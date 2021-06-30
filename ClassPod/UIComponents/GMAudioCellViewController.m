//
//  GMAudioCellViewController.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 30.06.2021.
//

#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

#import "GMAudioFormView.h"
#import "UIColor+ColorHex.h"
#import "GMAudioCellViewController.h"

#define GMAudioCellTeacherBackground @"AAAAEE"
#define GMAudioCellStudentBackground @"AAEEAA"

#define GMAudioCellTeacherLine @"8888EE"
#define GMAudioCellStudentLine @"88EE88"

#define GMAudioCellCenterLine @"999999"

@interface GMAudioCellViewController () <AVAudioPlayerDelegate>
{
    NSMutableArray *dataArray;
}

@property (nonatomic, retain) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet GMAudioFormView *audioForm;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *playStopButton;

- (IBAction)playStopClicked:(id)sender;

@end

@implementation GMAudioCellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Init player
}

- (void) setAudio:(Audiochat *)audio
{
    if (_player || [_audio.uuid isEqualToString:audio.uuid] == NO) {
        // dispose old player
        _player = nil;
    }
    NSURL *url = [NSURL fileURLWithPath:audio.filename];
    NSError *error = nil;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!error) {
        [_player prepareToPlay];
        NSTimeInterval t = _player.duration;
        NSInteger min = t / 60;
        NSInteger sec = t - (min * 60);
        self.durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)min,(long)sec];
    }
}


- (void) viewDidAppear:(BOOL)animated
{
    CALayer *l = self.view.layer;
    if (self.owner == GMAudioCellOwnerTeacher) {
        l.backgroundColor = [UIColor colorWithHexString:GMAudioCellTeacherBackground].CGColor;
        self.audioForm.lineColor = [UIColor colorWithHexString:GMAudioCellTeacherLine];
    } else {
        l.backgroundColor = [UIColor colorWithHexString:GMAudioCellStudentBackground].CGColor;
        self.audioForm.lineColor = [UIColor colorWithHexString:GMAudioCellTeacherLine];
    }
    self.audioForm.centerColor = [UIColor colorWithHexString:GMAudioCellCenterLine];

    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)playStopClicked:(id)sender {
}
@end
