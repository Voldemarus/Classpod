//
//  RadioTransmitter.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 22.05.2021.
//

#import <Foundation/Foundation.h>
#import <PubNub/PubNub.h>

NS_ASSUME_NONNULL_BEGIN

@interface RadioTransmitter : NSObject


+ (RadioTransmitter *) sharedTransmitter;

@property (nonatomic, retain) NSMutableSet *channels;

- (void) addchannel:(NSString *)name;


@end

NS_ASSUME_NONNULL_END
