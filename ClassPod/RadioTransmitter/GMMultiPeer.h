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
    Notification is sent when advertiser invited by remote client
 */
extern NSString * _Nonnull const GMMultipeerInviteAccepted;


NS_ASSUME_NONNULL_BEGIN

@interface GMMultiPeer : NSObject

/** Teacher mode  constructor*/
- (instancetype) initWithLessonName:(NSString *)lessonName;
/** Student mode constructor */
- (instancetype) initWithStudentsName:(NSString *)aName;

/**
 Teacher mode only.
 set to YES to start adevertise lesson, and to NO - to stop advertising
 */
@property (nonatomic) BOOL advertiseStatus;

/**
    List of the subscribers
 */
@property (nonatomic, retain) NSMutableSet <MCPeerID *> *subscribers;


@end

NS_ASSUME_NONNULL_END
