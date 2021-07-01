//
//  NSString+HtmlUtil.m
//
//  Created by Dmitry Likhtarov on 27/12/2018.
//  Copyright © 2018 Dmitry Likhtarov. All rights reserved.
//

#import "NSString+HtmlUtil.h"

@implementation NSString (HtmlUtil)

//
// декодирует юникоде стринг типа @"\\u5404\\u500b\\u90fd";
//
- (NSString*) deUnicodeString
{
    if (self.length > 0) {
        NSMutableString *convertedString = [self mutableCopy];
        CFStringRef transform = CFSTR("Any-Hex/Java");
        CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
        return convertedString;
    }
    return self;
}

//
// декодирует html стринг типа @"&quot;  &hx1201;  &x20; ";
//
- (NSString*)deHtmlString
{
    // Если нет апмерсанда то далее не ищем
    if (self.length < 1 || [self rangeOfString:@"&" options:NSLiteralSearch].location == NSNotFound) {
        return self;
    }
    
    // Накапливаем строку
    NSMutableString *result = [NSMutableString new];
    
    NSScanner *scanner = [NSScanner scannerWithString:self];
    
    [scanner setCharactersToBeSkipped:nil];
    
    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
    
    do {
        // Сканирование до следующего объекта или до конца строки.
        
        NSString *nonEntityString;
        
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        
        if (scanner.isAtEnd) {
            return result;
        }

        if ([scanner scanString:@"&amp;" intoString:NULL]) {
            [result appendString:@"&"];
        } else if ([scanner scanString:@"&apos;" intoString:NULL]) {
            [result appendString:@"'"];
        } else if ([scanner scanString:@"&quot;" intoString:NULL]) {
            [result appendString:@"\""];
        } else if ([scanner scanString:@"&lt;" intoString:NULL]) {
            [result appendString:@"<"];
        } else if ([scanner scanString:@"&gt;" intoString:NULL]) {
            [result appendString:@">"];
        }
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
            
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            } else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            
            if (gotNumber) {
                [result appendFormat:@"%C", (unichar)charCode];
                
                [scanner scanString:@";" intoString:NULL];
            } else {
                NSString *unknownEntity = @"";
                
                [scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
                
                
                [result appendFormat:@"&#%@%@", xForHex, unknownEntity];
                
                //[scanner scanUpToString:@";" intoString:&unknownEntity];
                //[result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                //NSLog(@"Ожидали число, но получили &#%@%@;", xForHex, unknownEntity);
                
            }
            
        } else {
            
            NSString *amp;
            
            [scanner scanString:@"&" intoString:&amp];    //отдельностоящий амперсад (&)
            [result appendString:amp];
            
            /*
             NSString *unknownEntity = @"";
             [scanner scanUpToString:@";" intoString:&unknownEntity];
             NSString *semicolon = @"";
             [scanner scanString:@";" intoString:&semicolon];
             [result appendFormat:@"%@%@", unknownEntity, semicolon];
             NSLog(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
             */
        }
        
    } while (!scanner.isAtEnd);
    
    return result;
}

- (NSDictionary * _Nonnull) dictFromJSON
{
    NSError * error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData: [self dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: &error];
    
    if (error == nil && [jsonObject isKindOfClass:NSDictionary.class]) {
        return jsonObject;
    }
    
    DLog(@"%@", [error localizedDescription]);
    return @{};
}

