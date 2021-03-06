//
//  TeacherVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import "TeacherVC.h"
#import "CellStudentList.h"
#import "ServiceLocator.h"
//#import "RadioTransmitter.h"
#import "LDRTPServer.h"
#import "PlayListMakerVC.h"
#import <AVKit/AVKit.h>


@interface TeacherVC ()
<UITableViewDelegate, UITableViewDataSource,
ServiceLocatorDelegate>
{
    DAO *dao;
    Preferences *prefs;
    ServiceLocator *srl;
    NSArray <Student*>* arrayStudents;
    Student * selectedStudent;
    PlayListMakerVC * playListMakerVC;
    BOOL musicPlaying;
    BOOL microfoneON;

    __weak IBOutlet UIButton * buttonPlayStop;

}

@property (weak, nonatomic) IBOutlet UITableView *tableStudents;
@property (weak, nonatomic) IBOutlet UIButton *buttonMusic;
@property (weak, nonatomic) IBOutlet UIButton *buttonMicrophone;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlaylistCreate;

@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) AVPlayerItem *playerItem;

@end

@implementation TeacherVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    dao = [DAO sharedInstance];
    prefs = [Preferences sharedPreferences];
    
    musicPlaying = NO;

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

- (void) viewWillDisappear:(BOOL)animated
{
    [srl stopService];
    srl = nil;
    [super viewWillDisappear:animated];
}

- (void) reloadAllStudents
{
    arrayStudents = [dao studentsForCurrentTeacherOnlyConnected:YES];
//    arrayStudents = [dao studentsForCurrentTeacherOnlyConnected:NO];
    [self.tableStudents reloadData];
}

#pragma mark - Button actions

- (IBAction) buttonMicrophonePressed:(id)sender
{
    microfoneON = !microfoneON;
    DLog(@"🐝 button Microphone Pressed %@", microfoneON ? @"Вкл" : @"Откл");
    
#warning ! Need edit selected student
    Student *student = selectedStudent;
    UInt32 port = student.socket.connectedPort;
    if (port == 0) {
        port = 51001;
    }
//    UInt32 port = 51001;
//    student.socket writeData:<#(NSData *)#> withTimeout:<#(NSTimeInterval)#> tag:<#(long)#>
//    LDRTPServer *server = LDRTPServer.sharedRTPServer;
    
    NSMutableArray *arraySocket = [NSMutableArray new];
    for (Student * student in arrayStudents) {
        // Послать сообщение студенту на воспроизведение/остановку музыки
        GCDAsyncSocket * soc = student.socket;
        if (soc) {
            [arraySocket addObject:soc];
        }
    }
//    LDAudioServer *server = [[LDAudioServer alloc] initWithSocketPort:port];
//    server.connectedClients = arraySocket;
//    if (microfoneON) {
//        [server start];
//    } else {
//        [server stop];
//    }

//    [server initialSocketPort:port];
//    [server open];


}

- (IBAction) buttonMusicPressed:(id)sender
{
//    if (!selectedStudent) {
//        DLog(@"Нет Выбранного студента!");
//    }
//
    musicPlaying = !musicPlaying;

    NSString * imageName = musicPlaying ? @"RadioBlack" : @"RadioBlackOff";
    [self.buttonMusic setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

    for (Student * student in arrayStudents) {
        // Послать сообщение студенту на воспроизведение/остановку музыки
        NSData *dataPlay = [dao packetDataPlayMusic:musicPlaying];
        [student.socket writeData:dataPlay withTimeout:-1.0f tag:0];
    }


//    RadioTransmitter * rt = [RadioTransmitter sharedTransmitter];
//    DLog(@"getIPAddress = [%@]", RadioTransmitter.getIPAddress);
}

- (IBAction) buttonPlaylistCreatePressed:(id)sender
{
    PlayListMakerVC *vc = (PlayListMakerVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"PlayListMakerVC"];
    [self presentViewController:vc animated:NO completion:^{
        vc.classPod = self.classPod;
    }];
}

- (void) changedStudent:(Student*) student
{
    [self reloadAllStudents];
}

#pragma mark - AVPlayer receiver


- (void) turnAudioOn
{
    [self.playerItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:nil];
    [self.player play];
    [buttonPlayStop setImage:[UIImage imageNamed:@"BT_Pause"] forState:UIControlStateNormal];
}

- (void) turnAudioOff
{
    [self.player pause];
    [self.playerItem removeObserver:self forKeyPath:@"timedMetadata"];
        self.player = nil;
        self.playerItem = nil;
    [buttonPlayStop setImage:[UIImage imageNamed:@"BT_Play"] forState:UIControlStateNormal];
}

- (IBAction) playPauseButtonClicked:(id) sender
{
    if (self.player.rate == 0.0) {
        if (!self.player) {
            NSURL *radioURL = [NSURL URLWithString:RADIO_URL];
            self.playerItem = [[AVPlayerItem alloc] initWithURL:radioURL];
            self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        }
        [self turnAudioOn];
    } else {
        [self turnAudioOff];
    }
}

#pragma mark - Table methods

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

    DLog(@"🍏 Notif @\"ОбновилсяСтудент\" recaved servise: [%@]" , student.name);

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
    DLog(@"🍏 New Abbonent  connected to the class! socket port: %hu", newSocket.localPort);
}

- (void) abonentDisconnected:(NSError *)error
{
    DLog(@"🍏 Abonent disconnected wish Message: %@", error.localizedDescription);

    [self reloadAllStudents];
}

- (void) didChangedServises:(NSArray<NSNetService *> *)serviceS
{
    DLog(@"🍏 didChangedServises: [%ld]", serviceS.count);

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
    DLog(@"🍏 didChangeTXTRecordData withServise name: [%@]", service.name);
    
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
