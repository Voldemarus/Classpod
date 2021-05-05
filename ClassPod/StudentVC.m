//
//  StudentVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import "StudentVC.h"

@interface StudentVC ()
{
    Preferences *prefs;
}

@property (weak, nonatomic) IBOutlet UISwitch *swTeacherAudio;
@property (weak, nonatomic) IBOutlet UISwitch *swPersonalAudio;

@end

@implementation StudentVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    prefs = [Preferences sharedPreferences];
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
@end
