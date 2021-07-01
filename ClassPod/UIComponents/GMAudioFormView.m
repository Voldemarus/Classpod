//
//  GMAudioFormView.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 30.06.2021.
//

#import "GMAudioFormView.h"


@interface GMAudioFormView ()
{
    UIView *centerLineView;
    NSInteger totalCount;
    CGFloat xPoint;
    NSTimer *timer;
    CGFloat internalLineWidth;
    CGFloat internalLineSeperation;
    BOOL preRender;
    CGFloat width;

    UIColor *lineColor;
    UIColor *centerLineColor;
}

@end

@implementation GMAudioFormView

@synthesize centerColor = centerLineColor;


- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        centerLineColor = [UIColor darkGrayColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Draw centerline
    if (!centerLineView) {
        centerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.5, self.frame.size.width, 1.0)];
        centerLineView.backgroundColor = centerLineColor;
    }
}

@end
