//
//  ClassPod+CoreDataClass.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "ClassPod+CoreDataClass.h"
#import "Utils.h"

@implementation ClassPod

+ (ClassPod* _Nonnull) getOrCgeateWithTeacher:(Teacher * _Nonnull)teacher
                                    nameIfNew:(NSString * _Nullable)newName
                                    noteIfNew:(NSString * _Nullable)newNote
                                        inMoc:(NSManagedObjectContext *)moc
{
    
    NSAssert(teacher, @"‼️ Teacher is empty!");
    ClassPod * classpod = [self getWithTeacher:teacher inMoc:moc];
    if (!classpod) {
        classpod = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(ClassPod.class) inManagedObjectContext:moc];
        classpod.name = newName;
        classpod.note = newNote;
        classpod.teacher = teacher;
    }

    return classpod;
}

+ (ClassPod * _Nullable) getWithTeacher:(Teacher *)teacher
                                  inMoc:(NSManagedObjectContext *)moc
{
    if (!teacher) {
        DLog(@"‼️ Teacher is empty!");
        return nil;
    }
    
    NSFetchRequest *req = [self fetchRequest];
    req.predicate = [NSPredicate predicateWithFormat:@"teacher = %@", teacher];
    NSError *error = nil;
    NSArray <ClassPod *> *res = [moc executeFetchRequest:req error:&error];
    if (!res && error) {
        DLog(@"Cannot get ClassPod for teacher: >>%@<< -- %@", teacher.name, error.localizedDescription);
        return nil;
    }

    return res.count > 0 ? res[0] : nil;
}

- (void) deleteAllMusicAndDeleteFile:(BOOL)deleteFile
{
    NSOrderedSet<Music *>* musics = self.musics;
    if (musics.count > 0) {
        [self removeMusics:musics];
        NSManagedObjectContext *moc = self.managedObjectContext;
        for (NSInteger i = 0; i < musics.count; i++) {
            Music *music = musics[i];
            NSString * fileName = music.fileName;
            if (deleteFile && fileName.length > 0) {
                // удалить файл
                NSFileManager * fm = NSFileManager.defaultManager;
                NSString * fileParh = myCachesDirectoryFile(fileName);
                if (fileParh.length > 0 && [fm fileExistsAtPath:fileParh]) {
                    [fm removeItemAtPath:fileParh error:nil];
                }
            }
            [moc deleteObject:musics[i]];
        }
    }
}

- (Music * _Nonnull) addMusicName:(NSString * _Nonnull)fileName
{
    NSAssert(fileName, @"‼️ fileName is empty!");

    Music * music = [NSEntityDescription insertNewObjectForEntityForName: NSStringFromClass(Music.class) inManagedObjectContext:self.managedObjectContext];
    music.fileName = fileName;
    [self addMusicsObject:music];
    
    return music;
}


@end
