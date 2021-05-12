//
//  ViewController.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 03.05.2021.
//

#import "ViewController.h"

@interface ViewController ()
{
    Preferences *prefs;
}

@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    prefs = [Preferences sharedPreferences];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (prefs.teacherModeON) {
            [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"TeacherVC"] animated:NO completion:nil];
        } else {
//            [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"StudentVC"] animated:NO completion:nil];
        }
    });
}

@end
