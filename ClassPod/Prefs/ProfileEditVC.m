//
//  ProfileEditVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 12.05.2021.
//

#import "ProfileEditVC.h"

@interface ProfileEditVC ()
<UITextFieldDelegate, UITextViewDelegate>
{
    Preferences *prefs;
    
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
    prefs = [Preferences sharedPreferences];
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
    textFieldName.text = prefs.myName;
    labelNote.text = RStr(@"Note:");
    textViewNote.text = prefs.note;
    if (self.screenMode == ScreenMode_Teachr) {
        viewTeacher.alpha = 1.0;
        labelCourseName.text = RStr(@"Course name:");
        textFieldCourseName.text = prefs.courseName;
        labelHourRate.text = RStr(@"Hour Rate");
        textFieldHourRate.text = [NSString stringWithFormat:@"%.2f", prefs.rate];
    } else {
        viewTeacher.alpha = 0.0;
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    NSString *text = textField.text;
    if (textField == textFieldName) {
        prefs.myName = text;
    } if (textField == textFieldCourseName) {
        prefs.courseName = text;
    } if (textField == textFieldHourRate) {
        text = [text stringByReplacingOccurrencesOfString:@"," withString:@"."];
        prefs.rate = text.doubleValue;
        textFieldHourRate.text = [NSString stringWithFormat:@"%.2f", prefs.rate];
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (textView == textViewNote) {
        prefs.note = textView.text;
    }
}

- (IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}


@end