- (NSArray * _Nonnull) arrayFromJSON
{
    NSError * error = nil;
    id jsonObject =
    [NSJSONSerialization JSONObjectWithData: [self dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: &error];
    
    if (error == nil && [jsonObject isKindOfClass:NSArray.class]) {
        return jsonObject;
    }
    
    DLog(@"%@", error.localizedDescription);
    return @[];
}

// Найти в строке по регулярному выражению
// Возвращает первый параметр (тот который которой первый в скобках)
- (NSString *) stringWithRegularExpression:(NSString*)regViragenie
{
    if (regViragenie.length < 1) {
        return @"";
    }
    
    NSString * resultat = nil;
    NSRegularExpression * regExp = [NSRegularExpression regularExpressionWithPattern:regViragenie options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSTextCheckingResult * matchs = [regExp firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    if (matchs.numberOfRanges > 1) {
        NSRange range = [matchs rangeAtIndex:1];
        if (range.length > 0) {
            resultat = [self substringWithRange:range];
        }
    }
    //DLog(@" ☘️ Найдено: \"%@\"",resultat);
    return resultat;
}

//
//// Convert the number in the string to the corresponding
//// Unicode character, e.g.
////    decodeNumeric("64", 10)   --> "@"
////    decodeNumeric("20ac", 16) --> "€"
//
//- (NSString*)deUnicodeString:(NSString*)input { // декодирует юникоде стринг типа @"\\u5404\\u500b\\u90fd";
//    if (!input) { return input; } // Если нил то нил
//    NSString *convertedString = [input mutableCopy];
//    CFStringRef transform = CFSTR("Any-Hex/Java");
//    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
//    return convertedString;
//}
//
////- (NSString*) decodeNumeric:(NSString*)string base:(int32_t)base
////{
////    
////    let code = UInt32(strtoul(string, nil, base))
////    
////    return Character(UnicodeScalar(code)!)
////}
////- (NSString*) decode:(NSString*)entity
////{
////    if ([entity hasPrefix:@"&#x"] || [entity hasPrefix:@"&#X"]) {
////        return [self ]
////        return decodeNumeric(String(entity[entity.index(entity.startIndex, offsetBy: 3)...]), base: 16)
////    } else if ([entity hasPrefix@"&#"]) {
////        return decodeNumeric(String(entity[entity.index(entity.startIndex, offsetBy: 2)...]), base: 10)
////    } else {
////        return characterEntities[entity];
////    }
////
////}
//
//- (NSDictionary*) characterEntities
//{
//    static NSDictionary *dict = nil;
//    if (!dict) {
//        dict = @{
//                 // XML predefined entities:
//                 @"&quot;"     : @"\"",
//                 @"&amp;"      : @"&",
//                 @"&apos;"     : @"'",
//                 @"&lt;"       : @"<",
//                 @"&gt;"       : @">",
//                 
//                 // HTML character entity references:
//                 @"&nbsp;"     : @"\u00A0",
//                 @"&iexcl;"    : @"\u00A1",
//                 @"&cent;"     : @"\u00A2",
//                 @"&pound;"    : @"\u00A3",
//                 @"&curren;"   : @"\u00A4",
//                 @"&yen;"      : @"\u00A5",
//                 @"&brvbar;"   : @"\u00A6",
//                 @"&sect;"     : @"\u00A7",
//                 @"&uml;"      : @"\u00A8",
//                 @"&copy;"     : @"\u00A9",
//                 @"&ordf;"     : @"\u00AA",
//                 @"&laquo;"    : @"\u00AB",
//                 @"&not;"      : @"\u00AC",
//                 @"&shy;"      : @"\u00AD",
//                 @"&reg;"      : @"\u00AE",
//                 @"&macr;"     : @"\u00AF",
//                 @"&deg;"      : @"\u00B0",
//                 @"&plusmn;"   : @"\u00B1",
//                 @"&sup2;"     : @"\u00B2",
//                 @"&sup3;"     : @"\u00B3",
//                 @"&acute;"    : @"\u00B4",
//                 @"&micro;"    : @"\u00B5",
//                 @"&para;"     : @"\u00B6",
//                 @"&middot;"   : @"\u00B7",
//                 @"&cedil;"    : @"\u00B8",
//                 @"&sup1;"     : @"\u00B9",
//                 @"&ordm;"     : @"\u00BA",
//                 @"&raquo;"    : @"\u00BB",
//                 @"&frac14;"   : @"\u00BC",
//                 @"&frac12;"   : @"\u00BD",
//                 @"&frac34;"   : @"\u00BE",
//                 @"&iquest;"   : @"\u00BF",
//                 @"&Agrave;"   : @"\u00C0",
//                 @"&Aacute;"   : @"\u00C1",
//                 @"&Acirc;"    : @"\u00C2",
//                 @"&Atilde;"   : @"\u00C3",
//                 @"&Auml;"     : @"\u00C4",
//                 @"&Aring;"    : @"\u00C5",
//                 @"&AElig;"    : @"\u00C6",
//                 @"&Ccedil;"   : @"\u00C7",
//                 @"&Egrave;"   : @"\u00C8",
//                 @"&Eacute;"   : @"\u00C9",
//                 @"&Ecirc;"    : @"\u00CA",
//                 @"&Euml;"     : @"\u00CB",
//                 @"&Igrave;"   : @"\u00CC",
//                 @"&Iacute;"   : @"\u00CD",
//                 @"&Icirc;"    : @"\u00CE",
//                 @"&Iuml;"     : @"\u00CF",
//                 @"&ETH;"      : @"\u00D0",
//                 @"&Ntilde;"   : @"\u00D1",
//                 @"&Ograve;"   : @"\u00D2",
//                 @"&Oacute;"   : @"\u00D3",
//                 @"&Ocirc;"    : @"\u00D4",
//                 @"&Otilde;"   : @"\u00D5",
//                 @"&Ouml;"     : @"\u00D6",
//                 @"&times;"    : @"\u00D7",
//                 @"&Oslash;"   : @"\u00D8",
//                 @"&Ugrave;"   : @"\u00D9",
//                 @"&Uacute;"   : @"\u00DA",
//                 @"&Ucirc;"    : @"\u00DB",
//                 @"&Uuml;"     : @"\u00DC",
//                 @"&Yacute;"   : @"\u00DD",
//                 @"&THORN;"    : @"\u00DE",
//                 @"&szlig;"    : @"\u00DF",
//                 @"&agrave;"   : @"\u00E0",
//                 @"&aacute;"   : @"\u00E1",
//                 @"&acirc;"    : @"\u00E2",
//                 @"&atilde;"   : @"\u00E3",
//                 @"&auml;"     : @"\u00E4",
//                 @"&aring;"    : @"\u00E5",
//                 @"&aelig;"    : @"\u00E6",
//                 @"&ccedil;"   : @"\u00E7",
//                 @"&egrave;"   : @"\u00E8",
//                 @"&eacute;"   : @"\u00E9",
//                 @"&ecirc;"    : @"\u00EA",
//                 @"&euml;"     : @"\u00EB",
//                 @"&igrave;"   : @"\u00EC",
//                 @"&iacute;"   : @"\u00ED",
//                 @"&icirc;"    : @"\u00EE",
//                 @"&iuml;"     : @"\u00EF",
//                 @"&eth;"      : @"\u00F0",
//                 @"&ntilde;"   : @"\u00F1",
//                 @"&ograve;"   : @"\u00F2",
//                 @"&oacute;"   : @"\u00F3",
//                 @"&ocirc;"    : @"\u00F4",
//                 @"&otilde;"   : @"\u00F5",
//                 @"&ouml;"     : @"\u00F6",
//                 @"&divide;"   : @"\u00F7",
//                 @"&oslash;"   : @"\u00F8",
//                 @"&ugrave;"   : @"\u00F9",
//                 @"&uacute;"   : @"\u00FA",
//                 @"&ucirc;"    : @"\u00FB",
//                 @"&uuml;"     : @"\u00FC",
//                 @"&yacute;"   : @"\u00FD",
//                 @"&thorn;"    : @"\u00FE",
//                 @"&yuml;"     : @"\u00FF",
//                 @"&OElig;"    : @"\u0152",
//                 @"&oelig;"    : @"\u0153",
//                 @"&Scaron;"   : @"\u0160",
//                 @"&scaron;"   : @"\u0161",
//                 @"&Yuml;"     : @"\u0178",
//                 @"&fnof;"     : @"\u0192",
//                 @"&circ;"     : @"\u02C6",
//                 @"&tilde;"    : @"\u02DC",
//                 @"&Alpha;"    : @"\u0391",
//                 @"&Beta;"     : @"\u0392",
//                 @"&Gamma;"    : @"\u0393",
//                 @"&Delta;"    : @"\u0394",
//                 @"&Epsilon;"  : @"\u0395",
//                 @"&Zeta;"     : @"\u0396",
//                 @"&Eta;"      : @"\u0397",
//                 @"&Theta;"    : @"\u0398",
//                 @"&Iota;"     : @"\u0399",
//                 @"&Kappa;"    : @"\u039A",
//                 @"&Lambda;"   : @"\u039B",
//                 @"&Mu;"       : @"\u039C",
//                 @"&Nu;"       : @"\u039D",
//                 @"&Xi;"       : @"\u039E",
//                 @"&Omicron;"  : @"\u039F",
//                 @"&Pi;"       : @"\u03A0",
//                 @"&Rho;"      : @"\u03A1",
//                 @"&Sigma;"    : @"\u03A3",
//                 @"&Tau;"      : @"\u03A4",
//                 @"&Upsilon;"  : @"\u03A5",
//                 @"&Phi;"      : @"\u03A6",
//                 @"&Chi;"      : @"\u03A7",
//                 @"&Psi;"      : @"\u03A8",
//                 @"&Omega;"    : @"\u03A9",
//                 @"&alpha;"    : @"\u03B1",
//                 @"&beta;"     : @"\u03B2",
//                 @"&gamma;"    : @"\u03B3",
//                 @"&delta;"    : @"\u03B4",
//                 @"&epsilon;"  : @"\u03B5",
//                 @"&zeta;"     : @"\u03B6",
//                 @"&eta;"      : @"\u03B7",
//                 @"&theta;"    : @"\u03B8",
//                 @"&iota;"     : @"\u03B9",
//                 @"&kappa;"    : @"\u03BA",
//                 @"&lambda;"   : @"\u03BB",
//                 @"&mu;"       : @"\u03BC",
//                 @"&nu;"       : @"\u03BD",
//                 @"&xi;"       : @"\u03BE",
//                 @"&omicron;"  : @"\u03BF",
//                 @"&pi;"       : @"\u03C0",
//                 @"&rho;"      : @"\u03C1",
//                 @"&sigmaf;"   : @"\u03C2",
//                 @"&sigma;"    : @"\u03C3",
//                 @"&tau;"      : @"\u03C4",
//                 @"&upsilon;"  : @"\u03C5",
//                 @"&phi;"      : @"\u03C6",
//                 @"&chi;"      : @"\u03C7",
//                 @"&psi;"      : @"\u03C8",
//                 @"&omega;"    : @"\u03C9",
//                 @"&thetasym;" : @"\u03D1",
//                 @"&upsih;"    : @"\u03D2",
//                 @"&piv;"      : @"\u03D6",
//                 @"&ensp;"     : @"\u2002",
//                 @"&emsp;"     : @"\u2003",
//                 @"&thinsp;"   : @"\u2009",
//                 @"&zwnj;"     : @"\u200C",
//                 @"&zwj;"      : @"\u200D",
//                 @"&lrm;"      : @"\u200E",
//                 @"&rlm;"      : @"\u200F",
//                 @"&ndash;"    : @"\u2013",
//                 @"&mdash;"    : @"\u2014",
//                 @"&lsquo;"    : @"\u2018",
//                 @"&rsquo;"    : @"\u2019",
//                 @"&sbquo;"    : @"\u201A",
//                 @"&ldquo;"    : @"\u201C",
//                 @"&rdquo;"    : @"\u201D",
//                 @"&bdquo;"    : @"\u201E",
//                 @"&dagger;"   : @"\u2020",
//                 @"&Dagger;"   : @"\u2021",
//                 @"&bull;"     : @"\u2022",
//                 @"&hellip;"   : @"\u2026",
//                 @"&permil;"   : @"\u2030",
//                 @"&prime;"    : @"\u2032",
//                 @"&Prime;"    : @"\u2033",
//                 @"&lsaquo;"   : @"\u2039",
//                 @"&rsaquo;"   : @"\u203A",
//                 @"&oline;"    : @"\u203E",
//                 @"&frasl;"    : @"\u2044",
//                 @"&euro;"     : @"\u20AC",
//                 @"&image;"    : @"\u2111",
//                 @"&weierp;"   : @"\u2118",
//                 @"&real;"     : @"\u211C",
//                 @"&trade;"    : @"\u2122",
//                 @"&alefsym;"  : @"\u2135",
//                 @"&larr;"     : @"\u2190",
//                 @"&uarr;"     : @"\u2191",
//                 @"&rarr;"     : @"\u2192",
//                 @"&darr;"     : @"\u2193",
//                 @"&harr;"     : @"\u2194",
//                 @"&crarr;"    : @"\u21B5",
//                 @"&lArr;"     : @"\u21D0",
//                 @"&uArr;"     : @"\u21D1",
//                 @"&rArr;"     : @"\u21D2",
//                 @"&dArr;"     : @"\u21D3",
//                 @"&hArr;"     : @"\u21D4",
//                 @"&forall;"   : @"\u2200",
//                 @"&part;"     : @"\u2202",
//                 @"&exist;"    : @"\u2203",
//                 @"&empty;"    : @"\u2205",
//                 @"&nabla;"    : @"\u2207",
//                 @"&isin;"     : @"\u2208",
//                 @"&notin;"    : @"\u2209",
//                 @"&ni;"       : @"\u220B",
//                 @"&prod;"     : @"\u220F",
//                 @"&sum;"      : @"\u2211",
//                 @"&minus;"    : @"\u2212",
//                 @"&lowast;"   : @"\u2217",
//                 @"&radic;"    : @"\u221A",
//                 @"&prop;"     : @"\u221D",
//                 @"&infin;"    : @"\u221E",
//                 @"&ang;"      : @"\u2220",
//                 @"&and;"      : @"\u2227",
//                 @"&or;"       : @"\u2228",
//                 @"&cap;"      : @"\u2229",
//                 @"&cup;"      : @"\u222A",
//                 @"&int;"      : @"\u222B",
//                 @"&there4;"   : @"\u2234",
//                 @"&sim;"      : @"\u223C",
//                 @"&cong;"     : @"\u2245",
//                 @"&asymp;"    : @"\u2248",
//                 @"&ne;"       : @"\u2260",
//                 @"&equiv;"    : @"\u2261",
//                 @"&le;"       : @"\u2264",
//                 @"&ge;"       : @"\u2265",
//                 @"&sub;"      : @"\u2282",
//                 @"&sup;"      : @"\u2283",
//                 @"&nsub;"     : @"\u2284",
//                 @"&sube;"     : @"\u2286",
//                 @"&supe;"     : @"\u2287",
//                 @"&oplus;"    : @"\u2295",
//                 @"&otimes;"   : @"\u2297",
//                 @"&perp;"     : @"\u22A5",
//                 @"&sdot;"     : @"\u22C5",
//                 @"&lceil;"    : @"\u2308",
//                 @"&rceil;"    : @"\u2309",
//                 @"&lfloor;"   : @"\u230A",
//                 @"&rfloor;"   : @"\u230B",
//                 @"&lang;"     : @"\u2329",
//                 @"&rang;"     : @"\u232A",
//                 @"&loz;"      : @"\u25CA",
//                 @"&spades;"   : @"\u2660",
//                 @"&clubs;"    : @"\u2663",
//                 @"&hearts;"   : @"\u2665",
//                 @"&diams;"    : @"\u2666",
//                 };
//    }
//    return dict;
//}

@end
