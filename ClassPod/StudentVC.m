//
//  StudentVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import "StudentVC.h"
#import "CellTecherList.h"

@interface StudentVC ()
<UITableViewDelegate, UITableViewDataSource>
{
    DAO *dao;
    Preferences *prefs;
    NSArray <Teacher*>* arrayTeachers;
}

@property (weak, nonatomic) IBOutlet UITableView *tableTeachers;

@property (weak, nonatomic) IBOutlet UISwitch *swTeacherAudio;
@property (weak, nonatomic) IBOutlet UISwitch *swPersonalAudio;

@end

@implementation StudentVC

- (void) viewDidLoad
{
    [super viewDidLoad];

    dao = [DAO sharedInstance];
    prefs = [Preferences sharedPreferences];
    
    [self reloadAll];
}

- (void) reloadAll
{
    arrayTeachers = [dao teachersList];
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


    cell.name.text = teacher.courseName.length > 0 ? teacher.courseName : RStr(@"Unknow student");
    cell.imageCheck.image = [UIImage imageNamed:cheked ? @"CheckOn" : @"CheckOff"];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Teacher *teacher = arrayTeachers[indexPath.row];
}


@end
