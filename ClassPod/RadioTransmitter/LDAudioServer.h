//
//  LDAudioServer.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 02.07.2021.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import  <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDAudioServer : NSObject <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket * serverSocket;

@property (nonatomic, strong) NSMutableArray *connectedClients;

@property (nonatomic) AudioComponentInstance audioUnit;

@property (nonatomic, readwrite) NSInteger port;

- (id) initWithSocketPort:(UInt32) port;

- (void) start;
- (void) stop;
- (void) writeDataToClients:(NSData*)data;

@end

NS_ASSUME_NONNULL_END
