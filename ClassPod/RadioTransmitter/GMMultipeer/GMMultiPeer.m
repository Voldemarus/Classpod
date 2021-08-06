//
//  GMMultiPeer.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 02.07.2021.
//

#import <AVFoundation/AVFoundation.h>

#import "GMMultiPeer.h"
#import "Preferences.h"
#import "DAO.h"
#import "DebugPrint.h"

NSString * const GMMultipeerSubscribesUpdated = @"GMMultipeerSubscribesUpdated";
NSString * const GMMultipeerInviteAccepted = @"GMMultipeerInviteAccepted";
NSString * const GMMultiPeerAdvertiserFailed = @"GMMultiPeerAdvertiserFailed";
NSString * const GMMultipeerSubscribesRemoved = @"GMMultipeerSubscribesRemoved";
NSString * const GMMultipeerSessionConnected = @"GMMultipeerSessionConnected";
NSString * const GMMultipeerSessionConnecting = @"GMMultipeerSessionConnecting";
NSString * const GMMultipeerSessionNotConnected = @"GMMultipeerSessionNotConnected";
/**

 See https://stackoverflow.com/questions/65190065/nsnetservicebrowser-did-not-search-with-error-72008-on-ios-14

 About related record in the info.plist

 */

NSString * const SERVICE_NAME   =   @"clpodsrv";
NSString * const STREAM_TYPE_MUSIC  =   @"music";
NSString * const STREAM_TYPE_VOICE  =   @"voice";


@interface GMMultiPeer () < MCNearbyServiceAdvertiserDelegate,
                            MCNearbyServiceBrowserDelegate, MCSessionDelegate>
{
    MCPeerID *peerID;
    BOOL teacherMode;
    MCNearbyServiceAdvertiser *advertiser;  /* teacher mode */
    MCNearbyServiceBrowser *browser;        /* student mode */
    BOOL _advertiseStatus;
    BOOL _browsingStatus;
    NSMutableSet <MCPeerID *> *connectedToTeacherStudent;
}

@property (nonatomic, retain) AVAssetReader *assetReader;
@property (nonatomic, retain) AVAssetReaderTrackOutput *assetOutput;
@property (nonatomic, retain)  MCSession *session;
@end

@implementation GMMultiPeer

@synthesize subscribers;
@synthesize session = session;

- (instancetype) initWithLessonName:(NSString *)lessonName
{
    if (self = [super init]) {
        teacherMode = YES;
        connectedToTeacherStudent = [NSMutableSet new];
        [self commonInit:lessonName];
        advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID discoveryInfo:NULL serviceType:SERVICE_NAME];
        NSAssert(advertiser,@"advertiser should be initialised");
        if (advertiser) {
            advertiser.delegate = self;
        }
    }
    return self;
}

- (MCSession *) chatSession
{
    return self.session;
}

- (NSArray <MCPeerID *> *) connectedStudents
{
    return connectedToTeacherStudent.allObjects;
}

- (instancetype) initWithStudentsName:(NSString *)aName
{
    if (self = [super init]) {
        teacherMode = NO;
        [self commonInit:aName];
        browser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID serviceType:SERVICE_NAME];
        browser.delegate = self;
        NSAssert(browser, @"browser should be initialised");
    }
    return self;
}

- (void) commonInit:(NSString *)peerName
{
    subscribers = [[NSMutableSet alloc] initWithCapacity:7];
    self.avatarName = peerName;
    peerID = [[MCPeerID alloc] initWithDisplayName:self.avatarName];
    NSAssert(peerID, @"Peer OD should be initialised");
    session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil
                         encryptionPreference:MCEncryptionNone];
    session.delegate = self;
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

- (void) stop
{
    if (teacherMode) {
        self.advertiseStatus = NO;
    } else {
        self.browsingStatus = NO;
    }
    [session disconnect];
}

//
// https://thoughtbot.com/blog/streaming-audio-to-multiple-listeners-via-ios-multipeer-connectivity
//
- (BOOL) startStreaming:(NSURL *)mediaURL toPeers:(NSArray <MCPeerID *> *)peers
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mediaURL options:nil];
    self.assetReader = [AVAssetReader assetReaderWithAsset:asset error:nil];
    AVAssetReaderTrackOutput *assetOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:asset.tracks[0] outputSettings:nil];

    [self.assetReader addOutput:self.assetOutput];
    [self.assetReader startReading];

    return NO;
}

- (void) stopStreaming
{
    [self.assetReader cancelReading];
}


- (NSOutputStream *)startOutputMusicStreamForPeer:(MCPeerID *)peer
{
    NSError *error;
    NSOutputStream *stream = [self.session startStreamWithName:STREAM_TYPE_MUSIC
                                                        toPeer:peer error:&error];
    if (error) {
        DLog(@"Error: %@", [error userInfo].description);
    }

    return stream;
}

