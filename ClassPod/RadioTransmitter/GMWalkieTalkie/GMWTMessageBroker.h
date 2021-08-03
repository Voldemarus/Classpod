//
//  GMWTMessageBroker.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 03.08.2021.
//

#import <Foundation/Foundation.h>
#import "GMWTMessageObject.h"

@class GMWTMessageBroker;

@protocol GMWTMessageBrokerDelegate <NSObject>

@optional
- (void)messageBroker:(GMWTMessageBroker *)server didSendMessage:(GMWTMessageObject *)message;

- (void)messageBroker:(GMWTMessageBroker *)server didReceiveMessage:(GMWTMessageObject *)message;

- (void)messageBrokerDidDisconnectUnexpectedly:(GMWTMessageBroker *)server;

@end

NS_ASSUME_NONNULL_BEGIN


@interface GMWTMessageBroker : NSObject

@end

NS_ASSUME_NONNULL_END
