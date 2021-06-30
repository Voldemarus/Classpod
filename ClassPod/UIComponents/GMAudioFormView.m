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
    NSMutableArray *dataArray;
    NSInteger totalCount;
    CGFloat xPoint;
    NSTimer *timer;
    CGFloat internalLineWidth;
    CGFloat internalLineSeperation;
    BOOL preRender;
    CGFloat width;

    UIColor *lineColor;
    UIColor *centerLine;
}

@end

@implementation GMAudioFormView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
