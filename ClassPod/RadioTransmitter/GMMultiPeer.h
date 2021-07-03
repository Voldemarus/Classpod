//
//  GMMultiPeer.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 02.07.2021.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

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

@end

NS_ASSUME_NONNULL_END
