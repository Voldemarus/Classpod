//
//  LDWWWTools.h
//
//  Created by Dmitry Likhtarov on 20.07.2018.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDWWWTools : NSObject

+ (LDWWWTools *) sharedInstance;

/**
 Рекурсивный метод записи на сервер
 @param urls - массив локальных URL к файлам для записи на сервер
 @param cursor - текущий курсор загрузки, при первом вызове передать 0
 @param errorTotal - последняя ошибка либо nil, при первом вызове передать nil
 @param completion - блок завершения и ошибка либо nil
 */
- (void) saveToWWWFilesWithUrls:(NSArray<NSURL*>*)urls
                         cursor:(NSInteger)cursor
                          error:(NSError*_Nullable)errorTotal
                     completion:(void (^ _Nullable)(NSError * _Nullable error))completion;

- (void) getListExistMusicOnServerCompletion:(void (^_Nullable)(NSError *error, NSDictionary * _Nonnull dictMusic))completion;

@end

NS_ASSUME_NONNULL_END
