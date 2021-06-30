//
//  ClassPodEditVC.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 30.06.2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClassPodEditVC : UIViewController

typedef void (^ClassPodEditVCResponseBlock)(BOOL hasChange);

- (void) setClassPod:(ClassPod *)classPod responseBlock:(ClassPodEditVCResponseBlock _Nullable)responseBlock;

@end

NS_ASSUME_NONNULL_END
