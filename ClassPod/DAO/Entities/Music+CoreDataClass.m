//
//  Music+CoreDataClass.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "Music+CoreDataClass.h"

@implementation Music
//
//+ (Music * _Nonnull) getOrCgeateByFileName:(NSString *)fileName
//                                  classPod:(ClassPod*)classPod
//                                     inMoc:(NSManagedObjectContext *)moc
//{
//    NSAssert(fileName && classPod, @"‼️ fileName or classPod is empty!");
//
//    Music * music = [self getByFileName:fileName inMoc:moc];
//    if (!music) {
//        music = [NSEntityDescription insertNewObjectForEntityForName: NSStringFromClass(self.class) inManagedObjectContext:moc];
//        music.fileName = fileName;
//    }
//
//    [music addClassesObject:classPod];
//
//    return music;
//}
//
//+ (Music * _Nullable) getByFileName:(NSString *)fileName
//                              inMoc:(NSManagedObjectContext *)moc
//{
//    NSFetchRequest *req = [self fetchRequest];
//    req.predicate = [NSPredicate predicateWithFormat:@"fileName = %@", fileName];
//    NSError *error = nil;
//    NSArray <Music *> *res = [moc executeFetchRequest:req error:&error];
//    if (!res && error) {
//        DLog(@"‼️ Cannot get record Music for fileName >>%@<< error: %@", fileName, error.localizedDescription);
//        return nil;
//    }
//    return (res.count > 0) ? res[0] : nil;
//}

//- (void) deleteForClassPod:(ClassPod*)classPod
//{
//    if (classPod && [self.classes containsObject:classPod]) {
//        [self removeClassesObject:classPod];
//        if (self.classes.count == 0) {
//            // Больше ни с кем не связан, удалить файл
//            NSFileManager * fm = NSFileManager.defaultManager;
//            NSString * fileParh = self.fileURL;
//            if (fileParh.length > 0) {
//                if ([fm fileExistsAtPath:fileParh]) {
//                    [fm removeItemAtPath:fileParh error:nil];
//                }
//            }
//        }
//    }
//    [self.managedObjectContext deleteObject:self];
//}

@end
