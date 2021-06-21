//
//  Utils.h
//
//  Created by Dmitry Likhtarov on 15/08/2019.
//  Copyright © 2019 Dmitry Likhtarov. All rights reserved.
//
#ifndef Utils_h
#define Utils_h
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>


NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

// Путь для кэша Library/Caches
NSString* myCachesDirectory(void);
// Путь файла с именем name в локальном кэше Library/Caches/name
NSString* myCachesDirectoryFile(NSString * _Nonnull name);


// Путь для кэша мелодий по 30 секунд Library/Sound
NSString* mySoundDirectory(void);
// Путь файла с именем name в локальном кэше мелодий Library/Sound/name
NSString* mySoundFile(NSString * _Nonnull name);

// Записать файл из библиотеки локально и обрезать на 30 секунд,
// в блок вернем имя(не путь!) файла в Library/Sounds/fileName или имя мелодии по умолчанию
+ (void) createMP3FromMediaItem:(MPMediaItem*)song
                     completion:(void (^)(NSString * _Nullable fileName, NSString * _Nullable fileWithPath))completion;

// Картинка обложки песни(или альбома) с заданным размером
+ (UIImage*) imageCoverSong:(MPMediaItem*)song size:(CGSize)size;

// Найдем песню в медиатеке по сохраненному ранее ID
+ (MPMediaItem*) mediaItemForPersistentID:(MPMediaEntityPersistentID) persistentID;

// Наличие интернета
+ (BOOL) hasInternet;
+ (BOOL) hasInternetBezAlerta;

+ (void) alertInfoTitle:(NSString*)title message:(NSString*)message;
+ (void) alertError:(NSError*)error;

// Блок в главном потоке
+ (void) runMainThreadBlock:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
#endif
