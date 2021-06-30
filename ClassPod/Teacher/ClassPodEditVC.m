//
//  ClassPodEditVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 30.06.2021.
//

#import "ClassPodEditVC.h"

@interface ClassPodEditVC ()
<UITextFieldDelegate, UITextViewDelegate>
{
    Preferences *prefs;
    BOOL hasChange;
    
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

@property (nonatomic, retain) ClassPod *classPod;
@property (nonatomic,copy) ClassPodEditVCResponseBlock responseBlock;

@end

@implementation ClassPodEditVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    prefs = [Preferences sharedPreferences];
    hasChange = NO;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateUI];
}

//- (void) setClassPod:(ClassPod *)classPod
- (void) setClassPod:(ClassPod *)classPod responseBlock:(ClassPodEditVCResponseBlock _Nullable)responseBlock
{
    _classPod = classPod;
    _responseBlock = responseBlock;
    [self updateUI];
}

- (void) updateUI
{
    labelHeader.text = RStr(@"Edit Class Pod");
    labelName.text = RStr(@"Name:");
    textFieldName.text = self.classPod.name;
    labelNote.text = RStr(@"Note:");
    textViewNote.text = self.classPod.note;
    
#warning Don't edit teacher??
    viewTeacher.alpha = 0.5;    
    textFieldCourseName.enabled = NO;
    textFieldHourRate.enabled = NO;

    labelCourseName.text = RStr(@"Course name:");
    textFieldCourseName.text = self.classPod.teacher.courseName;
    labelHourRate.text = RStr(@"Hour Rate");
    textFieldHourRate.text = [NSString stringWithFormat:@"%.2f", self.classPod.teacher.hourRate];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    NSString *text = textField.text;
    if (textField == textFieldName) {
        if (![self.classPod.name isEqualToString:text]) {
            self.classPod.name = text;
            hasChange = YES;
        }
    } if (textField == textFieldCourseName) {
        if (![self.classPod.teacher.courseName isEqualToString:text]) {
            self.classPod.teacher.courseName = text;
            hasChange = YES;
        }
    } if (textField == textFieldHourRate) {
        CGFloat rate = [text stringByReplacingOccurrencesOfString:@"," withString:@"."].floatValue;
        if (self.classPod.teacher.hourRate != rate) {
            self.classPod.teacher.hourRate = text.floatValue;
            hasChange = YES;
        }
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (textView == textViewNote) {
        NSString *text =  textView.text;
        if (![self.classPod.note isEqualToString:text]) {
            self.classPod.note = text;
            hasChange = YES;
        }
    }
}

- (IBAction) closePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.responseBlock) {
            self.responseBlock(hasChange);
        }
    }];
}


@end
