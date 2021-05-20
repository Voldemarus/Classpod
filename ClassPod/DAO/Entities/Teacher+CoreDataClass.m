//
//  Teacher+CoreDataClass.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "Teacher+CoreDataClass.h"

@implementation Teacher

@synthesize service; // only RAM

+ (Teacher* _Nonnull) getOrCgeateWithService:(NSNetService *)service inMoc:(NSManagedObjectContext *)moc
{
    NSString *name = service.name;
    Teacher *teacher = [Teacher getByName:name inMoc:moc];
    if (!teacher) {
        teacher = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(Teacher.class) inManagedObjectContext:moc];
            teacher.name = name;

    }
    
    teacher.service = service;
    
    return teacher;
}

+ (Teacher * _Nullable) getByName:(NSString *)name inMoc:(NSManagedObjectContext *)moc
{
    if (name.length < 1) {
        DLog(@"‼️ Name is empty!");
        return nil;
    }
    
    NSFetchRequest *req = [self fetchRequest];
    req.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSError *error = nil;
    NSArray <Teacher *> *res = [moc executeFetchRequest:req error:&error];
    if (!res && error) {
        DLog(@"Cannot get Teacher for name: >>%@<< -- %@", name, error.localizedDescription);
        return nil;
    }

    return res.count > 0 ? res[0] : nil;
}

@end
