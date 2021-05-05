//
//  Preferences.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#ifndef Preferences_h
#define Preferences_h

//extern NSString * const ПРИМЕР;

@interface Preferences : NSObject

+ (Preferences *) sharedPreferences;
- (void) flush;

@property (nonatomic, readwrite) BOOL teacherModeON;
@property (nonatomic, readwrite) BOOL audioTeacherON;
@property (nonatomic, readwrite) BOOL audioPersonalON;
    
@end

#endif // Preferences_h
