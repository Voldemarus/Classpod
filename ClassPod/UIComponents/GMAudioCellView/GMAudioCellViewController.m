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
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

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
    // Set up time label in HH:MM format;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    self.timeLabel.text = [df stringFromDate:audio.timestamp];
    self.audioForm.fileName = audio.filename;
    [self.view setNeedsDisplay];
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

- (IBAction)playStopClicked:(id)sender
{
    if (_player.isPlaying) {
        [_player pause];
    } else {
        [_player play];
    }
}

#pragma mark - AVAudioPlayer delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [player pause];
    // now rewind to initial position to repeat sound from the beginning
    // if user clicks button again
    player.currentTime = 0.0;
}


@end
