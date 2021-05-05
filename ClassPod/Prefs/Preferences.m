//
//  Preferences.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import "Preferences.h"


@interface Preferences ()
{
    NSUserDefaults *prefs;
}

@end

//NSString * const REQUEST_URL = @"http:/";

//NSString * const VVVappVersionReceived          =   @"VVVappVersionReceived";

@implementation Preferences

+ (Preferences *) sharedPreferences
{
    static Preferences *_Preferences;
    if (_Preferences == nil) {
        _Preferences = [[Preferences alloc] init];
    }
    return _Preferences;
}

+ (void)initialize
{
    // set up default parameters
    NSMutableDictionary  *defaultValues = [NSMutableDictionary new];
//    [defaultValues setObject:@(1) forKey:VVVappVersionReceived];

    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}

- (id) init
{
    if (self = [super init]) {
        prefs = NSUserDefaults.standardUserDefaults;
    }
    return self;
}

- (void) flush
{
    [prefs synchronize];
}

#pragma mark -


@end
