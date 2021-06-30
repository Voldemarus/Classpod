//
//  DAO.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 21.10.2020.//
//  Copyright © 2019 Dmitry Likhtarov. All rights reserved.
//

#import "DAO.h"
#import "DebugPrint.h"
#import "Preferences.h"

//#ifdef MAIN_APP_IOS
//#endif

// JSON keys for student request




@interface DAO ()
{
    Preferences * prefs;
}

@end

@implementation DAO

+ (DAO *) sharedInstance
{
    static DAO *_sharedDao = nil;
    if (!_sharedDao) {
        _sharedDao = [[DAO alloc] init];
    }
    return _sharedDao;
}

- (instancetype) init
{
    if (self = [super init]) {
        prefs = [Preferences sharedPreferences];
        _persistentContainerQueue = [[NSOperationQueue alloc] init];
        _persistentContainerQueue.maxConcurrentOperationCount = 1;
     }
    return self;
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSManagedObjectContext *)moc
{
    return self.persistentContainer.viewContext;
}

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"ClassPod"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                } else {
                    self->_persistentContainer.viewContext.automaticallyMergesChangesFromParent = true;
                }
            }];
        }
    }    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext:(NSManagedObjectContext* _Nullable)context
{
    if (!context) {
        context = self.moc;
    }

#ifdef DEBUG
#warning !!!!!!!!!! TEMPORALY disable write context !!!!
    DLog(@" 🌹🌹🌹🌹🌹🌹🌹🌹 ЗАПИСЬ отключена!");
    return;
    
    
    
    if (context == self.persistentContainer.viewContext) {
        DLog(@" 🌹🌹 Сохраненяется Основной контекст");
    } else {
        DLog(@" 🌹 Сохраненяется Другой0 контекст");
    }
#endif

    NSError *error;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

- (void)enqueueCoreDataBlock:(void (^)(NSManagedObjectContext* context))block completion:(void (^)(void))completion
{
    void (^blockCopy)(NSManagedObjectContext*) = [block copy];
    void (^completionCopy)(void) = [completion copy];
    [self.persistentContainerQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext* context =  self.persistentContainer.newBackgroundContext;
        [context performBlockAndWait:^{
            blockCopy(context); // внутри блока выполняем нужные операции в контексте
            NSError *error;
            if ([context hasChanges] && ![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            } else {
                DLog(@" 🌹 Фоновый контекст сохранен");
                if (completionCopy) {
                    // Блок завершения для операций, которые надо выполнять после сохранения контекста
                    completionCopy();
                }
            }
            
        }];
    }]];
}

#pragma mark -

- (void) runMainThreadBlock:(void (^)(void))block
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
+ (void) runMainThreadBlock:(void (^)(void))block
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#pragma mark - Custom methods

- (NSArray <Student *> * _Nonnull) studentsForCurrentTeacherOnlyConnected:(BOOL)onlyConnected
{
    NSFetchRequest *req = [Student fetchRequest];
    req.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    // all students in teacher mode belongs to the current teacher
    // as we fill database when clients subscribe to the service
    NSError *error = nil;
    NSArray <Student *> *result = [self.moc executeFetchRequest:req error:&error];
    if (!result && error) {
        DLog(@"Cannot get data from Student entity - %@", error.localizedDescription);
    }
    
    if (onlyConnected) {
        NSMutableArray *arrayConnected = [NSMutableArray new];
        for (Student *student in result) {
            if ([student.socket isConnected]) {
                [arrayConnected addObject:student];
            }
        }
        return arrayConnected;
    }
    
    return result ? result : @[];
    
}

- (NSArray <ClassPod *> * _Nonnull) allClassPodsForCurrentTeacher
{
    NSFetchRequest *req = [ClassPod fetchRequest];
    req.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSError *error = nil;
    NSArray <ClassPod *> *result = [self.moc executeFetchRequest:req error:&error].mutableCopy;
    if (!result && error) {
        DLog(@"‼️ Cannot get data from ClassPod entity - %@", error.localizedDescription);
        return @[];
    }
    return result ? result : @[];
}

