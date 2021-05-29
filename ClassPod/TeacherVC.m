//
//  TeacherVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import "TeacherVC.h"
#import "CellStudentList.h"
#import "ServiceLocator.h"
#import "RadioTransmitter.h"
#import "LDRTPServer.h"

@interface TeacherVC ()
<UITableViewDelegate, UITableViewDataSource,
ServiceLocatorDelegate>
{
    DAO *dao;
    Preferences *prefs;
    ServiceLocator *srl;
    NSArray <Student*>* arrayStudents;
    Student * selectedStudent;
}

@property (weak, nonatomic) IBOutlet UITableView *tableStudents;
@property (weak, nonatomic) IBOutlet UIButton *buttonMusic;
@property (weak, nonatomic) IBOutlet UIButton *buttonMicrophone;

@end

@implementation TeacherVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    dao = [DAO sharedInstance];
    prefs = [Preferences sharedPreferences];

    srl = [ServiceLocator sharedInstance];
    [srl stopService];
    srl.delegate = self;
    srl.classProvider = YES;
    NSString *clName = [NSString stringWithFormat:@"Classpod %@", prefs.myName];
    srl.name = clName;
    [srl publishService];

    NSNotificationCenter * nc = NSNotificationCenter.defaultCenter;
    [nc addObserver:self selector:@selector(refreshStudentNotif:) name:@"ОбновилсяСтудент" object:nil];

    [self reloadAllStudents];
}

- (void) reloadAllStudents
{
    arrayStudents = [dao studentsForCurrentTeacherOnlyConnected:YES];
    [self.tableStudents reloadData];
}

- (IBAction) buttonMicrophonePressed:(id)sender
{
    DLog(@"🐝 button Microphone Pressed");
}

- (IBAction) buttonMusicPressed:(id)sender
{
    if (!selectedStudent) {
        DLog(@"Нет Выбранного студента!");
    }

#warning ! Need edit selected student
    Student *student = selectedStudent;
    UInt32 port = student.socket.connectedPort;
//    UInt32 port = 51001;
//    student.socket writeData:<#(NSData *)#> withTimeout:<#(NSTimeInterval)#> tag:<#(long)#>
    DLog(@"🐝 button Music Pressed");
    LDRTPServer *server = LDRTPServer.sharedRTPServer;
    
    [server initialSocketPort:port];
    [server open];

    
//    RadioTransmitter * rt = [RadioTransmitter sharedTransmitter];
//    DLog(@"getIPAddress = [%@]", RadioTransmitter.getIPAddress);
}

- (void) changedStudent:(Student*) student
{
    [self reloadAllStudents];
}

#pragma mark Table methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayStudents.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellStudentList * cell = (CellStudentList*)[tableView dequeueReusableCellWithIdentifier:CellStudentListID forIndexPath:indexPath];

    Student *student = arrayStudents[indexPath.row];

#warning Need Edit priznak cheked students
    BOOL cheked = YES;


    cell.name.text = student.name.length > 0 ? student.name : RStr(@"Unknow student");
    cell.imageCheck.image = [UIImage imageNamed:cheked ? @"CheckOn" : @"CheckOff"];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedStudent = arrayStudents[indexPath.row];
}

#pragma mark - ServiceLocator delegate -

- (void) refreshStudentNotif:(NSNotification*) notif
{
    Student *student = notif.object;

    DLog(@">>> Notif @\"ОбновилсяСтудент\" recaved servise: [%@]" , student.name);

    if (student) {
        NSInteger row = [arrayStudents indexOfObject:student];
        if (row != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableStudents reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        } else {
            [self reloadAllStudents];
        }
    } else {
        [self reloadAllStudents];
    }
}

- (void) newAbonentConnected:(GCDAsyncSocket *)newSocket
{
    DLog(@">>> New Abbonent  connected to the class!");
}

- (void) abonentDisconnected:(NSError *)error
{
    DLog(@"Abonent disconnected wish Message: %@", error.localizedDescription);
    
    [self reloadAllStudents];
}

- (void) didChangedServises:(NSArray<NSNetService *> *)serviceS
{
    DLog(@">>> didChangedServises: [%ld]", serviceS.count);

//    [arrayTeachers removeAllObjects];
//
//    for (Teacher *teacher in [dao teachersListWithService]) {
//        teacher.service = nil;
//    }
//
//    for (NSNetService * service in serviceS) {
//        Teacher *teacher = [Teacher getOrCgeateWithService:service inMoc:dao.moc];
//        [arrayTeachers addObject:teacher];
//    }
    
    [self reloadAllStudents];
}

- (void) didChangeTXTRecordData:(NSData *)data withServise:(NSNetService *)service
{
    DLog(@">>> didChangeTXTRecordData withServise name: [%@]", service.name);
    
    Student *student = [Student getFromUuidInTXTData:data inMoc:dao.moc];
    
    NSInteger row = [arrayStudents indexOfObject:student];
    if (row != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableStudents reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    } else {
        [self reloadAllStudents];
    }
}

@end
