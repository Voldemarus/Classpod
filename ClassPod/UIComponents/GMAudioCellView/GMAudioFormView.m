//
//  GMAudioFormView.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 30.06.2021.
//

#import "GMAudioFormView.h"
#import <AVFoundation/AVFoundation.h>

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
    NSMutableArray *dataArray;

    UIColor *lineColor;
    UIColor *centerLineColor;
}

@end

@implementation GMAudioFormView

@synthesize lineColor = lineColor;
@synthesize centerColor = centerLineColor;


- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        centerLineColor = [UIColor darkGrayColor];
        lineColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.88 alpha:1.0];
        internalLineWidth = 2.0;
        internalLineSeperation = 1.0;
        xPoint = 0.0;
    }
    return self;
}

- (void) setLineColor:(UIColor *)aLineColor
{
    lineColor = aLineColor;
    [self setNeedsDisplay];
}

- (void) setCenterColor:(UIColor *)centerColor
{
    centerLineColor = centerColor;
    [self setNeedsDisplay];
}

- (void) setFileName:(NSString *)fileName
{
    _fileName = fileName;
    [self prepareData];
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Draw centerline
    if (!centerLineView) {
        centerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.5, self.frame.size.width, 1.0)];
        centerLineView.backgroundColor = centerLineColor;
        [self addSubview:centerLineView];
    }
}


- (void) prepareData
{
    if (!_fileName) {
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:_fileName];
    NSError *error = nil;
    AVAudioFile *avf = [[AVAudioFile alloc] initForReading:url error:&error];
    if (error) {
        NSLog(@"Cannot open audiofile - %@", [error localizedDescription]);
        return;
    }
    // Get length of the file
    AVAudioFramePosition audioFileLength = avf.length;
    // And audioformat
    AVAudioFormat *format = avf.processingFormat;
    // Now we should calculate amount of readings
    NSInteger numberOfReadings = self.frame.size.width / (internalLineWidth + internalLineSeperation);
    if (numberOfReadings == 0 || audioFileLength < 1) {
        return;
    }
    AVAudioFrameCount framesize = (AVAudioFrameCount) audioFileLength / numberOfReadings;
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:framesize];
    // Process in separate queue
    dispatch_queue_t prepareDataQueue = dispatch_queue_create("PrepareAudioLine", NULL);
    dispatch_async(prepareDataQueue, ^{
        if (!self->dataArray) {
            self->dataArray = [NSMutableArray new];
        } else {
            [self->dataArray removeAllObjects];
        }
        CGFloat maxValue = 0.0;
        for (NSInteger i = 0; i < numberOfReadings; i++) {
            avf.framePosition = i * framesize;
            // trad data to buffer
            NSError *err = nil;
            [avf readIntoBuffer:buffer frameCount:framesize error:&err];
            if (error) {
                DLog(@"Error during reading into buffer - %@", [err localizedDescription]);
                return;
            }
            float *channelData = (float *)[buffer floatChannelData];
            CGFloat sum = 0.0;
            NSInteger positiveCount = 0;
            for (NSInteger k = 0; k < framesize; k++) {
                CGFloat value = *channelData++;
                if (value > 0) {
                    sum += value;
                    positiveCount++;
                }
            }
            if (positiveCount > 0) {
                sum /= positiveCount;
                if (sum < maxValue) {
                    maxValue = sum;
                }
            }
            // Add normalised average value to the output array
            [self->dataArray addObject:@(sum)];
        }
        [self generatePoints:maxValue];
        [self setNeedsDisplay]; // As soon data is prepared we should draw it
    });
}

/**
        Converts dataarray into coordinates
 */
- (void) generatePoints:(CGFloat) maxValue
{
    for (NSInteger i = 0; i < dataArray.count; i++) {
        // get reading which should be in range 0..1
        double val = [dataArray[i] doubleValue];
        // convert it into height of the bar
        double height = (val < 0.05 ? self.frame.size.height * 2.0 * val : 1.0);
        // Now estimate position of the bar
        CGFloat x = (internalLineWidth+internalLineSeperation) * i;
        CGFloat y = (self.frame.size.height - height) * 0.5;
        CAShapeLayer *barLayer = [[CAShapeLayer alloc] init];
        [self.layer addSublayer:barLayer];
        UIBezierPath *bp = [UIBezierPath bezierPath];
        [bp moveToPoint:CGPointMake(x,y)];              // move to inital point
        [bp addLineToPoint:CGPointMake(x,y+height)];    // draw vertical bar
        barLayer.path = bp.CGPath;
        barLayer.strokeColor = self.lineColor.CGColor;
        barLayer.lineWidth = internalLineWidth;
        barLayer.zPosition = 2.0;
    }
}



#pragma mark - Auxillary methods

/**
 Byte invertion for color component
 */
- (CGFloat) invertByte:(CGFloat) a
{
    return (1.0 - a) * 0.9;
}

/**
    Just clone of strange utility from the protoype
 */
- (CGFloat) heuristicInvert:(CGFloat) a
{
    if (a > 0.6 && a < 0.9) {
        return 0.7;
    } else {
        return (1.0 - a);
    }
}


/**
    Color inversion
 */
- (UIColor *) invertColor:(UIColor *)aColor
{
    CGFloat r, g, b, a = 0.0;
    [self.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    UIColor *retColor = [UIColor colorWithRed:[self invertByte:r]
                                        green:[self invertByte:g]
                                         blue:[self invertByte:b]
                                        alpha:a];
    return retColor;
}

@end
