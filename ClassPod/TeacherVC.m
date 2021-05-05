//
//  TeacherVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import "TeacherVC.h"

@interface TeacherVC ()
<UITableViewDelegate, UITableViewDataSource>
{
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableStudents;
@property (weak, nonatomic) IBOutlet UIButton *buttonMusic;
@property (weak, nonatomic) IBOutlet UIButton *buttonMicrophone;

@end

@implementation TeacherVC

- (void) viewDidLoad
{
    [super viewDidLoad];
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
    return 20;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellStudent1" forIndexPath:indexPath];
    return cell;
}

@end