//- (NSArray <Teacher *> *) teachersList
//{
//    NSFetchRequest *req = [Teacher fetchRequest];
//    NSError *error = nil;
//    NSArray <Teacher *> *result = [self.moc executeFetchRequest:req error:&error];
//    if (!result && error) {
//        DLog(@"Cannot get data from Teacher entity - %@",[error localizedDescription]);
//    }
//    if (result.count > 1) {
//        NSArray <Teacher *> *sortedArray = [result sortedArrayUsingComparator:^NSComparisonResult(  Teacher  *obj1, Teacher *obj2) {
//            return [obj1.name compare:obj2.name];
//        }];
//        return sortedArray;
//    }
//    return result;
//}

- (NSArray <Teacher *> *) teachersListWithService
{
    NSFetchRequest *req = [Teacher fetchRequest];
    req.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSError *error = nil;
    NSMutableArray <Teacher *> *result = [self.moc executeFetchRequest:req error:&error].mutableCopy;
    if (!result && error) {
        DLog(@"Cannot get data from Teacher entity - %@",[error localizedDescription]);
    }
    for (NSInteger i = result.count - 1; i >=0 ; i--) {
        Teacher *t = result[i];
        if (!t.service || t.uuid.length < 1) {
            [result removeObject:t];
        }
    }
    return result;
}

- (void) deleteClassPod:(ClassPod*)classPod
{
    if (!classPod) {
        DLog(@"‼️ Так быть не должно!");
        return;
    }
    NSManagedObjectContext *context = classPod.managedObjectContext;
    NSArray *
    array = classPod.students.allObjects;
    for (NSInteger i = 0; i < array.count; i++) {
        [context deleteObject:array[i]];
    }
    NSFileManager *fm = NSFileManager.defaultManager;
    array = classPod.music.allObjects;
    for (NSInteger i = 0; i < array.count; i++) {
        Music *music = array[i];
        NSString *strUrl = music.fileURL;
        NSURL *url = strUrl.length > 0 ? [NSURL fileURLWithPath:strUrl] : nil;
        if (url) {
            [fm removeItemAtURL:url error:nil];
        }
        [context deleteObject:music];
    }
    [context deleteObject:classPod];
}

//
// Returns student instance from the data packet, receiced from
// remote client, and places it into local CoreData database
//
- (Student *) studentWithData:(NSData *)aData forTeacherUUID:(NSString **)tUUID
{
    if (!aData) {
        return nil;
    }
    Student *std = [Student parseDataPacket:aData forTeacher:tUUID inMoc:self.moc];
    if (tUUID) {
        // teacher uuid is provided - link to proper class
        
    }
    return std;
}


- (NSData *) dataPackForStudent:(Student *)student
{
    NSData *d = [student packetDataWithTeacherUUID:nil];
    return d;
}

- (NSData *) dataPackForStudent:(Student *)student
                  withTeacherID:(NSString *)tUUID
{
    NSData *d = [student packetDataWithTeacherUUID:tUUID];
    return d;

}

// Получить или создать "студента" как свое устройство в префах. Для совместимости?
//
- (Student*) getOrCreateStudetnSelf
{
    Student * student = [Student getStudentByUUID:prefs.personalUUID inMoc:self.moc];
    if (!student) {
        student = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(Student.class) inManagedObjectContext:self.moc];
    }
    student.uuid = prefs.personalUUID;
    student.name = prefs.myName;
    student.note = prefs.note;

    return student;
}

/**
 Send play/stop command to student
 */
- (NSData *) packetDataPlayMusic:(BOOL)playMusic
{
    NSDictionary *d = @{
        STUDENT_PLAYMUSIC   :   @(playMusic),
    };
    NSError *error = nil;
    NSData *packedData = [NSJSONSerialization dataWithJSONObject:d options:0 error:&error];
    if (error) {
        DLog(@"cannot pack data - %@",d);
        DLog(@"Error returned - %@", [error localizedDescription]);
        return nil;
    }
    return packedData;
}

@end
