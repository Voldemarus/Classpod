//
//  StudentModeVC.m
//  MultiPeerTest
//
//  Created by Водолазкий В.В. on 30.07.2021.
//

#import "StudentModeVC.h"
#import "GMMultiPeer.h"
#import "UIView+Toast.h"
#import "AppDelegate.h"
#import "TDAudioInputStreamer.h"

@interface StudentModeVC () <UITableViewDelegate, UITableViewDataSource, GMMultipeerDelegate>
{
    NSMutableArray <MCPeerID *> *lesson;
    NSMutableArray <MCPeerID *> *connected;
}

@property (weak, nonatomic) IBOutlet UITextField *studentName;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *lessonNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonTimeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonStartTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *lessonDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonDuration;

@property (nonatomic, retain) TDAudioInputStreamer *musicStream;
@property (nonatomic, retain) TDAudioInputStreamer *voiceStream;

@end

@implementation StudentModeVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    lesson = [NSMutableArray new];
    connected = [NSMutableArray new];

    self.tableview.dataSource = self;
    self.tableview.delegate = self;

    self.lessonNameLabel.text = @"";
    self.lessonTimeStampLabel.text = @"";
    self.lessonStartTimeLabel.text = @"";
    self.lessonDuration.text = @"";
    self.lessonDescriptionLabel.text = @"";

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(lessonDetected:)
               name:GMMultipeerSubscribesUpdated object:nil];
    [nc addObserver:self selector:@selector(lessonRemoved:)
               name:GMMultipeerSubscribesRemoved object:nil];
    [nc addObserver:self selector:@selector(peerConnected:)
               name:GMMultipeerSessionConnected object:nil];
    [nc addObserver:self selector:@selector(peerDisconnected:)
               name:GMMultipeerSessionNotConnected object:nil];
    [nc addObserver:self selector:@selector(connectionInProgress:)
               name:GMMultipeerSessionConnecting object:nil];
}


/**
      Method is called when working on lesson is over.
 */
- (void) stopLesson:(MCPeerID *) peer
{

    [self.tableview reloadData];
}

#pragma mark - Selectors

- (void) peerConnected:(NSNotification *) note
{
    MCPeerID *peer = (MCPeerID *)[note object];
    NSInteger index = [connected indexOfObject:peer];
    if (index == NSNotFound) {
        [lesson removeObject:peer];
        [connected addObject:peer];
    }
    [self.tableview reloadData];
}

- (void) peerDisconnected:(NSNotification *) note
{
    MCPeerID *peer = (MCPeerID *)[note object];
    NSInteger index = [connected indexOfObject:peer];
    if (index != NSNotFound) {
        [connected removeObject:peer];
        [lesson addObject:peer];
    } else {
        [self.view makeToast:@"Failed to connect!"];
    }
    [self.tableview reloadData];
}

- (void) connectionInProgress:(NSNotification *) note
{
    [self.view makeToast:@"Connection in progress"];
}

- (void) lessonDetected:(NSNotification *)note
{
    MCPeerID *peer = (MCPeerID *)[note object];
    NSInteger index = [connected indexOfObject:peer];
    if (index == NSNotFound) {
        index = [lesson indexOfObject:peer];
        if (index == NSNotFound) {
            [lesson addObject:peer];
            [self.tableview reloadData];
        }
    }
}

- (void) lessonRemoved:(NSNotification *) note
{
    MCPeerID *peer = (MCPeerID *)[note object];
    NSInteger index = [connected indexOfObject:peer];
    if (index != NSNotFound) {
        // this is an active lesson. Perform all necessary actions
        // to stop lesson related activities
        [self stopLesson:peer];
        [connected removeObjectAtIndex:index];
    } else {
        // this lesson is not used by student, so we can just remove it
        // from the lesson' list
        index = [lesson indexOfObject:peer];
        if (index != NSNotFound) {
            [lesson removeObjectAtIndex:index];
            [self.tableview reloadData];
        }
    }
}


#pragma mark - UITableView delegate

- (NSInteger) tableView:(UITableView *)tableView
                    numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return connected.count;
    } else {
        return lesson.count;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0 ? @"Connected Lesson" : @"Total Lessons list");
}


- (UITableViewCell *) tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPeerID *peer = (indexPath.section == 0 ? connected[indexPath.row] : lesson[indexPath.row]);
    NSString *displayName = peer.displayName;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"qqq"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"qqq"];
    }
    cell.textLabel.text = displayName;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (indexPath.section == 0) {
        // connected record selected, need to detach from lesson
        MCPeerID *peer = connected[indexPath.row];
        [self stopLesson:peer];
    } else {
        // not connected, trying to connect
        NSString *sName = self.studentName.text;
        if (sName.length == 0) {
            [self.view makeToast:@"Name should be entered!"];
        }
        // Make request to the selected lesson
        MCPeerID *peer = lesson[indexPath.row];
        [d.engine invitePeer:peer];
    }

}

- (IBAction)doneClicked:(id)sender
{
    [self.studentName resignFirstResponder];
    NSString *sName = self.studentName.text;
    if (sName.length == 0) {
        [self.view makeToast:@"Name should be entered!"];
        return;
    }
    AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
    d.engine = [[GMMultiPeer alloc] initWithStudentsName:sName];
    d.engine.browsingStatus = YES;
    d.engine.delegate = self;
}

#pragma mark - GMMultipeerDelegate -

-(void) session:(MCSession *)session processReceivedData:(NSDictionary *)data
{
    NSString *packType = data[@"PacketType"];
    if (packType && [packType isEqualToString:@"Initial"]) {
        // This is is data packet auto sent when connection is established
        NSNumber *timestampN = data[@"TimeStamp"];
        NSDate *timestamp = [NSDate dateWithTimeIntervalSinceReferenceDate:timestampN.doubleValue];
        NSTimeInterval duration = [data[@"Duration"] doubleValue];
        NSNumber *startDateN = data[@"Started"];
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:startDateN.doubleValue];
        NSString *actualName  =  data[@"LessonName"];
        NSString *note = data[@"Note"];
        // Now we will show them on the screen
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lessonNameLabel.text = actualName;
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MMM/dd/YYYY hh:mm:ss"];
            self.lessonTimeStampLabel.text = [df stringFromDate:timestamp];
            self.lessonStartTimeLabel.text = [df stringFromDate:startDate];
            int minutes = duration/60;
            int seconds = duration - (minutes * 60);
            self.lessonDuration.text = [NSString stringWithFormat:@"%02d:%02d min", minutes, seconds];
            self.lessonDescriptionLabel.text = note;
       });
    }
}

/**
    If music stream was not created before, just start it. Either we should resume it if voice translation is over
 */
- (void) session:(MCSession *)session didReceiveMusicStream:(NSInputStream *)stream
{
    if (!self.musicStream) {
        self.musicStream = [[TDAudioInputStreamer alloc] initWithInputStream:stream];
        [self.musicStream start];
    } else if (self.voiceStream == nil || self.musicStream.isPaused == YES) {

        [self.musicStream resume];
    }
}

- (void) session:(MCSession *)session didReceiveVoiceStream:(NSInputStream *)stream
{
    if (!self.voiceStream) {
        self.voiceStream = [[TDAudioInputStreamer alloc] initWithInputStream:stream];
        [self.musicStream pause];
        [self.voiceStream start];
    }
}

@end
