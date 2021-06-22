//
//  Utils.m
//
//  Created by Dmitry Likhtarov on 15/08/2019.
//  Copyright © 2019 Dmitry Likhtarov. All rights reserved.
//

#import "Utils.h"
#import <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <CommonCrypto/CommonDigest.h>
#import "ExtAudioConverter.h"
#import "lame.h"


// Картинка на обложку альбома по умолчанию
#define IMAGE_ALBUB_TEMPLATE @"CoverAlbumTemlate"

@implementation Utils

NSString* myCachesDirectory(void)
{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
}

NSString* myCachesDirectoryFile(NSString * _Nonnull name)
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:name];
}

// Путь для кэша мелодий по 30 секунд  // Library/Sound
NSString* mySoundDirectory(void)
{
    NSString *soundDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"Sounds"];
    NSFileManager *fm = NSFileManager.defaultManager;
    if (![fm fileExistsAtPath:soundDir]) {
        [fm createDirectoryAtPath:soundDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return soundDir;
}

// Путь файла с именем name в локальном кэше мелодий
NSString* mySoundFile(NSString * _Nonnull name)
{
    NSString *soundDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"Sounds"];
    NSFileManager *fm = NSFileManager.defaultManager;
    if (![fm fileExistsAtPath:soundDir]) {
        [fm createDirectoryAtPath:soundDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [soundDir stringByAppendingPathComponent:name];
}

#pragma mark - Работа с аудио файлом

/*
 Записать файл из библиотеки локально (// и обрезать на 30 секунд, - отключено)
 в копмплетион имя валидного файла в Library/Sounds или имя по умолчанию
*/

+ (void) createMP3FromMediaItem:(MPMediaItem*)song
                     completion:(void (^)(NSString * _Nullable fileWithPath))completion
{
    if (!song) {
        if (completion) completion(nil);
        DLog (@"‼️ Song пустой!");
        return;
    }
    
    NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    // Проверим, можно ли открыть исходный файл
    OSStatus openErr = noErr;
    AudioFileID audioFile = NULL;
    openErr = AudioFileOpenURL((__bridge CFURLRef) assetURL, kAudioFileReadPermission, 0, &audioFile);
    if (audioFile) AudioFileClose (audioFile);
    
    if (openErr) {
		NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:openErr userInfo:nil];
        DLog (@"‼️ Core Audio не может открыть URL: %@  OSStatus: %@", assetURL, error);
        if (completion) completion(nil);
        return;
    }

    if (![[AVAssetExportSession exportPresetsCompatibleWithAsset:songAsset] containsObject:AVAssetExportPresetAppleM4A]) {
        DLog (@"‼️ Недопустимый формат AVAssetExportPresetAppleM4A для songAsset. Доступны только: %@", [AVAssetExportSession exportPresetsCompatibleWithAsset:songAsset]);
        if (completion) completion(nil);
        return;
    }
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset presetName: AVAssetExportPresetAppleM4A];
 
    if (![exporter.supportedFileTypes containsObject:AVFileTypeAppleM4A]) {
        DLog (@"‼️ Недопустимый формат AVFileTypeAppleM4A для exporter. Доступны только: %@", exporter.supportedFileTypes);
        if (completion) completion(nil);
        return;
    }

    exporter.outputFileType = AVFileTypeAppleM4A; // AVFileTypeMPEGLayer3 - запрещен эплом
    
    NSString *fileM4A = mySoundFile(@"exportTempFileM4A");
    NSFileManager *fm = NSFileManager.defaultManager;
    if ([fm fileExistsAtPath:fileM4A]) {
        // DLog (@"Файл был, удалим его: %@", fileName);
        [fm removeItemAtPath:fileM4A error:nil];
    }
    
    exporter.outputURL = [NSURL fileURLWithPath:fileM4A];
    
//    // **** Обрезать файл до 30 секунд
//    float startTrimTime = 0; // mySlider.leftValue;
//    float endTrimTime = 30; // mySlider.rightValue;
//    CMTime startTime = CMTimeMake((int)(floor(startTrimTime * 100)), 100);
//    CMTime stopTime = CMTimeMake((int)(ceil(endTrimTime * 100)), 100);
//    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
//    exporter.timeRange = exportTimeRange;
//    // *****
    
    // А теперь экспортируем файл
#ifdef DEBUG
            NSTimeInterval ti0 = NSDate.date.timeIntervalSince1970;
#endif
    
    NSString *persistentID = [NSString stringWithFormat:@"%llu", song.persistentID];// NSUUID.UUID.UUIDString;
    if (persistentID.length < 1) {
        DLog (@"‼️ Не верный persistentID: %llu", song.persistentID);
        if (completion) completion(nil);
        return;
    }
    NSString *fileMP3 = mySoundFile(persistentID);

    [exporter exportAsynchronouslyWithCompletionHandler:^{
        // TODO: файл с расширением .mp3 не записывается в exportAsynchronouslyWithCompletionHandler! защита эпл:)))

        if (exporter.status == AVAssetExportSessionStatusCompleted) {
#ifdef DEBUG
            NSTimeInterval ti1 = NSDate.date.timeIntervalSince1970;
            DLog (@"🐞 Время записи файла из библиотеки:  %.3f", ti1 - ti0);
#endif
            ExtAudioConverter* converter = [[ExtAudioConverter alloc] init];
            converter.inputFile =  fileM4A;
            converter.outputFile = fileMP3;
            converter.outputFormatID = kAudioFormatMPEGLayer3;
            converter.outputFileType = kAudioFileMP3Type;
            converter.outputBitDepth = BitDepth_16;
            // 🐞 Время записи файла из библиотеки:  0.792
            // 🐞 Время конвертации файла в MP3:  11.189
            // 🐞 Время конвертации общее: 11.981
            [converter convert];

#ifdef DEBUG
            NSTimeInterval ti2 = NSDate.date.timeIntervalSince1970;
            DLog (@"🐞 Время конвертации файла в MP3:  %.3f", ti2 - ti1);
            DLog (@"🐞 Время конвертации общее: %.3f", ti2 - ti0);
#endif

            if (completion) completion(fileMP3);
            return;
        } else {
            DLog (@"🐞 Ошибка экспорта фала:  %ld", exporter.status);
            if (completion) completion(nil);
            return;
        }
        
    }];
    
}

