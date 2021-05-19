//
//  AppDelegate.m
//  ClassPodDebug
//
//  Created by Водолазкий В.В. on 12.05.2021.
//

#import "AppDelegate.h"
#import "DebugPrint.h"
#import "Preferences.h"
#import "DAO.h"
#import "ServiceLocator.h"

@interface AppDelegate () <NSTableViewDelegate, ServiceLocatorDelegate,
                            NSTableViewDataSource, NSTabViewDelegate>
{
    Preferences *prefs;
    ServiceLocator *srl;
    DAO *dao;
    BOOL currentMode;       // YES - server , NO - client

    NSArray <Teacher *> *teacherList;
    NSArray <Student *> *studentList;
    Teacher *connectedService;

}

@property (weak) IBOutlet NSTabView *modeTabView;

// Student tab
@property (weak) IBOutlet NSTextField *studentName;
@property (weak) IBOutlet NSTextField *studentUUID;
@property (weak) IBOutlet NSTableView *serviceTable;
@property (weak) IBOutlet NSTextField *studentNote;


@property (strong) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    prefs = [Preferences sharedPreferences];
    dao = [DAO sharedInstance];

    srl = [ServiceLocator sharedInstance];
    srl.delegate = self;

#ifdef DEBUG
    prefs.studentName = @"Я студиоз";
#endif

    [self.modeTabView selectTabViewItemAtIndex:prefs.testerMode];
    currentMode = (prefs.testerMode == 0);
//    if (currentMode == 0) {
//        [self startService];
//    } else {
        [self startBrowsing];
//    }
    self.studentUUID.stringValue = prefs.studentUUID.UUIDString;
    self.studentName.stringValue = prefs.studentName;
    self.studentNote.stringValue = prefs.studentNote;
    connectedService = nil;

    [self updateUI];
}

- (void) updateUI
{
    teacherList = [dao teachersList];
    studentList = @[];

    [self.serviceTable reloadData];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    prefs.studentName = self.studentName.stringValue;
    prefs.studentNote = self.studentNote.stringValue;
}

#pragma mark - ServiceLocator delegate -


- (void) newAbonentConnected:(GCDAsyncSocket *)newSocket
{
    NSLog(@">>> New Abbonent  connected to the class!");
}

- (void) abonentDisconnected:(NSError *)error
{
    NSLog(@"Abonent disconnected");
    if (error) {
        NSLog(@"Error on disconnectig - %@", [error localizedDescription]);
    }
}

- (void) didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    DLog(@"didFindService %@", service);
    Teacher *newTeacher = [dao newTeacherWithService:service];
    [self updateUI];
}
- (void) didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    DLog(@"didFindDomain %@", domainString);
}

#pragma mark - NSTableView Delegate/Dataspurce

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == self.serviceTable) {
        return teacherList.count;
    }

    return 0;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == self.serviceTable) {
        Teacher *t = teacherList[row];
        if ([tableColumn.identifier isEqualToString:@"ServerName"]) {
            return t.name;
        } else if ([tableColumn.identifier isEqualToString:@"ServerStatus"]) {
            if (t == connectedService) {
                return @"Connected";
            } else {
                return @"";
            }
        }
    }
    return tableColumn.identifier;
}

- (IBAction) serviceListAction:(id)sender
{
    NSTableView* tableView = (NSTableView*)sender;
    NSInteger index = tableView.selectedRow;
    if (index >= 0 && index < teacherList.count) {
        if (connectedService) {
            // detach actual service
            [self stopServiceConnection:index];
        }
        [self.serviceTable reloadData];
    }
}



#pragma mark - NSTabView delegate

- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem
{
    NSInteger index = [tabView indexOfTabViewItem:tabViewItem];
    prefs.testerMode = index;
    if (index == 0) {
        // service part
        [self stopServiceConnection:-1];
        srl.classProvider = YES;
        [self startService];
    } else {
        // client part
        [srl stopService];
        srl.classProvider = NO;
        [self startBrowsing];
    }
}

#pragma mark - Service Locator

- (void) startService
{

}

- (void) stopService
{

}

- (void) startBrowsing
{
    srl.classProvider = NO;
    srl.name = prefs.studentName;
    [srl startBrowsing];
}

- (void) stopServiceConnection:(NSInteger)index
{

}


@end
