//
//  GMAvatarView.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 01.07.2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMAvatarView : UIImageView

/**
        Size of the avatar, which is actualy a square image
 */
@property (nonatomic) CGFloat size;

@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;


@end

NS_ASSUME_NONNULL_END
