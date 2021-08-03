//
//  TeacherModeVC.m
//  MultiPeerTest
//
//  Created by Водолазкий В.В. on 29.07.2021.
//


#import <GameKit/GameKit.h>

#import "TeacherModeVC.h"
#import "AppDelegate.h"
#import "UIView+Toast.h"
#import "DebugPrint.h"

@interface TeacherModeVC () <UITableViewDataSource, UITableViewDelegate, GMMultipeerDelegate>
{
    NSMutableArray *studentsPeer;
    NSString *lessonName;
    NSMutableDictionary *voiceChat;
    GKVoiceChat *activeChat;
}

@property (weak, nonatomic) IBOutlet UITextField *lessonLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    //  Initate audio chat
    if ([GKVoiceChat isVoIPAllowed] == NO) {
        [self.view makeToast:@"VOIP is not available for this device!"];
        return;
    }
    GKVoiceChat *chat = [voiceChat objectForKey:peer];
    if (!chat) {
        // There are no chat for this user created, Create it now

    } else {
        // this chat was created before
        chat.active = YES;
        activeChat = chat;
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
