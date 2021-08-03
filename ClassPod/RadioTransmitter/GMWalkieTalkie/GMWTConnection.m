//
//  GMWTConnection.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 03.08.2021.
//

#import "GMWTConnection.h"
#import "AppDelegate.h"

@implementation GMWTConnection


+ (instancetype) connection
{
    return [[GMWTConnection alloc] init];
}

- (MCPeerID *) otherPeer
{
    return [[self.chatSession connectedPeers] objectAtIndex:0];
}

- (void)connect
{
    self.voicechat = [[GKVoiceChat alloc] init];
}

- (void)disconnect
{
    // Overridden by subclasses
}

- (void)answerIncomingCall
{
    // Overridden by subclasses
}

- (void)denyIncomingCall
{
    // Overridden by subclasses
}





@end
