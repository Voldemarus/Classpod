//
//  TeacherVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import "TeacherVC.h"
#import "CellStudentList.h"

@interface TeacherVC ()
<UITableViewDelegate, UITableViewDataSource>
{
    DAO *dao;
    Preferences *prefs;
    NSArray <Student*>* arrayStudents;
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
    
    [self reloadAll];
}

- (void) reloadAll
{
    arrayStudents = [dao studentsForCurrentTeacher];
}

- (IBAction) buttonMicrophonePressed:(id)sender
{
    DLog(@"🐝 button Microphone Pressed");
}

- (IBAction) buttonMusicPressed:(id)sender
{
    DLog(@"🐝 button Music Pressed");
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
    Student *student = arrayStudents[indexPath.row];
    
}
@end
