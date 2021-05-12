//
//  TesterPreferences.m
//  ClassPodDebug
//
//  Created by Водолазкий В.В. on 12.05.2021.
//

#import "TesterPreferences.h"

@interface TesterPreferences ()
{
    NSUserDefaults *prefs;
}

@end

NSString * const VVVteacherModeON           =   @"vvv0";
NSString * const VVVStudentName             =   @"vvv1";
NSString * const VVVstudentNote             =   @"vvv2";
NSString * const VVVUUID                    =   @"vvv3";

@implementation TesterPreferences

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

    [defaultValues setObject:@"" forKey:VVVStudentName];
    [defaultValues setObject:@"" forKey:VVVstudentNote];
    [defaultValues setObject:@0 forKey:VVVteacherModeON];

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

- (NSString *) studentName
{
    return [prefs objectForKey:VVVStudentName];
}

- (void) setStudentName:(NSString *)studentName
{
    [prefs setObject:studentName forKey:VVVStudentName];
}

- (NSString *) studentNote
{
    return [prefs objectForKey:VVVstudentNote];
}

- (void) setStudentNote:(NSString *)studentNote
{
    [prefs setObject:studentNote forKey:VVVstudentNote];
}

- (NSUInteger) testerMode
{
    return [prefs integerForKey:VVVteacherModeON];
}

- (void) setTesterMode:(NSUInteger)testerMode
{
    [prefs setInteger:testerMode forKey:VVVteacherModeON];
}


- (NSUUID *) studentUUID
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




@end
