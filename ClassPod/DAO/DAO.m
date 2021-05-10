//
//  DAO.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 21.10.2020.//
//  Copyright © 2019 Dmitry Likhtarov. All rights reserved.
//

#import "DAO.h"
//#import "Preferences.h"

@interface DAO ()
{
//    Preferences 	*prefs;
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
//        prefs = [Preferences sharedPreferences];
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
        context = self.persistentContainer.viewContext;
    }

#ifdef DEBUG
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
 
// индикатор активности сети.
- (void) networkActivityIndicatorVisible:(BOOL)startRomashka
{
#ifdef USING_IOS
    [self runMainThreadBlock:^{
        [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:startRomashka];
    }];
#else
#endif
}
+ (void) networkActivityIndicatorVisible:(BOOL)startRomashka
{
#ifdef USING_IOS
    [self runMainThreadBlock:^{
        [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:startRomashka];
    }];
#else
#endif
}

#pragma mark - Custom methods


@end
