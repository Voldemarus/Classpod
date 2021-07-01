//
//  GMAudioFormView.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 30.06.2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMAudioFormView : UIView

/**
        Color of the line
 */
@property (nonatomic, retain) UIColor *lineColor;

/**
        Color of X-axis
 */
@property (nonatomic, retain) UIColor *centerColor;

/**
    Path to audio file name
 */
@property (nonatomic, retain) NSString *fileName;

@end

NS_ASSUME_NONNULL_END
