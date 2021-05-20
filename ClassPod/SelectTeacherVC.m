//
//  SelectTeacherVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 20.05.2021.
//

#import "SelectTeacherVC.h"
#import "CellTecherList.h"
#import "StudentVC.h"
#import "ServiceLocator.h"

@interface SelectTeacherVC ()
<
UITableViewDelegate, UITableViewDataSource,
ServiceLocatorDelegate
>
{
    DAO *dao;
    Preferences *prefs;
    ServiceLocator *srl;

    NSMutableArray <Teacher *> * arrayTeachers;

    __weak IBOutlet UILabel * labelHeader;
    __weak IBOutlet UILabel * labelDetail;
    StudentVC * studentVC;
}

@property (weak, nonatomic) IBOutlet UITableView *tableTeachers;

@property (weak, nonatomic) IBOutlet UISwitch *swTeacherAudio;
@property (weak, nonatomic) IBOutlet UISwitch *swPersonalAudio;

@end

@implementation SelectTeacherVC

- (void) viewDidLoad
{
    [super viewDidLoad];

    dao = [DAO sharedInstance];
    prefs = [Preferences sharedPreferences];
    
    arrayTeachers = [dao teachersList].mutableCopy;
    
    srl = [ServiceLocator sharedInstance];
    srl.delegate = self;
    srl.classProvider = NO;
    srl.name = prefs.myName;
    [srl startBrowsing];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateUI];
}

- (void) updateUI
{
    
    [DAO runMainThreadBlock:^{
        self.swTeacherAudio.on = self->prefs.audioTeacherON;
        self.swPersonalAudio.on = self->prefs.audioPersonalON;
    }];
    
//    arrayTeachers = [dao teachersList].mutableCopy;
    [self.tableTeachers reloadData];
}

- (IBAction) switchPressed:(UISwitch*)sw
{
    if (sw == self.swTeacherAudio) {
        prefs.audioTeacherON = sw.on;
    } else if (sw == self.swPersonalAudio) {
        prefs.audioPersonalON = sw.on;
    }
}

#pragma mark Table methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayTeachers.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellTecherList * cell = (CellTecherList*)[tableView dequeueReusableCellWithIdentifier:CellTecherListID forIndexPath:indexPath];

    Teacher *teacher = arrayTeachers[indexPath.row];

#warning Need Edit priznak cheked students
    BOOL cheked = YES;


//    cell.name.text = teacher.courseName.length > 0 ? teacher.courseName : RStr(@"Unknow student");
    cell.name.text = teacher.name.length > 0 ? teacher.name : RStr(@"Unknow student");
    cell.imageCheck.image = [UIImage imageNamed:cheked ? @"CheckOn" : @"CheckOff"];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!studentVC) {
        studentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StudentVC"];
    }
    Teacher *teacher = arrayTeachers[indexPath.row];
    studentVC.teacher = teacher;
    [self presentViewController:studentVC animated:YES completion:^{
        //
    }];
}

#pragma mark - ServiceLocator delegate -

- (void) newAbonentConnected:(GCDAsyncSocket *)newSocket
{
    DLog(@">>> New Abbonent  connected to the class!");
}

- (void) abonentDisconnected:(NSError *)error
{
    DLog(@"Abonent disconnected %@", error ? [NSString stringWithFormat:@"\nError on disconnectig - %@", error.localizedDescription] : @"");
}
- (void) didChangedServises:(NSArray<NSNetService *> *)serviceS
{

    [arrayTeachers removeAllObjects];
    
    for (Teacher *tea in [dao teachersList]) {
        tea.service = nil;
    }
    
    for (NSNetService * service in serviceS) {
        Teacher *teacher = [Teacher getOrCgeateWithService:service inMoc:dao.moc];
        [arrayTeachers addObject:teacher];
    }
    
    [self updateUI];
}

@end
