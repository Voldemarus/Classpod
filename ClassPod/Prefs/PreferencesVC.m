//
//  PreferencesVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import "PreferencesVC.h"
#import "CellLabelSwith.h"

#define TAG_TEACHER_MODE    11

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
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    CellLabelSwith *cell = (CellLabelSwith*)[tableView dequeueReusableCellWithIdentifier:CellLabelSwithID forIndexPath:indexPath];
    cell.swith.tag = 0;
    if (row == 0) {
        cell.name.text = RStr(@"Start as teacher mode");
        cell.swith.on = prefs.teacherModeON;
        cell.swith.tag = TAG_TEACHER_MODE;
    }
    return cell;
}

- (IBAction) switchPressed:(UISwitch*)sw
{
    if (sw.tag == TAG_TEACHER_MODE) {
        prefs.teacherModeON = sw.on;
    }
}

@end
