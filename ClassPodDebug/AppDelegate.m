//
//  AppDelegate.m
//  ClassPodDebug
//
//  Created by Водолазкий В.В. on 12.05.2021.
//

#import "AppDelegate.h"
#import "TesterPreferences.h"
#import "DAO.h"
#import "ServiceLocator.h"

@interface AppDelegate () <NSTableViewDelegate, NSTableViewDataSource, NSTabViewDelegate>
{
    TesterPreferences *prefs;
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
@property (unsafe_unretained) IBOutlet NSTextView *studentNote;


@property (strong) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    prefs = [TesterPreferences sharedPreferences];
    dao = [DAO sharedInstance];

    [self.modeTabView selectTabViewItemAtIndex:prefs.testerMode];
    currentMode = (prefs.testerMode == 0);
    self.studentUUID.stringValue = prefs.studentUUID;
    self.studentName.stringValue = prefs.studentName;
    self.studentNote.string = prefs.studentNote;
    connectedService = nil;

    teacherList = @[];
    studentList = @[];

    [self.serviceTable reloadData];


}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
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
}

- (IBAction)serviceListAction:(id)sender {
    NSTableView* tableView = (NSTableView*)sender;
    NSInteger index = tableView.selectedRow;

    if (connectedService) {
        // detach actual service

    }
    [self.serviceTable reloadData];
}



#pragma mark - NSTabView delegate


@end
