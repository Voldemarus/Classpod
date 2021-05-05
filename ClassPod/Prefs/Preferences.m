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

NSString * const VVVteacherModeON          =   @"VVVteacherModeON";

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
    
    [defaultValues setObject:@(0) forKey:VVVteacherModeON];

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

- (BOOL) teacherModeON
{
    return [prefs boolForKey:VVVteacherModeON];
}
- (void) setTeacherModeON:(BOOL)teacherModeON
{
    [prefs setBool:teacherModeON forKey:VVVteacherModeON];
    [self flush];
}

@end
