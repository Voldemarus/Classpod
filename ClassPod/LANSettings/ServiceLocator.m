//
//  ServiceLocator.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 05.05.2021.
//

#import "ServiceLocator.h"

@interface ServiceLocator ()

@end

@implementation ServiceLocator

+ (ServiceLocator *) sharedInstance
{
    static ServiceLocator * _service = nil;
    if (!_service) {
        _service = [[ServiceLocator alloc] init];
    }
    return _service;
}

- (instancetype) init
{
    if (self = [super init]) {

    }
    return self;
}

@end
