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

NSString * const VVVteacherModeON           =   @"VVVteacherModeON";
NSString * const VVVaudioTeacherON          =   @"VVVaudioTeacherON";
NSString * const VVVaudioPersonalON         =   @"VVVaudioPersonalON";
NSString * const VVVUUID                    =   @"vvv3";

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
    [defaultValues setObject:@(1) forKey:VVVaudioTeacherON];
    [defaultValues setObject:@(1) forKey:VVVaudioPersonalON];

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

- (NSUUID *) personalUUID
{
    static NSUUID *uuid = nil;
    if (!uuid) {
        NSString *uud  = [prefs objectForKey:VVVUUID];
        if (uud) {
            // pickup uuid from the storage
            uuid = [[NSUUID alloc] initWithUUIDString:uud];
        } else {
            // no uuid is created yet, create it and store in
            // defaults
            uuid = [NSUUID UUID];
            [prefs setObject:uuid.UUIDString forKey:VVVUUID];
            [prefs synchronize];
        }
    }
    return uuid;
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

- (BOOL) audioTeacherON
{
    return [prefs boolForKey:VVVaudioTeacherON];
}
- (void) setAudioTeacherON:(BOOL)audioTeacherON
{
    [prefs setBool:audioTeacherON forKey:VVVaudioTeacherON];
    [self flush];
}

- (BOOL) audioPersonalON
{
    return [prefs boolForKey:VVVaudioPersonalON];
}
- (void) setAudioPersonalON:(BOOL)audioPersonalON
{
    [prefs setBool:audioPersonalON forKey:VVVaudioPersonalON];
    [self flush];
}

@end
