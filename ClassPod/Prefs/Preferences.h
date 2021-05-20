//
//  Preferences.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#ifndef Preferences_h
#define Preferences_h

#import <Foundation/Foundation.h>

//extern NSString * const ПРИМЕР;

@interface Preferences : NSObject

+ (Preferences *) sharedPreferences;
- (void) flush;

/**
        Both for teacher and student
 */
@property (nonatomic, readonly)  NSString *personalUUID;

// Teacher profile data
@property (nonatomic, retain) NSString *myName;  // common for teacher and student
@property (nonatomic, retain) NSString *note;
@property (nonatomic) double rate;
@property (nonatomic, retain) NSString *courseName;

@property (nonatomic, readwrite) BOOL teacherModeON;
@property (nonatomic, readwrite) BOOL audioTeacherON;
@property (nonatomic, readwrite) BOOL audioPersonalON;


#ifndef MAIN_APP_IOS

// Only mac version
typedef enum : NSUInteger {
    TesterMode_Student = 0,
    TesterMode_Teacher = 1,
} TesterMode;
@property (nonatomic) TesterMode testerMode;

//@property (nonatomic, retain) NSString *studentName;
//@property (nonatomic, retain) NSString *studentNote;
//@property (nonatomic, readonly) NSString *studentUUID;

#endif

@end

#endif // Preferences_h
