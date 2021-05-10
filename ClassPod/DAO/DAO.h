//
//  DAO.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 21.10.2020.//
//  Copyright © 2019 Dmitry Likhtarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Teacher+CoreDataClass.h"
#import "Student+CoreDataClass.h"
#import "Music+CoreDataClass.h"
#import "ClassPod+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface DAO : NSObject

@property (readonly, strong) NSPersistentContainer * persistentContainer; // Хранилище
@property (nonatomic, retain) NSManagedObjectContext * moc; // Основной контекст
@property (nonatomic, strong) NSOperationQueue * persistentContainerQueue; // Очередь фоновой записи локальной базы

+ (DAO *) sharedInstance;

- (void)saveContext:(NSManagedObjectContext* _Nullable)context;

// Обработка в фоновом контекст, по окончании запись в основной контекст
- (void)enqueueCoreDataBlock:(void (^)(NSManagedObjectContext* context))block completion:(void (^)(void))completion;

- (void) runMainThreadBlock:(void (^)(void))block; // Запустить в основном потоке
+ (void) runMainThreadBlock:(void (^)(void))block;


- (void) networkActivityIndicatorVisible:(BOOL)startRomashka; // индикатор активности сети.
+ (void) networkActivityIndicatorVisible:(BOOL)startRomashka; // индикатор активности сети.

@end

NS_ASSUME_NONNULL_END
