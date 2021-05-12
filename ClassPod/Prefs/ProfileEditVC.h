//
//  ProfileEditVC.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 12.05.2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ScreenMode_Teachr = 1,
    ScreenMode_Student = 2,
} ScreenMode;

@interface ProfileEditVC : UIViewController

@property (nonatomic, readwrite) ScreenMode screenMode;

@end

NS_ASSUME_NONNULL_END
