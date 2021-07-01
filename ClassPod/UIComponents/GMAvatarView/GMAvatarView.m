//
//  GMAvatarView.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 01.07.2021.
//

#import "GMAvatarView.h"
#import "UIColor+ColorHex.h"


#define GMAvatarViewDefaultColor @"BBCCFF"
#define GMAvatarViewDefaultWidth 2.5


@implementation GMAvatarView

- (instancetype) init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype) initWithImage:(UIImage *)image
{
    if (self = [super initWithImage:image]) {
        [self commonInit];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)coder
{
    if (self == [super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype) initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    if (self = [super initWithImage:image highlightedImage:highlightedImage]) {
        [self commonInit];
    }
    return self;
}

// set up default parameters;
- (void) commonInit
{
    self.borderWidth = GMAvatarViewDefaultWidth;
    self.borderColor = [UIColor colorWithHexString:GMAvatarViewDefaultColor];
}

- (void) setImage:(UIImage *)aImage
{
    super.image = aImage;
    self.autoresizingMask = UIViewAutoresizingNone;
    // Resize frame if it is not square
    CGFloat width = MIN(self.frame.size.width, self.frame.size.height);
    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = width;
    self.frame = frame;
    // Now arrange border
    CALayer *l = self.layer;
    l.cornerRadius = self.frame.size.width / 2.0;
    l.borderColor = self.borderColor.CGColor;
    l.borderWidth = self.borderWidth;
}


@end
