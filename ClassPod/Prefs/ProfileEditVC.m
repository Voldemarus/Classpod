//
//  ProfileEditVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 12.05.2021.
//

#import "ProfileEditVC.h"

@interface ProfileEditVC ()
{
    
    __weak IBOutlet UILabel *labelHeader;

    __weak IBOutlet UILabel *labelName;
    __weak IBOutlet UITextField *textFieldName;

    __weak IBOutlet UILabel *labelNote;
    __weak IBOutlet UITextView *textViewNote;

    __weak IBOutlet UIView *viewTeacher;

    __weak IBOutlet UILabel *labelCourseName;
    __weak IBOutlet UITextField *textFieldCourseName;

    __weak IBOutlet UILabel *labelHourRate;
    __weak IBOutlet UITextField *textFieldHourRate;
}

@end

@implementation ProfileEditVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
    
}

- (void) setScreenMode:(ScreenMode)screenMode
{
    _screenMode = screenMode;
}

- (void) updateUI
{
    labelHeader.text = (self.screenMode == ScreenMode_Teachr) ? RStr(@"Edit teacher profile") : RStr(@"Edit student profile");
    labelName.text = RStr(@"Name:");
    textFieldName.text = @"?????????";
    labelNote.text = RStr(@"Note:");
    textViewNote.text = @"?????? текст примечания";
    if (self.screenMode == ScreenMode_Teachr) {
        viewTeacher.alpha = 1.0;
        labelCourseName.text = RStr(@"Course name:");
        textFieldCourseName.text = @"???? Название курса";
        labelHourRate.text = RStr(@"Hour Rate");
        textFieldHourRate.text = [NSString stringWithFormat:@"%.2f", 123.45];
    } else {
        viewTeacher.alpha = 0.0;
    }
}

- (IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}


@end
