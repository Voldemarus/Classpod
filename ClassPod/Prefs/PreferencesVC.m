//
//  PreferencesVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import "PreferencesVC.h"
#import "CellLabelSwith.h"
#import "ProfileEditVC.h"

#define TAG_TEACHER_MODE    11
#define TAG_BUTTON_TEACHER  12
#define TAG_BUTTON_STUDENT  13

@interface PreferencesVC ()
<UITableViewDelegate, UITableViewDataSource>
{
    Preferences *prefs;
}

@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation PreferencesVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    prefs = [Preferences sharedPreferences];
}

#pragma mark Table methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    CellLabelSwith *cell;
    cell.swith.tag = 0;
    if (row == 0) {
        cell = (CellLabelSwith*)[tableView dequeueReusableCellWithIdentifier:CellLabelSwithID forIndexPath:indexPath];
        cell.name.text = RStr(@"Start as teacher mode");
        cell.swith.on = prefs.teacherModeON;
        cell.swith.tag = TAG_TEACHER_MODE;
    } else if (row == 1) {
        cell = (CellLabelSwith*)[tableView dequeueReusableCellWithIdentifier:CellLabelButtonID forIndexPath:indexPath];
        cell.name.text = RStr(@"Edin teacher profile");
        cell.button.tag = TAG_BUTTON_TEACHER;
    } else if (row == 2) {
        cell = (CellLabelSwith*)[tableView dequeueReusableCellWithIdentifier:CellLabelButtonID forIndexPath:indexPath];
        cell.name.text = RStr(@"Edin student profile");
        cell.button.tag = TAG_BUTTON_STUDENT;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (row == 1 || row == 2) {
        ProfileEditVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileEditVC"];
        vc.screenMode = (row == 1) ? ScreenMode_Teachr : ScreenMode_Student;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (IBAction) switchPressed:(UISwitch*)sw
{
    if (sw.tag == TAG_TEACHER_MODE) {
        prefs.teacherModeON = sw.on;
    }
}

@end
