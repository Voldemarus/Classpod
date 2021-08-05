//
//  GMAudioRecorder.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 05.08.2021.
//

#import "GMAudioRecorder.h"
#import "DebugPrint.h"

//
// See https://arvindhsukumar.medium.com/using-avaudioengine-to-record-compress-and-stream-audio-on-ios-48dfee09fde4
//

#define GMRECORDER_BUFFER_SIZE      4096

@interface GMAudioRecorder ()

@property (nonatomic, retain) AVAudioEngine *engine;
@property (nonatomic, retain) AVAudioMixerNode *mixerNode;
@property (nonatomic, retain) NSOutputStream *outStream;

@end

@implementation GMAudioRecorder

- (instancetype) init
{
    if (self = [super init]) {
        self.state = GMRecorderStateStopped;

        if ([self setupSession]) {
            [self setupEngine];
        } else
            return nil;
    }
    return self;
}

- (BOOL) setupSession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        DLog(@"Cannot tune AudioSession - %@", [error localizedDescription]);
        return NO;
    }
    [session setMode:AVAudioSessionModeVoiceChat error:&error];
    if (error) {
        DLog(@"Cannot set VOIP mode for AudioSession - %@", [error localizedDescription]);
        return NO;
    }
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        DLog(@"Cannot activate AudioSession - %@", [error localizedDescription]);
        return NO;
    }
//    // Request permissions
//    [audioSession requestRecordPermission:^(BOOL granted) {
//        if (granted) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.view makeToast:@"Access to microphione granted"];
//                // now we can proceed with audio dreaming
//                NSDictionary *settings = @{
//                    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
//                    AVSampleRateKey: @12000,
//                    AVNumberOfChannelsKey: @1,
//                    AVEncoderAudioQualityKey: @(AVAudioQualityMedium)
//                };
//
//            });
//        }
//    }];
    return YES;
}

- (BOOL) setupEngine
{
    self.engine = [[AVAudioEngine alloc] init];
    self.mixerNode = [[AVAudioMixerNode alloc] init];
    if (!self.engine || !self.mixerNode) {
        return NO;
    }
    // Ad mixer to engine
    [self.engine attachNode:self.mixerNode];
    // And tune all connections in the mixer
    [self makeConnections];
    // Now prepare engine for work
    [self.engine prepare];
    return YES;
}

/**
        inputNode --> mixerNode --> engine.mainMixerNode -- --> AVAudioOutputNode

 */
- (void) makeConnections
{
    AVAudioInputNode *inputNode =  self.engine.inputNode;
    AVAudioFormat *format = [inputNode outputFormatForBus:0];
    [self.engine connect:inputNode to:self.mixerNode format:format];

    AVAudioMixerNode *mainMixer = self.engine.mainMixerNode;
    // Use mono (single channel to keep traffic modest
    AVAudioFormat *mixerFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32 sampleRate:format.sampleRate channels:1 interleaved:NO];
    [self.engine connect:self.mixerNode to:mainMixer format:mixerFormat];
}

#pragma mark -

- (BOOL) startRecordingToFile:(NSURL *)file
{
    NSAssert(file, @"Should be nonnull");
    AVAudioNode  *tapNode = self.mixerNode;
    AVAudioFormat *format = [tapNode outputFormatForBus:0];
    NSError *error = nil;
    AVAudioFile *aFile = [[AVAudioFile alloc] initForWriting:file settings:format.settings error:&error];
    if (error) {
        DLog(@"Cannot create ffile for spund recording - %@", [error localizedDescription]);
        return NO;
    }
    [tapNode installTapOnBus:0 bufferSize:GMRECORDER_BUFFER_SIZE format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        NSError *err = nil;
        [aFile writeFromBuffer:buffer error:&err];
        if (err) {
            DLog(@"Error during writing to audio file - %@",[error localizedDescription]);
        }
    }];
    [self.engine startAndReturnError:&error];
    if (error) {
        DLog(@"Cannot start audioEngine - %@",[error localizedDescription]);
        return NO;
    }
    self.state = GMRecorderStateRecording;
    return YES;
}

- (BOOL) startRecording:(NSOutputStream *)stream
{
    NSAssert(stream,@"Output stream should be set!");
    self.outStream = stream;

    AVAudioNode  *tapNode = self.mixerNode;
    AVAudioFormat *format = [tapNode outputFormatForBus:0];
    [tapNode installTapOnBus:0 bufferSize:GMRECORDER_BUFFER_SIZE format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        // processing after installtion is finished



    }];
    NSError *error = nil;
    [self.engine startAndReturnError:&error];
    if (error) {
        DLog(@"Cannot start audioEngine - %@",[error localizedDescription]);
        return NO;
    }
    self.state = GMRecorderStateRecording;
   return YES;
}

- (BOOL) resumeRcording
{
    NSError *error = nil;
    [self.engine startAndReturnError:&error];
    if (error) {
        DLog(@"Cannot resume Recorder - %@",[error localizedDescription]);
        return NO;
    }
    return YES;
}

- (void) pause
{
    [self.engine pause];
    self.state = GMRecorderStatePaused;
}

- (void) stop
{
    [self.engine stop];
    self.state = GMRecorderStateStopped;
}


@end
