//
//  Preferences.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#ifndef Preferences_h
#define Preferences_h

//extern NSString * const REQUEST_URL;

@interface Preferences : NSObject

+ (Preferences *) sharedPreferences;
- (void) flush;

//@property (nonatomic, retain) NSString *audioDevice;

@end

#endif // Preferences_h
