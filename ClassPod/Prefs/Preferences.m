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
NSString * const VVVname                    =   @"vvv4";
NSString * const VVVrate                    =   @"vvv5";
NSString * const VVVcourse                  =   @"vvv6";
NSString * const VVVnote                    =   @"vvv7";

#ifndef MAIN_APP_IOS

// Only mac version
NSString * const VVVMACteacherModeON           =   @"vvvm0";
//NSString * const VVVStudentName             =   @"vvvm1";
//NSString * const VVVstudentNote             =   @"vvvm2";
//NSString * const VVVstudentUUID             =   @"vvvm3";

#endif


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
    [defaultValues setObject:@50 forKey:VVVrate];
    [defaultValues setObject:@"" forKey:VVVname];
    [defaultValues setObject:@"" forKey:VVVcourse];
    [defaultValues setObject:@"" forKey:VVVnote];

#ifndef MAIN_APP_IOS

// Only mac version
//    [defaultValues setObject:@"" forKey:VVVStudentName];
//    [defaultValues setObject:@"" forKey:VVVstudentNote];
    [defaultValues setObject:@(0) forKey:VVVMACteacherModeON];

#endif
    
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

- (NSString *) personalUUID
{
    static NSString *uuid = nil;
    if (!uuid) {
        uuid  = [prefs objectForKey:VVVUUID];
        if (uuid.length < 1) {
            // no uuid is created yet, create it and store in
            // defaults
            uuid = NSUUID.UUID.UUIDString;
            [prefs setObject:uuid forKey:VVVUUID];
            [prefs synchronize];
        }
    }
    return uuid;
}

#pragma mark -

- (double) rate
{
    return [prefs doubleForKey:VVVrate];
}

- (void) setRate:(double)rate
{
    [prefs setDouble:rate forKey:VVVrate];
}

- (NSString *) myName
{
    return [prefs objectForKey:VVVname];
}

- (void) setMyName:(NSString *)myName
{
    [prefs setObject:myName forKey:VVVname];
}

- (NSString *) courseName
{
    return [prefs objectForKey:VVVcourse];
}

- (void) setCourseName:(NSString *)courseName
{
    [prefs setObject:courseName forKey:VVVcourse];
}

- (NSString *) note
{
    return [prefs objectForKey:VVVnote];
}

- (void) setNote:(NSString *)note
{
    [prefs setObject:note forKey:VVVnote];
}


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

#ifndef MAIN_APP_IOS

// Only mac version

- (TesterMode) testerMode
{
    return [prefs integerForKey:VVVMACteacherModeON];
}

- (void) setTesterMode:(TesterMode)testerMode
{
    [prefs setInteger:testerMode forKey:VVVMACteacherModeON];
}

//- (NSString *) studentName
//{
//    return [prefs objectForKey:VVVStudentName];
//}
//
//- (void) setStudentName:(NSString *)studentName
//{
//    [prefs setObject:studentName forKey:VVVStudentName];
//}
//
//- (NSString *) studentNote
//{
//    return [prefs objectForKey:VVVstudentNote];
//}
//
//- (void) setStudentNote:(NSString *)studentNote
//{
//    [prefs setObject:studentNote forKey:VVVstudentNote];
//}
//
//- (NSString *) studentUUID
//{
//    static NSString *uuid = nil;
//    if (!uuid) {
//        uuid  = [prefs objectForKey:VVVstudentUUID];
//        if (uuid.length < 1) {
//            // no uuid is created yet, create it and store in
//            // defaults
//            uuid = NSUUID.UUID.UUIDString;
//            [prefs setObject:uuid forKey:VVVstudentUUID];
//            [prefs synchronize];
//        }
//    }
//    return uuid;
//}



#endif // #ifndef MAIN_APP_IOS

@end
