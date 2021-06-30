//
//  UIColor+ColorHex.m
//
//  Created by Dmitry Likhtarov on 23.04.2018.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import "UIColor+ColorHex.h"

@implementation UIColor (ColorHex)

+ (UIColor * _Nonnull) colorWithHexString:(NSString *_Nonnull) hexString
{
    // Возвращает Белый или NSColor
    
    if ([hexString length] != 6) {
        return [UIColor whiteColor];
    }
    
    // Проверим на валидность
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-fA-F|0-9]" options:0 error:NULL];
    NSUInteger match = [regex numberOfMatchesInString:hexString options:NSMatchingReportCompletion range:NSMakeRange(0, [hexString length])];
    
    if (match != 0) {
        return [UIColor whiteColor];
    }
    
    NSRange rRange = NSMakeRange(0, 2);
    NSString *rComponent = [hexString substringWithRange:rRange];
    unsigned int rVal = 0;
    NSScanner *rScanner = [NSScanner scannerWithString:rComponent];
    [rScanner scanHexInt:&rVal];
    float rRetVal = (float)rVal / 254;
    
    
    NSRange gRange = NSMakeRange(2, 2);
    NSString *gComponent = [hexString substringWithRange:gRange];
    unsigned int gVal = 0;
    NSScanner *gScanner = [NSScanner scannerWithString:gComponent];
    [gScanner scanHexInt:&gVal];
    float gRetVal = (float)gVal / 254;
    
    NSRange bRange = NSMakeRange(4, 2);
    NSString *bComponent = [hexString substringWithRange:bRange];
    unsigned int bVal = 0;
    NSScanner *bScanner = [NSScanner scannerWithString:bComponent];
    [bScanner scanHexInt:&bVal];
    float bRetVal = (float)bVal / 254;
    
    return [UIColor colorWithRed:rRetVal green:gRetVal blue:bRetVal alpha:1.0f];
    
}

+ (NSString * _Nonnull) hexValuesFromUIColor:(UIColor * _Nonnull) color
{
    // Возвращает Белый или 6 16-тиричных символов
    
    if (!color || color == [UIColor whiteColor]) {
        return @"ffffff"; // Special case, as white doesn't fall into the RGB color space
    }
    
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    int redDec   = (int)(red * 255);
    int greenDec = (int)(green * 255);
    int blueDec  = (int)(blue * 255);
    
    NSString *returnString = [NSString stringWithFormat:@"%02x%02x%02x", (unsigned int)redDec, (unsigned int)greenDec, (unsigned int)blueDec];
    
    return returnString;
 }

+ (UIColor *) colorWithRedByte:(int)aRed greenByte:(int)aGreen blueByte:(int)ablue andAlpha:(double)aAlpha
{
    double r = (aRed & 0xff) / 255.0;
    double g = (aGreen & 0xff) / 255.0;
    double b = (ablue & 0xff) / 255.0;
    double alpha = (aAlpha < 0.0 ? 0.0 : (aAlpha > 1.0 ? 1.0 : aAlpha));

    return [UIColor  colorWithRed:r green:g blue:b alpha:alpha];
}

@end

