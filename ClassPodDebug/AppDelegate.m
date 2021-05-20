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

    NSMutableDictionary <NSString*, GCDAsyncSocket*> * dictSockets;

    NSMutableArray <NSNetService *> *teacherServiceList;
//    NSArray <Teacher *> *teacherList;
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

    teacherServiceList = [NSMutableArray new];
    dictSockets = [NSMutableDictionary new];
    
    [self.modeTabView selectTabViewItemAtIndex:prefs.testerMode];

    if (prefs.testerMode == TesterMode_Teacher) {
        [self startService];
    } else {
        [self startBrowsing];
    }
    
    self.studentUUID.stringValue = prefs.personalUUID;
    self.studentName.stringValue = prefs.myName;
    self.studentNote.stringValue = prefs.note;
    
    connectedService = nil;

    [self updateUI];
}

- (void) updateUI
{
//    teacherList = [dao teachersList];
    studentList = @[];

    [self.serviceTable reloadData];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    prefs.myName = self.studentName.stringValue;
    prefs.note = self.studentNote.stringValue;
}

- (void) controlTextDidEndEditing:(NSNotification *)obj
{
    NSTextField *tf = obj.object;
    if (tf == self.studentName) {
        prefs.myName = tf.stringValue;
    } else if (tf == self.studentNote) {
        prefs.note = tf.stringValue;
    }
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
    DLog(@"Find Service: %@", service);
    DLog(@"Find Service name: %@, type: %@, port: %ld", service.name, service.type, service.port);
    
    BOOL needAdd = YES;
    for (NSNetService *serv in teacherServiceList) {
        if ([serv.name isEqualToString:service.name]) {
            needAdd = NO;
            break;
        }
    }
    if (needAdd) {
        [teacherServiceList addObject:service];
    }

    //    Teacher *newTeacher = [dao newTeacherWithService:service];
    [self updateUI];
}
- (void) didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    DLog(@"❓ didFindDomain %@", domainString); // Видимо не используем?
}
- (void) didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    DLog(@"Remove Service: %@", service);
    DLog(@"Remove Service name: %@, type: %@, port: %ld", service.name, service.type, service.port);
//    Teacher *newTeacher = [dao te];
    
    for (NSNetService *serv in teacherServiceList) {
        if ([serv.name isEqualToString:service.name]) {
            [teacherServiceList removeObject:service];
            break;
        }
    }
    
    [self updateUI];
}

#pragma mark - NSTableView Delegate/Dataspurce

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == self.serviceTable) {
        return teacherServiceList.count;
//        return teacherList.count;
    }

    return 0;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == self.serviceTable) {
//        Teacher *t = teacherList[row];
        NSNetService *service = teacherServiceList[row];
        if ([tableColumn.identifier isEqualToString:@"ServerName"]) {
            return service.name;
//            return t.name;
        } else if ([tableColumn.identifier isEqualToString:@"ServiceStatus"]) {
            return [NSString stringWithFormat:@"port: %ld", service.port];
//            if (t == connectedService) {
//                return @"Connected";
//            } else {
//                return @"";
//            }
        }
    }
    return tableColumn.identifier;
}

- (IBAction) serviceListAction:(id)sender
{
    NSTableView* tableView = (NSTableView*)sender;
    NSInteger index = tableView.selectedRow;
    if (index >= 0 && index < teacherServiceList.count) {
        NSNetService *service = teacherServiceList[index];
        if (connectedService) {
            // detach actual service
            [self stopServiceConnection:service];
        } else {
            [self connectWithService:service];
        }
        [self.serviceTable reloadData];
    }
}
//
//- (IBAction) serviceListAction:(id)sender
//{
//    NSTableView* tableView = (NSTableView*)sender;
//    NSInteger index = tableView.selectedRow;
//    if (index >= 0 && index < teacherList.count) {
//        if (connectedService) {
//            // detach actual service
//            [self stopServiceConnection:index];
//        }
//        [self.serviceTable reloadData];
//    }
//}



#pragma mark - NSTabView delegate

- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem
{
    BOOL studentMode = ([tabView indexOfTabViewItem:tabViewItem] == 0);
    prefs.testerMode = studentMode ? TesterMode_Student : TesterMode_Teacher;
    
    if (prefs.testerMode == TesterMode_Student) {
        // service part
        [self stopServiceConnection:nil];
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
    srl.name = prefs.myName;
    [srl startBrowsing];
}

- (BOOL) connectWithService:(NSNetService*)service
{
    NSString *name = service.name;
    if (service.name.length < 1) {
        DLog(@"❗️ нет имени: %@", service);
        return NO;
    }
    
    Student * studentSelf = [dao getOrCreateStudetnSelf];
    NSData *dataPack = [dao dataPackForStudent:studentSelf];
    
    BOOL isConnected=NO;
    
    NSArray* arrAddress = service.addresses.mutableCopy;
    
    GCDAsyncSocket * coSocket= dictSockets[name];
    
    
    if (!coSocket || !coSocket.isConnected) {
        
        GCDAsyncSocket * coSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //Connect
        while (!isConnected && arrAddress.count) {
            NSData* address= arrAddress[0];
            NSError* error;
            if ([coSocket connectToAddress:address error:&error]) {
                dictSockets[name] = coSocket;
                isConnected=YES;
                DLog(@"Connected: %@", name);
            } else if (error) {
                DLog(@"Unable to connect with Device %@ userinfo %@", error, error.userInfo);
            } else {
                DLog(@"Непонятно что: %@", name);
            }
        }
    } else {
        isConnected = coSocket.isConnected;
    }
    
    
    return isConnected;
    
}

- (void) stopServiceConnection:(NSNetService*)service
{

}

@end
