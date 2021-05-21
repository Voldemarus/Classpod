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

@end

@implementation SelectTeacherVC

- (void) viewDidLoad
{
    [super viewDidLoad];

    dao = [DAO sharedInstance];
    prefs = [Preferences sharedPreferences];
    
    arrayTeachers = [dao teachersListWithService].mutableCopy;
    
    srl = [ServiceLocator sharedInstance];
    srl.delegate = self;
    srl.classProvider = NO;
    srl.name = prefs.myName;
    [srl startBrowsing];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadAllTeachers];
}

- (void) reloadAllTeachers
{
        arrayTeachers = [dao teachersListWithService].mutableCopy;
        [self.tableTeachers reloadData];
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
    cell.courseName.text = teacher.courseName;
    cell.note.text = teacher.note;
    cell.hourRate.text = [NSString stringWithFormat:@"Rate of hour: %.2f", teacher.hourRate];

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
    
    for (Teacher *teacher in [dao teachersListWithService]) {
        teacher.service = nil;
    }
    
    for (NSNetService * service in serviceS) {
        Teacher *teacher = [Teacher getOrCgeateWithService:service inMoc:dao.moc];
        [arrayTeachers addObject:teacher];
    }
    
    [self reloadAllTeachers];
}

- (void) didChangeTXTRecordData:(NSData *)data withServise:(NSNetService *)service
{
    Teacher *teacher = [Teacher getOrCgeateWithService:service withTXTData:data inMoc:dao.moc];
    
    NSInteger row = [arrayTeachers indexOfObject:teacher];
    if (row != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableTeachers reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    } else {
        [self reloadAllTeachers];
    }
}


@end
