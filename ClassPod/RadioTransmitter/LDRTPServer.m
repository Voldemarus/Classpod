//
//  LDRTPServer.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 27.05.2021.
//

#import "LDRTPServer.h"
#import "AVFoundation/AVCaptureSession.h"
//#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureOutput.h"
#include <sys/socket.h>
#include <netinet/in.h>
#import "ifaddrs.h"
#import "arpa/inet.h"

@interface LDRTPServer()
<AVCaptureAudioDataOutputSampleBufferDelegate,
NSStreamDelegate>
{
    BOOL isConnect;
    AVCaptureSession * m_capture;
    NSInputStream * iStream;
    NSOutputStream * oStream;
    NSMutableData * globalData;
}

@end

@implementation LDRTPServer

+ (LDRTPServer *) sharedRTPServer
{
    static LDRTPServer * __obj = nil;
    if (!__obj) {
        __obj = [[LDRTPServer alloc] init];
    }
    return __obj;
}

- (instancetype) init
{
    if (self = [super init]) {
        //
    }
    return self;
}

- (void) open
{
    NSError *error;
    m_capture = [[AVCaptureSession alloc] init];
    AVCaptureDevice *audioDev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (audioDev == nil) {
        printf("Couldn't create audio capture device");
        return ;
    }
    //m_capture.sessionPreset = AVCaptureSessionPresetLow;
    
    // create mic device
    AVCaptureDeviceInput *audioIn = [AVCaptureDeviceInput deviceInputWithDevice:audioDev error:&error];
    if (error != nil) {
        printf("Couldn't create audio input");
        return ;
    }
    
    
    // add mic device in capture object
    if ([m_capture canAddInput:audioIn] == NO) {
        printf("Couldn't add audio input");
        return ;
    }
    [m_capture addInput:audioIn];
    // export audio data
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    if ([m_capture canAddOutput:audioOutput] == NO) {
        printf("Couldn't add audio output");
        return ;
    }
    
    
    [m_capture addOutput:audioOutput];
    [audioOutput connectionWithMediaType:AVMediaTypeAudio];
    [m_capture startRunning];
    return ;
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
//    DLog(@"sizeof(sampleBuffer) = %lu", sizeof(sampleBuffer));
#warning ENCODE need h.264?
    // MARK: - Надо закодировать сжать и отправить сжатое а не поток PCM
    char szBuf[450];
    int  nSize = sizeof(szBuf);

    if (isConnect == YES) {
//        if ([self encoderAAC:sampleBuffer aacData:szBuf aacLen:&nSize] == YES) {
            [self sendAudioData:szBuf len:nSize channel:0];
//        }

    }
}

- (void) initialSocketPort:(UInt32) port 
{
    //Use socket

    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    
    NSString *ip = [self getIPAddress]; // @"192.168.1.167";   //Your IP Address
//    UInt32 * port = 22133;
//    UInt32 port = 22133;

    DLog("initialSocket ip:%@, port:%u", ip, (unsigned int)port);

    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)ip, port, &readStream,  &writeStream);
    if (readStream && writeStream) {
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        
        iStream = (__bridge NSInputStream *)readStream;
        [iStream setDelegate:self];
        [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [iStream open];
        
        oStream = (__bridge NSOutputStream *)writeStream;
        [oStream setDelegate:self];
        [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [oStream open];
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    DLog(@"stream: %ld, eventCode:%ld", aStream.streamStatus, eventCode);
}

- (void) sendAudioData: (char *)buffer len:(int)len channel:(UInt32)channel
{
    Float32 *frame = (Float32*)buffer;
    [globalData appendBytes:frame length:len];
    
    if (isConnect == YES) {
        if ([oStream streamStatus] == NSStreamStatusOpen) {
            [oStream write:globalData.mutableBytes maxLength:globalData.length];
            
            
            globalData = [[NSMutableData alloc] init];
            
        }
    }
    
}

- (NSString*) getIPAddress
{
    return [self.class getIPAddress];
}
+ (NSString*) getIPAddress
{
    NSString* address;
    struct ifaddrs *interfaces = nil;
    
    // get all our interfaces and find the one that corresponds to wifi
    if (!getifaddrs(&interfaces))
    {
        for (struct ifaddrs* addr = interfaces; addr != NULL; addr = addr->ifa_next)
        {
            if (([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:@"en0"]) &&
                (addr->ifa_addr->sa_family == AF_INET))
            {
                struct sockaddr_in* sa = (struct sockaddr_in*) addr->ifa_addr;
                address = [NSString stringWithUTF8String:inet_ntoa(sa->sin_addr)];
                break;
            }
        }
    }
    freeifaddrs(interfaces);
    return address;
}

@end
