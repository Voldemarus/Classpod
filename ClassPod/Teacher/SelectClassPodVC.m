//
//  SelectClassPodVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 30.06.2021.
//

#import "SelectClassPodVC.h"
#import "CellClassPods.h"
#import "TeacherVC.h"

@interface SelectClassPodVC () <UITableViewDelegate, UITableViewDataSource>
{
    DAO *dao;
    Preferences *prefs;

    NSArray <ClassPod *> * arrayClassPods;

    __weak IBOutlet UILabel * labelHeader;
    __weak IBOutlet UILabel * labelDetail;
    __weak IBOutlet UIButton * buttonAddClass;
    TeacherVC * teacherVC;
}

@property (weak, nonatomic) IBOutlet UITableView *tableClassPods;

@end

@implementation SelectClassPodVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    dao = [DAO sharedInstance];
    prefs = [Preferences sharedPreferences];

    [self reloadAllClassPod];

}

//- (void) viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self reloadAllClassPod];
//}

- (void) reloadAllClassPod
{
    arrayClassPods = [dao allClassPodsForCurrentTeacher];
    [self.tableClassPods reloadData];
}

- (IBAction) closePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (IBAction) newClassPodPressed:(id)sender
{
    DLog(@"newClassPodPressed");
    NSManagedObjectContext * moc = dao.moc;
    Teacher * teacher = [Teacher getByUuid:prefs.personalUUID inMoc:moc];
    if (!teacher) {
        teacher = [Teacher getAndModyfyOrCreateWithUUID:prefs.personalUUID newName:prefs.myName newNote:prefs.note newCourseName:prefs.courseName newHourRate:prefs.rate inMoc:moc];
    }
    ClassPod *newClassPod = [ClassPod getOrCgeateWithTeacher:teacher nameIfNew:@"New Class Pod Name" noteIfNew:@"New note this classpod" inMoc:moc];
    [self reloadAllClassPod];
}

#pragma mark Table methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayClassPods.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellClassPods * cell = (CellClassPods*)[tableView dequeueReusableCellWithIdentifier:CellClassPodsID forIndexPath:indexPath];

    ClassPod * classPod = arrayClassPods[indexPath.row];

    cell.name.text = classPod.name.length > 0 ? classPod.name : RStr(@"Unknow ClassPod");
    cell.note.text = classPod.note.length > 0 ? classPod.note : RStr(@"Note not writing");
    // cell.imageClassPod.image = [UIImage imageNamed:cheked ? @"CheckOn" : @"CheckOff"];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!teacherVC) {
        teacherVC = (TeacherVC*)[self.storyboard instantiateViewControllerWithIdentifier:@"TeacherVC"];
    }
    
    [self presentViewController:teacherVC animated:YES completion:^{
        ClassPod * classPod = arrayClassPods[indexPath.row];
        teacherVC.classPod = classPod;
    }];
}

@end