- (NSOutputStream *)startOutputVoiceStreamForPeer:(MCPeerID *)peer
{
    NSError *error;
    NSOutputStream *stream = [self.session startStreamWithName:STREAM_TYPE_VOICE
                                                        toPeer:peer error:&error];
    if (error) {
        DLog(@"Error: %@", [error userInfo].description);
    }

    return stream;
}



#pragma mark - Helpers -

/**
    Converts dictionary into JSON packet, suitable to be send through the MCPSession
 */
- (NSData *) dataFromDictionary:(NSDictionary *)dict
{
    NSJSONWritingOptions options = kNilOptions;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:options error:&error];
    if (error) {
        DLog(@"Error during JSON serialisation - %@", [error localizedDescription]);
        return nil;
    }
    return data;
}

/**
        Unpacks data packet in JSON format to  NSDictionary object
 */
- (NSDictionary *) dictionaryFromData:(NSData *)data
{
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        DLog(@"Error during JSON serialisation - %@", [error localizedDescription]);
        return nil;
    }
    DLog(@"Received packet - %@",dict);
    return dict;
}


#pragma mark - Advertiser delegate methods -

- (void) advertiser:(MCNearbyServiceAdvertiser *)advertiser
  didReceiveInvitationFromPeer:(MCPeerID *)peerID
                   withContext:(nullable NSData *)context
             invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler
{
    NSLog(@"Invite received from - %@",peerID.displayName);
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

#pragma mark - MCSesionDelegate -

// Remote peer changed state.
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSString *notification = nil;
    NSError *error = nil;
    switch (state) {
        case MCSessionStateConnected:
            if (self->teacherMode) {
                //
                // In teacher mode we can set up intial packet which should be sent to student 
                //
                if (self.delegate && [self.delegate respondsToSelector:@selector(session:initialPacketForPeer:)] ) {
                    NSDictionary *dict = [self.delegate session:session initialPacketForPeer:peerID];
                    if (dict) {
                        NSData *lessonData = [self dataFromDictionary:dict];
                        if (lessonData) {
                            [session sendData:lessonData toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
                        }
                    }
                }
                if (error) {
                    DLog(@"error during sending data - %@",[error localizedDescription]);
                } else {
                    [connectedToTeacherStudent addObject:peerID];
                }
            } else {
                // connected to advertiser
                notification = GMMultipeerSessionConnected;
            }
            break;
        case MCSessionStateNotConnected:     // Not connected to the session.
            if (teacherMode) {
                [connectedToTeacherStudent removeObject:peerID];
            } else {
                notification = GMMultipeerSessionNotConnected;
            }
            break;
        case MCSessionStateConnecting:       // Peer is connecting to the session.
            if (teacherMode) {

            } else {
                notification = GMMultipeerSessionConnecting;
            }
            break;
        default:
            break;
    }
    if (notification) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [nc postNotificationName:notification object:peerID];
        });
    }
}

// Received data from remote peer.
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSDictionary *dict = [self dictionaryFromData:data];
    if (dict && self.delegate && [self.delegate respondsToSelector:@selector(session:processReceivedData:)]) {
            [self.delegate session:session processReceivedData:dict];
    }
}

// Received a byte stream from remote peer.
- (void)    session:(MCSession *)session
   didReceiveStream:(NSInputStream *)stream
           withName:(NSString *)streamName
           fromPeer:(MCPeerID *)peerID
{
    DLog(@"streamname - %@", streamName);
    if (!self.delegate) {
        DLog(@"Not supported!");
        return;
    }
    if ([streamName isEqualToString:STREAM_TYPE_MUSIC]) {
        if ([self.delegate respondsToSelector:@selector(session:didReceiveMusicStream:)]) {
            [self.delegate session:session didReceiveMusicStream:stream];
       }
    } else if ([streamName isEqualToString:STREAM_TYPE_VOICE]) {
        if ([self.delegate respondsToSelector:@selector(session:didReceiveVoiceStream:)]) {
            [self.delegate session:session didReceiveVoiceStream:stream];
        }
    }
}

// Start receiving a resource from remote peer.
- (void)  session:(MCSession *)session
  didStartReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                       withProgress:(NSProgress *)progress
{
    DLog(@"resource - %@",resourceName);
}

// Finished receiving a resource from remote peer and saved the content
// in a temporary location - the app is responsible for moving the file
// to a permanent location within its sandbox.
- (void)  session:(MCSession *)session
 didFinishReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                              atURL:(nullable NSURL *)localURL
                          withError:(nullable NSError *)error
{
    DLog(@"resource - %@",resourceName);
    DLog(@"error - %@",[error localizedDescription]);
}


// Made first contact with peer and have identity information about the
// remote peer (certificate may be nil).
- (void)        session:(MCSession *)session
  didReceiveCertificate:(nullable NSArray *)certificate
               fromPeer:(MCPeerID *)peerID
     certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    certificateHandler(YES);
}


@end
