//
//  TDAudioOutputStreamer.m
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 11/14/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//  Modified for Classpod project 2021, Geomatix Laboratory ,s.r.o.
//

#import <AVFoundation/AVFoundation.h>
#import "TDAudioOutputStreamer.h"
#import "TDAudioStream.h"
#import "DebugPrint.h"

@interface TDAudioOutputStreamer () <TDAudioStreamDelegate>

@property (strong, nonatomic) TDAudioStream *audioStream;
@property (strong, nonatomic) AVAssetReader *assetReader;
@property (strong, nonatomic) AVAssetReaderTrackOutput *assetOutput;
@property (strong, nonatomic) NSThread *streamThread;

@property (assign, atomic) BOOL isStreaming;

@end

@implementation TDAudioOutputStreamer

- (instancetype) initWithOutputStream:(NSOutputStream *)stream
{
    self = [super init];
    if (!self) return nil;

    self.audioStream = [[TDAudioStream alloc] initWithOutputStream:stream];
    self.audioStream.delegate = self;
    NSLog(@"Init");

    return self;
}

- (void)start
{
    if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        return [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    }

    NSLog(@"Start");
    self.streamThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [self.streamThread start];
}

- (void)run
{
    @autoreleasepool {
        [self.audioStream open];

        self.isStreaming = YES;
        NSLog(@"Loop");

        while (self.isStreaming && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) ;

        NSLog(@"Done");
    }
}

- (void)streamAudioFromURL:(NSURL *)url loop:(BOOL)loop
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSError *assetError;

    self.assetReader = [AVAssetReader assetReaderWithAsset:asset error:&assetError];
    if (loop) {
        [asset loadValuesAsynchronouslyForKeys:@[@"tracks"]
                             completionHandler:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error = nil;
                if ([asset statusOfValueForKey:@"tracks" error:&error] == AVKeyValueStatusLoaded) {
                    [self->_assetReader startReading];
                } else {
                    if (error) {
                        DLog(@"cannot start reading - %@",[error localizedDescription]);
                    }
                    else {
                        DLog(@"cannot restart reading - no error detected");
                    }
                    return;
                }

                if (self.assetReader.status == AVAssetReaderStatusCompleted) {
                    [self.assetReader cancelReading];
                    [self streamAudioFromURL:url loop:YES];
                } else {
                    DLog(@"status - %ld",(long)self.assetReader.status);
                }
            } );  // dispatch_async
        }];    //asset loadValues
    }   //loop

    self.assetOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:asset.tracks[0] outputSettings:nil];
    if (![self.assetReader canAddOutput:self.assetOutput]) return;

    [self.assetReader addOutput:self.assetOutput];
    [self.assetReader startReading];
    NSLog(@"Read Asset");
}

- (void)sendDataChunk
{
    CMSampleBufferRef sampleBuffer;

    sampleBuffer = [self.assetOutput copyNextSampleBuffer];

    if (sampleBuffer == NULL || CMSampleBufferGetNumSamples(sampleBuffer) == 0) {
         return;
    }

    CMBlockBufferRef blockBuffer;
    AudioBufferList audioBufferList;

    OSStatus err = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(AudioBufferList), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);

    if (err) {
        CFRelease(sampleBuffer);
        return;
    }

    for (NSUInteger i = 0; i < audioBufferList.mNumberBuffers; i++) {
        AudioBuffer audioBuffer = audioBufferList.mBuffers[i];
        [self.audioStream writeData:audioBuffer.mData maxLength:audioBuffer.mDataByteSize];
        NSLog(@"buffer size: %u", (unsigned int)audioBuffer.mDataByteSize);
    }

    CFRelease(blockBuffer);
    CFRelease(sampleBuffer);
}

- (void)stop
{
    [self performSelector:@selector(stopThread) onThread:self.streamThread withObject:nil waitUntilDone:YES];
}

- (void)stopThread
{
    self.isStreaming = NO;
    [self.audioStream close];
    NSLog(@"Stop");
}

#pragma mark - TDAudioStreamDelegate

- (void)audioStream:(TDAudioStream *)audioStream didRaiseEvent:(TDAudioStreamEvent)event
{
    switch (event) {
        case TDAudioStreamEventWantsData:
            [self sendDataChunk];
            break;

        case TDAudioStreamEventError:
            // TODO: shit!
            NSLog(@"Stream Error");
            break;

        case TDAudioStreamEventEnd:
            // TODO: shit!
            NSLog(@"Stream Ended");
            break;

        default:
            break;
    }
}

@end
