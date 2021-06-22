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
                          error:(NSError*)errorTotal
                     completion:(void (^)(NSError *error))completion
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

#pragma mark -
//
//- (void) loadPriceFormWWW
//{
//    if (!self->lvc) self->lvc = [[LoaderVC alloc] init];
//    self.cToolsLD.lvc = self->lvc;
//    [self->lvc showHeader:@"Загрузка прайса и картинок с WWW" Status:@"Загружается прайс с сервера..." pauseClose:1.1 closeCompletion:^(NSModalResponse returnCode) {
//        self->lvc = nil;
//    }];
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:GET_PRICE_ZIPPED_URL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT_INTERVAL_GET_PRICE];
//    request.HTTPMethod = @"GET";
//
//    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable errorWWW) {
//
//        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//        ALog(@"🦋 Загружен прайс с сервера StatusCode - %ld", statusCode);
//
//        if (data && statusCode == 200) {
//
//            NSURL *urlDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
//            NSURL *urlSavedBPList = [urlDir URLByAppendingPathComponent:PRICE_FILE_NAME];
//            NSURL *urlFileZip = [urlDir URLByAppendingPathComponent:PRICE_FILE_NAME_ZIP];
//
//            NSFileManager *fm = [NSFileManager defaultManager];
//            [fm createDirectoryAtURL:urlDir withIntermediateDirectories:YES attributes:nil error:nil];
//
//            [fm removeItemAtURL:urlSavedBPList error:nil];
//            [fm removeItemAtURL:urlFileZip error:nil];
//            [data writeToURL:urlFileZip atomically:YES];
//            [SSZipArchive unzipFileAtPath:urlFileZip.path toDestination:urlDir.path];
//            NSData *priceData = [NSData dataWithContentsOfURL:urlSavedBPList];
//            NSMutableDictionary *dictRecord = nil;
//            if (priceData) {
//                NSError *error = nil;
//                 dictRecord = [[NSKeyedUnarchiver unarchivedObjectOfClass:NSObject.class fromData:priceData error:&error] mutableCopy];
//            }
//            NSMutableArray <NSURL*>*imageNames = [NSMutableArray new]; // Список имен картинок, на которые ссылается прайс
//            if (dictRecord) {
//                DLog(@"Получен прайс от %@ (%ld ключей)", dictRecord[@"date"], dictRecord.count);
//                NSURL *baseURL = [NSURL URLWithString:HTTP_BASE_URL];
//                for (NSString *key in dictRecord.allKeys) {
//                    NSArray *array = dictRecord[key];
//                    if ([array isKindOfClass:NSArray.class]) {
//                        for (CKRecord *record in array) {
//                            for (NSString *keyImage in @[@"mainImage", @"menuMainImage", ]) {
//                                CKAsset *assetFile = record[keyImage];
//                                NSString *fileName = assetFile.fileURL.lastPathComponent;
//                                if ([fileName hasPrefix:IMAGE_PREFIX]) {
//                                    [imageNames addObject:[NSURL URLWithString:fileName relativeToURL:baseURL]];
//                                }
//                            }
//                            for (NSString *keyImages in @[@"interiorImages", @"schemaImages", @"adImages", @"images", ]) {
//                                NSArray * assets = record[keyImages];
//                                if ([array isKindOfClass:NSArray.class]) {
//                                    for (int i = 0; i < assets.count; i++) {
//                                        CKAsset *assetFile = assets[i];
//                                        NSString *fileName = assetFile.fileURL.lastPathComponent;
//                                        if ([fileName hasPrefix:IMAGE_PREFIX]) {
//                                            [imageNames addObject:[NSURL URLWithString:fileName relativeToURL:baseURL]];
//                                        }
//                                    }
//                                }
//                            }
//
//                        }
//                    }
//                }
//                DLog(@"Надо загрузить %ld картинок", imageNames.count);
//
//                [self loadFromWWWFilesUrls:imageNames cursor:0 fileUrls:[NSMutableArray new] error:[NSMutableArray new] completion:^(NSArray<NSURL *> *fileUrls, NSArray<NSError *> *errors) {
//                    DLog(@"Загружено %ld картинок (из %ld). Ошибок: %ld, последняя: %@", fileUrls.count, imageNames.count, errors.count, errors.count>0?errors[0]:@"");
//                    [self->lvc stopAnimation];
//                    [self.cToolsLD.lvc stopAnimation];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSAlert *alert = [[NSAlert alloc] init];
//                        alert.messageText = @"Загрузка завершена";
//                        alert.alertStyle = errors.count > 0 ? NSAlertStyleCritical : NSAlertStyleInformational;
//                        alert.informativeText = [NSString stringWithFormat:@"Загружено %ld картинок (из %ld) в папку:\n\n%@%@", fileUrls.count, imageNames.count, urlDir, errors.count > 0 ? [NSString stringWithFormat:@"\n\nОшибок: %ld, последняя: %@", errors.count, errors[0]] : @""];
//                        [alert runModal];
//                    });
//                }];
//            } else {
//                DLog(@"🦋‼️ Прайс не удалось разархивировать сервера StatusCode - %ld", statusCode);
//            }
//
//
//        } else {
//            NSString *otvet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            [self->lvc setStatus:[NSString stringWithFormat:@"Ошибка %ld\n%@\n%@", statusCode, errorWWW?errorWWW.localizedDescription:@"", otvet]];
//        }
//
//    }] resume];
//
//}
//
//- (void) loadFromWWWFilesUrls:(NSArray<NSURL*>*)urls
//                       cursor:(NSInteger)cursor
//                     fileUrls:(NSMutableArray <NSURL *> *)fileUrls
//                        error:(NSMutableArray <NSError *> *)errorsTotal
//                   completion:(void (^)(NSArray <NSURL *> *fileUrls, NSArray <NSError *> * errors))completion
//{
//    // Рекурсивный метод, загрузит все файлы из urls
//    // в блоке возвращает список URLs загруженных файлов и список ошибок загрузки
//    // Одновременно загружаем не более max файлов
//
//    int max = 3;
//
//    NSInteger count = urls.count;
//    NSInteger lenght = MIN(max, count - MIN(cursor, count));
//    NSArray <NSURL*>*files = nil;
//    if (lenght > 0) {
//        NSRange range = NSMakeRange(cursor, lenght);
//        files = [urls subarrayWithRange:range];
//    }
//    if (files.count < 1) {
//        if (completion) completion(fileUrls, errorsTotal);
//        return;
//    }
//
//    [self->lvc setStatus:[NSString stringWithFormat:@"Загружаются  с сервера %ld из %ld картинок", cursor + lenght, count]];
//
//    __block NSInteger countBlock = files.count;
//
//    for (NSURL *url in files) {
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT_INTERVAL_GET_PRICE];
//        request.HTTPMethod = @"GET";
//
//        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable errorWWW) {
//
//            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//
//            NSURL *urlDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
//            NSURL *urlFileSave = [urlDir URLByAppendingPathComponent:request.URL.lastPathComponent];
//
//            if (data && statusCode == 200) {
//
//                NSFileManager *fm = [NSFileManager defaultManager];
//                [fm createDirectoryAtURL:urlDir withIntermediateDirectories:YES attributes:nil error:nil];
//
//                if ([data writeToURL:urlFileSave atomically:YES]) {
//                    [fileUrls addObject:urlFileSave];
//                    ALog(@"🦋 Загружен файл с сервера: %@", urlFileSave);
//                } else {
//                    urlFileSave = nil;
//                }
//
//            }
//
//            if (!urlFileSave) {
//                NSError *error = [NSError errorWithDomain:@"BC" code:statusCode userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"‼️ Ошибка загрузки файла %@  Статус: %ld, ошибка %@", request.URL, statusCode, errorWWW]}];
//                [errorsTotal addObject:error];
//                DLog(@"🦋‼️ %@", error);
//            }
//
//            countBlock--;
//            if (countBlock < 1) {
//                // Для того, чтобы загружать апельсины бочками, но не более max одновременно
//                [self loadFromWWWFilesUrls:urls cursor:cursor+max fileUrls:fileUrls error:errorsTotal completion:completion];
//            }
//
//        }] resume];
//
//    }
//
//}


@end