// Картинка обложки песни(или альбома) с заданным размером
+ (UIImage*) imageCoverSong:(MPMediaItem*)song size:(CGSize)size
{
    if (!song) {
        return [UIImage imageNamed:IMAGE_ALBUB_TEMPLATE];
    }
    
    MPMediaItemArtwork* artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    if ( !artwork || artwork.bounds.size.width == 0 ) {
        // Если у песни нет обложки, то посмотрим обложку альбома
        NSNumber* albumID = [song valueForProperty:MPMediaItemPropertyAlbumPersistentID];
        if (albumID) {
            MPMediaQuery *  mediaQuery = [MPMediaQuery albumsQuery];
            MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue:albumID forProperty:MPMediaItemPropertyAlbumPersistentID];
            [mediaQuery addFilterPredicate:predicate];
            NSArray* arrMediaItems = mediaQuery.items;
            for (artwork in arrMediaItems) {
                artwork = [arrMediaItems[0] valueForProperty:MPMediaItemPropertyArtwork];
                if (artwork.bounds.size.width > 0) {
                    break;
                }
            }
        }
    }
    UIImage *image = [artwork imageWithSize:size];
    return image ? image : [UIImage imageNamed:IMAGE_ALBUB_TEMPLATE];
    
}

// Найдем песню в медиатеке по сохраненному ранее ID
+ (MPMediaItem*) mediaItemForPersistentID:(MPMediaEntityPersistentID) persistentID
{
    // Найдем песню, название, артиста и обложку
    MPMediaQuery * query = [MPMediaQuery songsQuery];
    MPMediaPropertyPredicate* pred = [MPMediaPropertyPredicate predicateWithValue:@(persistentID) forProperty:MPMediaItemPropertyPersistentID];
    [query addFilterPredicate:pred];
    return query.items.firstObject;
    
}

#pragma mark -

+ (BOOL) hasInternet
{
    BOOL otvet  = [Utils hasInternetBezAlerta];
    if (!otvet) {
        [self alertInfoTitle:RStr(@"Network error") message:[NSString stringWithFormat:@"Интернет недоступен. Если используется Сотовая сеть, то проверьте, разрешено ли программе ее использовать в настройке телефона(планшета) (нажмите кнопку \"Home\", найдите иконку \"Настройки\", далее: \"Сотовые данные\", найдите группу \"Сотовые данные для ПО\" и включите переключатель для программы %@)", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]] target:nil];
    }
    return otvet;
}

// Наличие интернета
+ (BOOL) hasInternetBezAlerta
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    return ( (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired) ) ? YES : NO;
}

+ (void) alertInfoTitle:(NSString*)title message:(NSString*)message target:(UIViewController* _Nullable)viewController
{
    [self runMainThreadBlock:^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:RStr(@"Close") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
                
        id rootViewController = viewController;
        if (!viewController) {
            rootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
            if ([rootViewController isKindOfClass:UITabBarController.class]) {
                rootViewController = ((UITabBarController *)rootViewController).selectedViewController;
            } else if ([rootViewController isKindOfClass:UINavigationController.class]) {
                rootViewController = ((UINavigationController *)rootViewController).viewControllers.firstObject;
            } else {
                DLog(@"‼️ Не верный контроллер для отображения алерта");
            }
        }
        
        [rootViewController presentViewController:alertController animated:YES completion:nil];
    }];
}

+ (void) alertError:(NSError*)error target:(UIViewController* _Nullable)viewController
{
    [self alertInfoTitle:RStr(@"Error") message:error.localizedDescription target:viewController];
}

// Блок в главном потоке
+ (void) runMainThreadBlock:(void (^)(void))block
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
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
    NSInteger interval1970 = [[NSDate date] timeIntervalSince1970]; // секунд с 1970г
    NSString *str = [NSString stringWithFormat:@"%@%ld%@", @"As", interval1970/100, @"Tuda"]; // Отбросим 100 секунд
    NSString *hash = [self md5StringUpperCase:str lowerCase:YES];
    //DLog(@"Хэш строки\n%@\n%@", str, hash);
    return hash;

}
@end
