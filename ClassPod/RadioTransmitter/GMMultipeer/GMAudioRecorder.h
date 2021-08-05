//
//  GMAudioRecorder.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 05.08.2021.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSInteger, GMRecorderState) {
    GMRecorderStateRecording,
    GMRecorderStatePaused,
    GMRecorderStateStopped,
};

NS_ASSUME_NONNULL_BEGIN

@interface GMAudioRecorder : NSObject

@property (nonatomic) GMRecorderState state;


- (BOOL) startRecording:(NSOutputStream *)stream;   // to stream
- (BOOL) startRecordingToFile:(NSURL *)file;        // to audio file

- (BOOL) resumeRcording;
- (void) pause;
- (void) stop;

@end

NS_ASSUME_NONNULL_END
