//
//  LDAudioServer.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 02.07.2021.
//

#import "LDAudioServer.h"

#define kOutputBus 0
#define kInputBus 1

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {

    // TODO: Use inRefCon to access our interface object to do stuff
    // Then, use inNumberFrames to figure out how much data is available, and make
    // that much space available in buffers in an AudioBufferList.

    LDAudioServer *server = (__bridge LDAudioServer*)inRefCon;

    AudioBufferList bufferList;

    SInt16 samples[inNumberFrames]; // A large enough size to not have to worry about buffer overrun
    memset (&samples, 0, sizeof (samples));

    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = samples;
    bufferList.mBuffers[0].mNumberChannels = 1;
    bufferList.mBuffers[0].mDataByteSize = inNumberFrames*sizeof(SInt16);

    // Then:
    // Obtain recorded samples

    OSStatus status;

    status = AudioUnitRender(server.audioUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             &bufferList);

    NSData *dataToSend = [NSData dataWithBytes:bufferList.mBuffers[0].mData length:bufferList.mBuffers[0].mDataByteSize];
    [server writeDataToClients:dataToSend];

    return noErr;
}

@implementation LDAudioServer


//-(id) init
- (id) initWithSocketPort:(UInt32) port
{
    if (self = [super init]) {
        _port = port;
    }
    return self;
}

-(void) start
{

    [UIApplication sharedApplication].idleTimerDisabled = YES;
    // Create a new instance of AURemoteIO

    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;

    AudioComponent comp = AudioComponentFindNext(NULL, &desc);
    AudioComponentInstanceNew(comp, &_audioUnit);

    //  Enable input and output on AURemoteIO
    //  Input is enabled on the input scope of the input element
    //  Output is enabled on the output scope of the output element

    UInt32 one = 1;
    AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one));

    AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &one, sizeof(one));

    // Explicitly set the input and output client formats
    // sample rate = 44100, num channels = 1, format = 32 bit floating point

    AudioStreamBasicDescription audioFormat = [self getAudioDescription];
    AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &audioFormat, sizeof(audioFormat));
    AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &audioFormat, sizeof(audioFormat));

    // Set the MaximumFramesPerSlice property. This property is used to describe to an audio unit the maximum number
    // of samples it will be asked to produce on any single given call to AudioUnitRender
    UInt32 maxFramesPerSlice = 4096;
    AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(UInt32));

    // Get the property value back from AURemoteIO. We are going to use this value to allocate buffers accordingly
    UInt32 propSize = sizeof(UInt32);
    AudioUnitGetProperty(_audioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, &propSize);


    AURenderCallbackStruct renderCallback;
    renderCallback.inputProc = recordingCallback;
    renderCallback.inputProcRefCon = (__bridge void *)(self);

    AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0, &renderCallback, sizeof(renderCallback));


    // Initialize the AURemoteIO instance
    AudioUnitInitialize(_audioUnit);

    AudioOutputUnitStart(_audioUnit);

    _connectedClients = [[NSMutableArray alloc] init];
    _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

    [self startAcceptingConnections];
}

- (AudioStreamBasicDescription)getAudioDescription {
    AudioStreamBasicDescription audioDescription = {0};
    audioDescription.mFormatID          = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags       = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian;
    audioDescription.mChannelsPerFrame  = 1;
    audioDescription.mBytesPerPacket    = sizeof(SInt16)*audioDescription.mChannelsPerFrame;
    audioDescription.mFramesPerPacket   = 1;
    audioDescription.mBytesPerFrame     = sizeof(SInt16)*audioDescription.mChannelsPerFrame;
    audioDescription.mBitsPerChannel    = 8 * sizeof(SInt16);
    audioDescription.mSampleRate        = 44100.0;
    return audioDescription;
}

-(void) startAcceptingConnections
{
    DLog(@"🐜 startAcceptingConnections _serverSocket=%@", _serverSocket);
    NSError *error = nil;
    if(_serverSocket)
        [_serverSocket acceptOnPort:self.port error:&error];
}


-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if(_connectedClients)
        [_connectedClients removeObject:sock];
}

- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {

    NSLog(@"Accepted New Socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);

    @synchronized(_connectedClients)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_connectedClients)
                [_connectedClients addObject:newSocket];
        });
    }

    NSError *error = nil;
    if(_serverSocket)
        [_serverSocket acceptOnPort:self.port error:&error];
}

-(void) writeDataToClients:(NSData *)data
{
    if(_connectedClients)
    {
        for (GCDAsyncSocket *socket in _connectedClients) {
            if([socket isConnected])
            {
                [socket writeData:data withTimeout:-1 tag:0];
            }
            else{
                if([_connectedClients containsObject:socket])
                    [_connectedClients removeObject:socket];
            }
        }
    }
}

-(void) stop
{
    if(_serverSocket)
    {
        _serverSocket = nil;
    }
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    AudioOutputUnitStop(_audioUnit);
}

-(void) dealloc
{
    if(_serverSocket)
    {
        _serverSocket = nil;
    }
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    AudioOutputUnitStop(_audioUnit);
}

@end
