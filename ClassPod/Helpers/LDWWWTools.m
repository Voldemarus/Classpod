//
//  LDWWWTools.m
//
//  Created by Dmitry Likhtarov on 20.07.2018.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import "LDWWWTools.h"
//#import "NSDate+Compare.h"
#import <CommonCrypto/CommonDigest.h>
#import "Utils.h"
//#import "SSZipArchive.h"
#import "NSString+HtmlUtil.h"

@interface LDWWWTools()
{
    NSMutableString *errorsWWW;
}

@end

@implementation LDWWWTools

+ (LDWWWTools *) sharedInstance
{
    static LDWWWTools * _shared = nil;
    static dispatch_once_t predicate;
    dispatch_once (&predicate, ^{_shared = [[self alloc] init];});
    return _shared;
}
- (instancetype) init
{
    if (self = [super init]) {
        //
    }
    return self;
}

#pragma mark -

- (void) saveToWWWFilesWithUrls:(NSArray<NSURL*>*)urls
                         cursor:(NSInteger)cursor
                          error:(NSError*_Nullable)errorTotal
                     completion:(void (^ _Nullable)(NSError * _Nullable error))completion
{
    // urls - список URL с файлами для записи на сервер

    int max = 50; // ограничение 100 файлов чтоб не правысить MAX_FILE_SIZE
    
    NSInteger count = urls.count;
    NSInteger min = count - MIN(cursor, count);
    NSInteger lenght = MIN(max, min);
    NSArray *files = nil;
    
    if (lenght > 0) {
        NSRange range = NSMakeRange(cursor, lenght);
        files = [urls subarrayWithRange:range];
    }
    
    if (files.count < 1) {
        if (completion) completion(errorTotal);
        return;
    }
        
    NSURLRequest *request = [self buildRequestAllFiles:files];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable errorWWW) {
        
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        NSString *otvet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        ALog(@"🦋 = cursor = %ld ==>%@<==", cursor, otvet);
        
        if ([otvet hasPrefix:@"OK"] && statusCode == 200) {
            ALog(@"🦋 На сервер успешно вызружено %ld из %ld файлов", cursor + lenght, count);
            // увеличить курсор и рекурсивно вызвать себя же
            [self saveToWWWFilesWithUrls:urls cursor:cursor+max error:errorTotal completion:completion];
        } else if ([otvet hasPrefix:@"errorhash"] && statusCode == 200) {
            ALog(@"‼️ Временная ошибка сравнения хэшей");
            // хэш мог попасть в пограничное состояние, зациклим и повторим эту порцию
            [self saveToWWWFilesWithUrls:urls cursor:cursor error:errorTotal completion:completion];
        } else {
            ALog(@"‼️ Ошибка вызруки порции %ld в позиции %ld из %ld файлов", lenght, cursor, count);
            ALog(@"StatusCode - %ld", statusCode);
            ALog(@"request.URL - %@", request.URL);
            ALog(@"allHeaderFields - %@", [(NSHTTPURLResponse *)response allHeaderFields]);
            ALog(@"data.length = %ld", data.length);
            NSError *error = [NSError errorWithDomain:@"BC" code:statusCode userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"‼️ Ошибка вызруки порции %ld в позиции %ld из %ld файлов:\nСтатус:%ld\n%@\n%@", lenght, cursor, count, statusCode, otvet, statusCode == 500 ? @"Ошибка PHP-скрипта на сервере": errorWWW]}];
            // Произошла ошибка, зафиксируем ее и прпробуем другие порции отправить
            // Если 500 ошибка - то нет смысла продолжать, PHP-скрипт неисправен
            [self saveToWWWFilesWithUrls:(statusCode == 500)?@[]:urls cursor:cursor+max error:error completion:completion];
        }
        
    }] resume];
    
}

#define KEY_PARAM              @"Key_Param"
#define KEY_GET_INFO           @"Key_Get_Info"
#define URL_POST_UPLOAD_AUDIO  @"https://classpod.spintip.com/zagruzka.php"

#define TIMEOUT_INTERVAL_POST    45

