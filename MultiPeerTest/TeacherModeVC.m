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


@interface TeacherModeVC () <UITableViewDataSource, UITableViewDelegate,
    GMMultipeerDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
    NSMutableArray *studentsPeer;
    NSString *lessonName;
    NSMutableDictionary *voiceChat;
 //   GKVoiceChat *activeChat;
    MCPeerID *selectedPeer;
}

@property (strong, nonatomic) MPMediaItem *song;
@property (strong, nonatomic) TDAudioOutputStreamer *outputStreamer;

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureAudioDataOutput *dataOutput;
@property (nonatomic, retain) AVCaptureDeviceInput *mic;
@property (nonatomic, retain)  NSOutputStream *oStream;

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
#warning Process loop variable bia settings or lesson mode!
        [self.outputStreamer streamAudioFromURL:mediaURL loop:YES];
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
        self.oStream = [d.engine startOutputVoiceStreamForPeer:selectedPeer];
        self.outputStreamer = [[TDAudioOutputStreamer alloc] initWithOutputStream:self.oStream];

         self.captureSession = [[AVCaptureSession alloc] init];
        self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        self.dataOutput = [[AVCaptureAudioDataOutput alloc] init];
        [self.dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        NSError *error = nil;
        NSArray *audioInputType = @[AVCaptureDeviceTypeBuiltInMicrophone];
        AVCaptureDeviceDiscoverySession *audioInputDevice = [
                                                             AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:audioInputType mediaType:AVMediaTypeAudio position:AVCaptureDevicePositionUnspecified];
        NSArray *audioDevices = audioInputDevice.devices;
        AVCaptureDevice *micDevice = nil;
        if ([audioDevices count]) {
            micDevice = [audioDevices objectAtIndex:0];  // use the first audio device
        } else {
            [self.view makeToast:@"Cannot detect microphone"];
            DLog(@"Cannot detect microphone on this device");
            return;
        }
        self.mic = [AVCaptureDeviceInput deviceInputWithDevice:micDevice error:&error];
        if (error) {
            [self.view makeToast:@"Error during mic intialisation"];
            DLog(@"Cannot initalize microphone device - %@", [error localizedDescription]);
            return;
        }
        [self.captureSession addInput:self.mic];
        [self.captureSession addOutput:self.dataOutput];
        [self.captureSession startRunning];

        [self.outputStreamer start];

//        // prepare microphone
//
//        NSError *myErr;
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&myErr];
//        if (myErr) {
//            DLog(@"Cannot tune AudioSession - %@", [myErr localizedDescription]);
//            return;
//        }
//        [audioSession setMode:AVAudioSessionModeVoiceChat error:&myErr];
//        if (myErr) {
//            DLog(@"Cannot set VOIP mode for AudioSession - %@", [myErr localizedDescription]);
//            return;
//        }
//        [audioSession setActive:YES error:&myErr];
//        if (myErr) {
//            DLog(@"Cannot activate AudioSession - %@", [myErr localizedDescription]);
//            return;
//        }
//        // Request permissions
//        [audioSession requestRecordPermission:^(BOOL granted) {
//            if (granted) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.view makeToast:@"Access to microphione granted"];
//                    // now we can proceed with audio dreaming
//                    NSDictionary *settings = @{
//                                    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
//                                    AVSampleRateKey: @12000,
//                                    AVNumberOfChannelsKey: @1,
//                                    AVEncoderAudioQualityKey: @(AVAudioQualityMedium)
//                    };
//
//                });
//           }
//        }];
    }
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate -

#ifndef BUFFER_SIZE
#define BUFFER_SIZE 8192
#endif

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CMBlockBufferRef block = CMSampleBufferGetDataBuffer(sampleBuffer);
    NSAssert(block, @"Block should be valid");
    size_t length = 0;
    void  *data  = malloc(BUFFER_SIZE*sizeof(double_t));
    OSStatus status = CMBlockBufferGetDataPointer(block, 0, nil, &length, data);
    if (status == 0) {
        if (self.oStream.streamStatus == NSStreamStatusWriting) {
            NSInteger written = [self.oStream write:data maxLength:BUFFER_SIZE];
#ifdef DEBUG
            printf("written : %4ld :: ", (long)written);
            unsigned char *dd = data;
            for (int i = 0; i < written; i++) {
                printf("%02d ",dd[i]);
            }
            printf("\n");
#endif
        } else {
            DLog(@"Mic capturing stream is not oened yet!!!");
        }
    }
    free(data);
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
