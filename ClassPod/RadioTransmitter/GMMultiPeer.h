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

NS_ASSUME_NONNULL_BEGIN

@interface GMMultiPeer : NSObject

/** Teacher mode  constructor*/
- (instancetype) initWithLessonName:(NSString *)lessonName;
/** Student mode constructor */
- (instancetype) initWithStudentsName:(NSString *)aName;

/**
 Requst from the lesson to acquire particular lesson bt ID

 */
- (void) invitePeer:(MCPeerID *) lessonPeer;

/**
 Teacher mode only.
 set to YES to start adevertise lesson, and to NO - to stop advertising
 */
@property (nonatomic) BOOL advertiseStatus;

/**
    Student mode only. Set to YES to allow browsing of remote lessons, NO, to stop.
 */
@property (nonatomic) BOOL browsingStatus;


/**
    List of the subscribers
 */
@property (nonatomic, retain) NSMutableSet <MCPeerID *> *subscribers;


@end

NS_ASSUME_NONNULL_END
