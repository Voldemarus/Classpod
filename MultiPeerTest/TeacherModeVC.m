//
//  TeacherModeVC.m
//  MultiPeerTest
//
//  Created by Водолазкий В.В. on 29.07.2021.
//


// #import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "TeacherModeVC.h"
#import "AppDelegate.h"
#import "UIView+Toast.h"
#import "DebugPrint.h"
#import "TDAudioOutputStreamer.h"


@interface TeacherModeVC () <UITableViewDataSource, UITableViewDelegate, GMMultipeerDelegate>
{
    NSMutableArray *studentsPeer;
    NSString *lessonName;
    NSMutableDictionary *voiceChat;
 //   GKVoiceChat *activeChat;
    MCPeerID *selectedPeer;
}

@property (strong, nonatomic) MPMediaItem *song;
@property (strong, nonatomic) TDAudioOutputStreamer *outputStreamer;

@property (weak, nonatomic) IBOutlet UITextField *lessonLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *playSongButton;
- (IBAction)playSongButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *talkToStudentButton;
- (IBAction)talkButtonClicked:(id)sender;


@end

@implementation TeacherModeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    studentsPeer = [NSMutableArray new];
    voiceChat = [NSMutableDictionary new];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(invitationAccepted:) name:GMMultipeerInviteAccepted object:nil];
    [nc addObserver:self selector:@selector(advertiserFailed:) name:GMMultiPeerAdvertiserFailed object:nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    NSArray *buttons = @[self.talkToStudentButton, self.playSongButton];
    for (UIButton *b in buttons) {
        CALayer *l = b.layer;
        l.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.45 alpha:1.0].CGColor;
        [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        l.cornerRadius = 4.0;
        l.borderColor = [UIColor darkGrayColor].CGColor;
    }
}

- (IBAction)registerLessonClicked:(id)sender
{
    lessonName = self.lessonLabel.text;
    [self.lessonLabel resignFirstResponder];
    if (lessonName.length > 0) {
        AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
        d.engine = [[GMMultiPeer alloc] initWithLessonName:lessonName];
        if (d.engine) {
            d.engine.advertiseStatus = YES;
            d.engine.delegate = self;
            [self.view makeToast:@"Lesson registered"];
        }
    }
}


- (void) invitationAccepted:(NSNotification *)note
{
    MCPeerID *peer = [note object];
    NSString *userName = peer.displayName;
    [studentsPeer addObject:peer];
    NSLog(@"Invite from %@",userName);
    [self.tableView reloadData];
}

- (void) advertiserFailed:(NSNotification *)note
{
    [self.view makeToast:@"Failed to activate advertiser" duration:2.5 position:[CSToastManager defaultPosition]];
}

#pragma mark TableView -

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return studentsPeer.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPeerID *peer = studentsPeer[indexPath.row];
    NSString *name = peer.displayName;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"StudentCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StudentCell"];
    }
    cell.textLabel.text = name;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    MCPeerID *peer = studentsPeer[indexPath.row];
    NSLog(@"%@ selected", peer.displayName);
    selectedPeer = peer;

}

- (IBAction)playSongButtonClicked:(id)sender
{
    NSBundle *mb = [NSBundle mainBundle];
    NSURL *mediaURL = [mb URLForResource:@"in_file" withExtension:@"mp3"];
    if (!mediaURL) {
        [self.view makeToast:@"Tune is not found!"];
        return;
    }
    NSInteger peers = studentsPeer.count;
    if (peers == 0) {
        [self.view makeToast:@"No students connected to this lesson"];
        return;
    }
    AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
    GMMultiPeer *engine = d.engine;
    // Initiate streaming to all students

    if (d.engine.connectedStudents.count) {
        NSOutputStream *oStream = [engine startOutputMusicStreamForPeer:d.engine.connectedStudents[0]];
        self.outputStreamer = [[TDAudioOutputStreamer alloc] initWithOutputStream:oStream];
        [self.outputStreamer streamAudioFromURL:mediaURL];
        [self.outputStreamer start];
    }
}

- (IBAction)talkButtonClicked:(id)sender
{
    if (!selectedPeer && studentsPeer.count > 0) {
        selectedPeer = studentsPeer[0];
    }
    if (selectedPeer) {
        // prepare separate output stream
        AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSOutputStream *oStream = [d.engine startOutputVoiceStreamForPeer:selectedPeer];
        // prepare microphone

        NSError *myErr;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&myErr];
        if (myErr) {
            DLog(@"Cannot tune AudioSession - %@", [myErr localizedDescription]);
            return;
        }
        [audioSession setMode:AVAudioSessionModeVoiceChat error:&myErr];
        if (myErr) {
            DLog(@"Cannot set VOIP mode for AudioSession - %@", [myErr localizedDescription]);
            return;
        }
        [audioSession setActive:YES error:&myErr];
        if (myErr) {
            DLog(@"Cannot activate AudioSession - %@", [myErr localizedDescription]);
            return;
        }
        // Request permissions
        [audioSession requestRecordPermission:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:@"Access to microphione granted"];
                    // now we can proceed with audio dreaming
                    NSDictionary *settings = @{
                                    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                    AVSampleRateKey: @12000,
                                    AVNumberOfChannelsKey: @1,
                                    AVEncoderAudioQualityKey: @(AVAudioQualityMedium)
                    };
                   
                });
           }
        }];


    
    }
}


#pragma mark - GMMultipeerDelegate -

//
// Defines dictionary with arbitray content to be sent automatically to student when
// connection is established
//
- (NSDictionary *) session:(MCSession *)session initialPacketForPeer:(MCPeerID *)peer
{
    NSDate *cDate = [[NSDate date] dateByAddingTimeInterval:10*60];
    NSTimeInterval startInterval = [cDate timeIntervalSinceReferenceDate];
    NSDictionary *d = @{
        @"PacketType" :   @"Initial",
        @"TimeStamp"  :   @([NSDate timeIntervalSinceReferenceDate]),
        @"LessonName" :   lessonName,
        @"Duration"   :   @(15*60),        // 15 minutes
        @"Started"    :   @(startInterval), // started in 10 minutes
        @"Note"       :   @"Put here some specific info related to particular lesson",
    };
    return d;
}

- (void) session:(MCSession *)session processReceivedData:(NSDictionary *)data
{
    if (data) {
        DLog(@"Received data from student : %@",data);
    }
}


@end
