//
//  GMMultiPeer.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 02.07.2021.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>


/**
    Notification sent when list of subscribers is updated
 */
extern NSString * _Nonnull const GMMultipeerSubscribesUpdated;

/**
 Notification is sent if peer is switched off
 */
extern NSString * _Nonnull const GMMultipeerSubscribesRemoved;

/**
    Notification is sent when advertiser invited by remote client
 */
extern NSString * _Nonnull const GMMultipeerInviteAccepted;

/**
    Notificztion sent if advertiser cannot be initialised
 */
extern NSString *  _Nonnull const GMMultiPeerAdvertiserFailed;


/**
    Notification sent when connection between peers is established
 */
extern NSString * _Nonnull const GMMultipeerSessionConnected;

/**
    Notification sent when connection is in the progress
 */

extern NSString * _Nonnull const GMMultipeerSessionConnecting;

/**
    Notification sent when connection is over or failed
 */
extern NSString * _Nonnull const GMMultipeerSessionNotConnected;


@protocol  GMMultipeerDelegate <NSObject>

@optional
/**
 Provide initial set of data as NSDictionary to be sent to student when connection is established
 */
- (NSDictionary *_Nullable) session:(MCSession * _Nonnull)session
              initialPacketForPeer:(MCPeerID *_Nonnull) peer;

/**
        provides hook to process data, received from the connected peer
 */
- (void) session:(MCSession * _Nonnull)session processReceivedData:(NSDictionary * _Nonnull) data;

@end


NS_ASSUME_NONNULL_BEGIN

@interface GMMultiPeer : NSObject

/** Teacher mode  constructor*/
- (instancetype) initWithLessonName:(NSString *)lessonName;
/** Student mode constructor */
- (instancetype) initWithStudentsName:(NSString *)aName;


- (MCSession *) chatSession;

/**
 Requst from the lesson to acquire particular lesson bt ID

 */
- (void) invitePeer:(MCPeerID *) lessonPeer;

/**
    Stop multipeering, release all connections
 */
- (void) stop;


/**
 Teacher mode only.
 set to YES to start adevertise lesson, and to NO - to stop advertising
 */
@property (nonatomic) BOOL advertiseStatus;

/**
    Student mode only. Set to YES to allow browsing of remote lessons, NO, to stop.
 */
@property (nonatomic) BOOL browsingStatus;


@property (nonatomic, assign) id <GMMultipeerDelegate> delegate;

/**
    List of the subscribers
 */
@property (nonatomic, retain) NSMutableSet <MCPeerID *> *subscribers;


@property (nonatomic, retain) NSString *avatarName;


@end

NS_ASSUME_NONNULL_END
