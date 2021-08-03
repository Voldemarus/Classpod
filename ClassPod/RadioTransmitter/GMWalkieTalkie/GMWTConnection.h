//
//  GMWTConnection.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 03.08.2021.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#import "GMMultiPeer.h"

@class GMWTConnection;

@protocol GMWTConnectionDelegate <NSObject>

@optional

- (void)connection:(GMWTConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionIsConnecting:(GMWTConnection *)connection;
- (void)connectionDidConnect:(GMWTConnection *)connection;
- (void)connectionDidDisconnect:(GMWTConnection *)connection;
- (void)connectionDidReceiveCall:(GMWTConnection *)connection;

@end

NS_ASSUME_NONNULL_BEGIN

@interface GMWTConnection : NSObject    <GMMultipeerDelegate>


//@property (nonatomic, assign) id<BWConnectionDelegate> delegate;
@property (nonatomic, copy) NSString *remotePeerID;
@property (nonatomic, getter = isConnected) BOOL connected;
@property (nonatomic, retain) MCPeerID *otherPeer;
@property (nonatomic, retain) MCSession *chatSession;
@property (nonatomic, retain) GKVoiceChat *voicechat;

+ (id)connection;

- (void)connect;
- (void)disconnect;
- (void)answerIncomingCall;
- (void)denyIncomingCall;
- (MCSession *)createChatSession;


@end

NS_ASSUME_NONNULL_END
