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
#import "Audiochat+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const TEACHER_UUID       =   @"uuid";
static NSString * const TEACHER_RATE       =   @"hourRate";
static NSString * const TEACHER_NOTE       =   @"note";
static NSString * const TEACHER_COURSENAME =   @"courseName";

static NSString * const STUDENT_PLAYMUSIC  =   @"playMusic";

@interface DAO : NSObject

@property (readonly, strong) NSPersistentContainer * persistentContainer; // Хранилище
@property (nonatomic, retain) NSManagedObjectContext * moc; // Основной контекст
@property (nonatomic, strong) NSOperationQueue * persistentContainerQueue; // Очередь фоновой записи локальной базы

+ (DAO *) sharedInstance;

#pragma mark - App sepcific methods

/**
    List of students, assigned to current teacher
 */
- (NSArray <Student *> * _Nonnull) studentsForCurrentTeacherOnlyConnected:(BOOL)onlyConnected;

- (NSArray <ClassPod *> * _Nonnull) allClassPodsForCurrentTeacher;

/**
    List of teachers for student, Is filled during browsing and used to subscribe to particular teacher
 */

//- (NSArray <Teacher *> *) teachersList;
- (NSArray <Teacher *> *) teachersListWithService;

- (void) deleteClassPod:(ClassPod*)classPod;

/**
    Parse incoming packet as student, or return nil
 */
- (Student *) studentWithData:(NSData *)aData forTeacherUUID:(NSString *_Nullable*_Nullable)tUUID;


/**
        Converts Student instance into data packet
 */
- (NSData *) dataPackForStudent:(Student *)student;
- (NSData *) dataPackForStudent:(Student *)student withTeacherID:(NSString *)tUUID;

// Получить или создать "студента" как свое устройство в префах. Для совместимости?
//
- (Student*) getOrCreateStudetnSelf;

#pragma mark - Data for send commands

/**
 Send play/stop command to student
 */
- (NSData *) packetDataPlayMusic:(BOOL)playMusic;

#pragma mark - Unified methods

- (void)saveContext:(NSManagedObjectContext* _Nullable)context;

// Обработка в фоновом контекст, по окончании запись в основной контекст
- (void)enqueueCoreDataBlock:(void (^)(NSManagedObjectContext* context))block completion:(void (^)(void))completion;

- (void) runMainThreadBlock:(void (^)(void))block; // Запустить в основном потоке
+ (void) runMainThreadBlock:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
