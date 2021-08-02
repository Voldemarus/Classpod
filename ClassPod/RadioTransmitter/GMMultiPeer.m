//
//  GMMultiPeer.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 02.07.2021.
//

#import "GMMultiPeer.h"
#import "Preferences.h"
#import "DAO.h"
#import "DebugPrint.h"

NSString * const GMMultipeerSubscribesUpdated = @"GMMultipeerSubscribesUpdated";
NSString * const GMMultipeerInviteAccepted = @"GMMultipeerInviteAccepted";
NSString * const GMMultiPeerAdvertiserFailed = @"GMMultiPeerAdvertiserFailed";
NSString * const GMMultipeerSubscribesRemoved = @"GMMultipeerSubscribesRemoved";

NSString * const SERVICE_NAME   =   @"clpodsrv";

@interface GMMultiPeer () < MCNearbyServiceAdvertiserDelegate,
                            MCNearbyServiceBrowserDelegate>
{
    MCSession *session;
    MCPeerID *peerID;
    BOOL teacherMode;
    MCNearbyServiceAdvertiser *advertiser;  /* teacher mode */
    MCNearbyServiceBrowser *browser;        /* student mode */
    BOOL _advertiseStatus;
    BOOL _browsingStatus;
}

@end

@implementation GMMultiPeer

@synthesize subscribers;

- (instancetype) initWithLessonName:(NSString *)lessonName
{
    if (self = [super init]) {
        teacherMode = YES;
        [self commonInit:lessonName];
        advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID discoveryInfo:NULL serviceType:SERVICE_NAME];
        NSAssert(advertiser,@"advertiser should be initialised");
        if (advertiser) {
            advertiser.delegate = self;
        }
    }
    return self;
}

- (instancetype) initWithStudentsName:(NSString *)aName
{
    if (self = [super init]) {
        teacherMode = NO;
        [self commonInit:aName];
        browser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID serviceType:SERVICE_NAME];
        NSAssert(browser, @"browser should be initialised");
    }
    return self;
}

- (void) commonInit:(NSString *)peerName
{
    subscribers = [[NSMutableSet alloc] initWithCapacity:7];
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

- (BOOL) browsingStatus
{
    return _browsingStatus;
}

- (void) setBrowsingStatus:(BOOL)browsingStatus
{
    if (!teacherMode && (browsingStatus != _browsingStatus)) {
        _browsingStatus = browsingStatus;
        if (_browsingStatus) {
            [browser startBrowsingForPeers];
        } else {
            [browser stopBrowsingForPeers];
        }
    }
}

#pragma mark - Actions -

/**
        Student asks to attach to lesson

 */
- (void) invitePeer:(MCPeerID *) lessonPeer
{
    if (!teacherMode) {
        // Note! use NSData in context to send user info !!!
        [browser invitePeer:lessonPeer toSession:session withContext:nil timeout:120.];
    }
}

#pragma mark - Advertiser delegate methods -

- (void) advertiser:(MCNearbyServiceAdvertiser *)advertiser
  didReceiveInvitationFromPeer:(MCPeerID *)peerID
                   withContext:(nullable NSData *)context
             invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler
{
    NSLog(@"Invitatopn received from - %@",peerID.displayName);
    // Automatically accept invitation
    invitationHandler(YES, session);
    dispatch_async(dispatch_get_main_queue(), ^{
        // And set info to pp
        [[NSNotificationCenter defaultCenter] postNotificationName:GMMultipeerInviteAccepted object:peerID];
    });
}


// Advertising did not start due to an error.
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"Cannot start adverising peer - %@",[error localizedDescription]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GMMultiPeerAdvertiserFailed object:nil];
    });
}

#pragma mark - Browser delegate methods -


- (void) browser:(MCNearbyServiceBrowser *)browser
              foundPeer:(MCPeerID *)peerID
      withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    DLog(@"Peer found - %@",peerID.displayName);
    DLog(@"Discovery info: %@",info);
    [subscribers addObject:peerID];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GMMultipeerSubscribesUpdated object:peerID];
    });
}

// A nearby peer has stopped advertising. -- Lesson has been over
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    DLog(@"Advertiser stops - %@",peerID.displayName);
    [subscribers removeObject:peerID];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GMMultipeerSubscribesRemoved object:peerID];
    });
}


// Browsing did not start due to an error.
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    DLog(@"Cannot start browser - %@", [error localizedDescription]);
}


@end
