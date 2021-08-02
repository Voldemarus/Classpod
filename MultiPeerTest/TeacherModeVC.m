//
//  TeacherModeVC.m
//  MultiPeerTest
//
//  Created by Водолазкий В.В. on 29.07.2021.
//

#import "TeacherModeVC.h"
#import "AppDelegate.h"
#import "UIView+Toast.h"

@interface TeacherModeVC () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *studentsPeer;
}

@property (weak, nonatomic) IBOutlet UITextField *lessonLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TeacherModeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    studentsPeer = [NSMutableArray new];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(invitationAccepted:) name:GMMultipeerInviteAccepted object:nil];
    [nc addObserver:self selector:@selector(advertiserFailed:) name:GMMultiPeerAdvertiserFailed object:nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (IBAction)registerLessonClicked:(id)sender
{
    NSString *lessonName = self.lessonLabel.text;
    [self.lessonLabel resignFirstResponder];
    if (lessonName.length > 0) {
        AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
        d.engine = [[GMMultiPeer alloc] initWithLessonName:lessonName];
        if (d.engine) {
            d.engine.advertiseStatus = YES;
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
}



@end
