//
//  GMWTMessageObject.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 03.08.2021.
//

#import "GMWTMessageObject.h"

NSString * const GMKIND =   @"gmkind";
NSString * const GMBODY =   @"gmbody";

@implementation GMWTMessageObject

- (instancetype) init
{
    if (self = [super init]) {
        _kind = GMMessageKindNone;
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.kind = [coder decodeIntForKey:GMKIND];
        self.body = [coder decodeObjectForKey:GMBODY];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self.kind forKey:GMKIND];
    [coder encodeObject:self.body forKey:GMBODY];
}


@end
