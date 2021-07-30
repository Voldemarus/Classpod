//
//  TeacherModeVC.m
//  MultiPeerTest
//
//  Created by Водолазкий В.В. on 29.07.2021.
//

#import "TeacherModeVC.h"
#import "AppDelegate.h"
#import "UIView+Toast.h"

@interface TeacherModeVC ()

@property (weak, nonatomic) IBOutlet UITextField *lessonLabel;

@end

@implementation TeacherModeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)registerLessonClicked:(id)sender
{
    NSString *lessonName = self.lessonLabel.text;
    [self.lessonLabel resignFirstResponder];
    if (lessonName.length > 0) {
        AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
        d.engine = [[GMMultiPeer alloc] initWithLessonName:lessonName];

        if (d.engine) {
            [self.view makeToast:@"Lesson registered"];
        }
    }

}

@end
