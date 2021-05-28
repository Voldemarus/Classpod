//
//  LDRTPServer.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 27.05.2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDRTPServer : NSObject

+ (LDRTPServer *) sharedRTPServer;
- (void) open;
- (void) initialSocketPort:(UInt32) port;

@end

NS_ASSUME_NONNULL_END
