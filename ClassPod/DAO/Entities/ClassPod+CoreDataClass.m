//
//  ClassPod+CoreDataClass.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "ClassPod+CoreDataClass.h"

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

@end
