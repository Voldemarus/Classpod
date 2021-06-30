//
//  GMAudioCellViewController.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 30.06.2021.
//

#import <UIKit/UIKit.h>

#import "DAO.h"


NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, GMAudioCellOwner) {
    GMAudioCellOwnerTeacher = 0,
    GMAudioCellOwnerStudent,
};

@interface GMAudioCellViewController : UIViewController

@property (nonatomic) GMAudioCellOwner owner;
@property (nonatomic, retain) Audiochat *audio;

@end

NS_ASSUME_NONNULL_END
