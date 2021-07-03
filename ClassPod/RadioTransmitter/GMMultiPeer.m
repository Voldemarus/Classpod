//
//  GMMultiPeer.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 02.07.2021.
//

#import "GMMultiPeer.h"
#import "Preferences.h"

NSString * const SERVICE_NAME   =   @"ClassPod-service";

@interface GMMultiPeer () <MCNearbyServiceAdvertiserDelegate>
{
    MCSession *session;
    MCPeerID *peerID;
    BOOL teacherMode;
    MCNearbyServiceAdvertiser *advertiser;  /* teacher mode */
    MCNearbyServiceBrowser *browser;        /* student mode */
    BOOL _advertiseStatus;
}

@end

@implementation GMMultiPeer

- (instancetype) initWithLessonName:(NSString *)lessonName
{
    if (self = [super init]) {
        teacherMode = YES;
        [self commonInit:lessonName];
        advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID discoveryInfo:NULL serviceType:SERVICE_NAME];
        NSAssert(advertiser,@"advertiser should be initialised");
    }
    return self;
}

- (instancetype) initWithStudentsName:(NSString *)aName
{
    if (self = [super init]) {
        teacherMode = NO;
        [self commonInit:aName];
    }
    return self;
}

- (void) commonInit:(NSString *)peerName
{
    peerID = [[MCPeerID alloc] initWithDisplayName:peerName];
    session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    _advertiseStatus = NO;

}

- (BOOL) advertiseStatus
{
    return _advertiseStatus;
}

- (void) setAdvertiseStatus:(BOOL)advertiseStatus
{
    if (teacherMode && (advertiseStatus != _advertiseStatus)) {
        _advertiseStatus = advertiseStatus;
        if (advertiseStatus) {
            [advertiser startAdvertisingPeer];
        } else {
            [advertiser stopAdvertisingPeer];
        }
    }
}


#pragma mark - Advertiser delegate methods -

- (void) advertiser:(MCNearbyServiceAdvertiser *)advertiser
  didReceiveInvitationFromPeer:(MCPeerID *)peerID
                   withContext:(nullable NSData *)context
             invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler
{
    NSLog(@"Invite accepted from - %@",peerID.displayName);
    // Automatically accept
    invitationHandler(YES, session);
    // TODO - add Toast to inform about new student
}


// Advertising did not start due to an error.
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"Cannot start adverising peer - %@",[error localizedDescription]);
}


@end
