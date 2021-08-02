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

@interface StudentModeVC () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray <MCPeerID *> *lesson;
    NSMutableArray <MCPeerID *> *connected;
}

@property (weak, nonatomic) IBOutlet UITextField *studentName;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation StudentModeVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    lesson = [NSMutableArray new];

    self.tableview.dataSource = self;
    self.tableview.delegate = self;

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(lessondDetected:)
               name:GMMultipeerSubscribesUpdated object:nil];
    [nc addObserver:self selector:@selector(lessonRemoved:)
               name:GMMultipeerSubscribesRemoved object:nil];

}


/**
      Method is called when working on lesson is over.
 */
- (void) stopLesson:(MCPeerID *) peer
{

    [self.tableview reloadData];
}

#pragma mark - Selectors

- (void) lessondDetected:(NSNotification *)note
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
    [self.tableview reloadData];
}

@end
