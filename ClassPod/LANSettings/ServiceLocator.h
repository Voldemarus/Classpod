//
//  ServiceLocator.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 05.05.2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServiceLocator : NSObject

+ (ServiceLocator *) sharedInstance;

/**
    YEs if this device is originator of service
 */
@property (nonatomic) BOOL classProvider;

@end

NS_ASSUME_NONNULL_END