- (NSURLRequest *)buildRequestAllFiles:(NSArray<NSURL*>*)arrayWithUrlFiles {
    
    if (arrayWithUrlFiles.count < 1) return nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_POST_UPLOAD_AUDIO] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT_INTERVAL_POST];
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    request.HTTPMethod = @"POST";
    
    //#warning HASH Need!!! Нужен какойто хэш!
    NSString *hashString = [self hashMD5WithCurrentTime]; // @"Key_Param"
    
    NSString *boundary = NSUUID.UUID.UUIDString;
    
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, boundary] forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *tempPostData = [NSMutableData data];
    
    for (int i = 0; i < arrayWithUrlFiles.count; i++) {
//    for (int i = 0; i < 3; i++) {
        NSURL *urlFile = arrayWithUrlFiles[i];
        NSData *postDataPrice = [NSData dataWithContentsOfURL:urlFile];

        // Sample file to send as data
        [tempPostData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile[]\"; filename=\"%@\"\r\n", urlFile.lastPathComponent] dataUsingEncoding:NSUTF8StringEncoding]];
        [tempPostData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [tempPostData appendData:postDataPrice];

    }
    
    // Key_Param = По идее какой то хэш для авторизации и проверять его в PHP
    [tempPostData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", KEY_PARAM] dataUsingEncoding:NSUTF8StringEncoding]];
    [tempPostData appendData:[@"Content-Type: text/html\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [tempPostData appendData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];

    [tempPostData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[NSString stringWithFormat:@"%ld", tempPostData.length] forHTTPHeaderField:@"Content-Length"];

    request.HTTPBody = tempPostData;

    return request;
}

- (void) getListExistMusicOnServerCompletion:(void (^_Nullable)(NSError *error, NSDictionary * _Nonnull dictMusic))completion
{
    // arrayMusic - список с файлами на сервере "filename" => basename($file), "filesize" => filesize($file), "filedate" => filemtime($file)

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_POST_UPLOAD_AUDIO] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT_INTERVAL_POST];
    
    request.HTTPMethod = @"POST";
    
    //#warning HASH Need!!! Нужен какойто хэш!
    NSString *hashString = [self hashMD5WithCurrentTime]; // @"Key_Param"
    
    request.HTTPBody = [[NSString stringWithFormat:@"%@=%@&%@=%@",KEY_PARAM, hashString, KEY_GET_INFO, KEY_GET_INFO] dataUsingEncoding:NSUTF8StringEncoding];

    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable errorWWW) {
        
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        NSString *otvet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
        if (statusCode == 200) {
            ALog(@"🦋 с сервера получен ответ %@", otvet);
            NSDictionary *dict = otvet.dictFromJSON;
            if (completion) completion(errorWWW, dict?dict:@{});
        } else if ([otvet hasPrefix:@"errorhash"] && statusCode == 200) {
            ALog(@"‼️ Временная ошибка сравнения хэшей");
            // хэш мог попасть в пограничное состояние, зациклим и повторим эту порцию
            [self getListExistMusicOnServerCompletion:completion];
        } else {
            ALog(@"‼️ Ошибка плучения списка файлов с сервера отвер:%@ error:%@", otvet, errorWWW);
            ALog(@"StatusCode - %ld", statusCode);
            ALog(@"request.URL - %@", request.URL);
            ALog(@"allHeaderFields - %@", [(NSHTTPURLResponse *)response allHeaderFields]);
            ALog(@"data.length = %ld", data.length);
            NSError *error = [NSError errorWithDomain:@"BC" code:statusCode userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"‼️ Ошибка плучения списка файлов с сервера error:%@\nСтатус:%ld\n%@\n%@", errorWWW, statusCode, otvet, statusCode == 500 ? @"Ошибка PHP-скрипта на сервере": errorWWW]}];
            // Произошла ошибка, зафиксируем ее и прпробуем другие порции отправить
            // Если 500 ошибка - то нет смысла продолжать, PHP-скрипт неисправен
            if (completion) completion(error, @{});
        }
        
    }] resume];
    
}

#pragma mark -

// Возвращяет хэш MD5 в верхнем или нижнем регистре регистре
- (NSString *) md5StringUpperCase:(NSString*)string lowerCase:(BOOL)lowerCase {
    const char *concat_str = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, (int)strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    if (lowerCase) { return [hash lowercaseString]; }
    return [hash uppercaseString];
}
- (NSString*) hashMD5WithCurrentTime
{
    NSInteger interval1970 = NSDate.date.timeIntervalSince1970; // секунд с 1970г
    NSString *str = [NSString stringWithFormat:@"%@%ld%@", @"As", interval1970/1000, @"Tuda"]; // Отбросим 1000 секунд
    NSString *hash = [self md5StringUpperCase:str lowerCase:YES];
    //DLog(@"Хэш строки\n%@\n%@", str, hash);
    return hash;
}

@end
