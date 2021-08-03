//
//  GMWTMessageObject.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 03.08.2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    GMMessageKindNone = 0,
    GMMessageKindVoiceCallRequest = 1,
    GMMessageKindVoiceCallRequestDenied = 2
} GMMessageKind;

@interface GMWTMessageObject : NSObject <NSCoding>

@property (nonatomic) GMMessageKind kind;
@property (nonatomic, retain) NSData *body;

@end

NS_ASSUME_NONNULL_END
