//
//  NSString+HtmlUtil.h
//
//  Created by Dmitry Likhtarov on 27/12/2018.
//  Copyright © 2018 Dmitry Likhtarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IOS
#else
    #import <Cocoa/Cocoa.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HtmlUtil)

//
// декодирует юникоде стринг типа @"\\u5404\\u500b\\u90fd";
//
- (NSString*)deUnicodeString;

//
// декодирует html стринг типа @"&quot;  &hx1201;  &x20; ";
//
- (NSString*)deHtmlString;

- (NSDictionary * _Nonnull) dictFromJSON;
- (NSArray * _Nonnull) arrayFromJSON;

- (NSString *) stringWithRegularExpression:(NSString*)regViragenie;

@end

NS_ASSUME_NONNULL_END
