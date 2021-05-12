//
//  TesterPreferences.h
//  ClassPodDebug
//
//  Created by Водолазкий В.В. on 12.05.2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TesterPreferences : NSObject

+ (TesterPreferences *) sharedPreferences;
- (void) flush;

@property (nonatomic, retain) NSString *studentName;
@property (nonatomic, retain) NSString *studentNote;
@property (nonatomic, readonly) NSUUID *studentUUID;
@property (nonatomic) NSUInteger testerMode;


@end

NS_ASSUME_NONNULL_END
