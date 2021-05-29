//
//  Teacher+CoreDataClass.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "Teacher+CoreDataClass.h"
#import "DebugPrint.h"
#import "DAO.h"

@implementation Teacher

@synthesize service; // only RAM

+ (Teacher* _Nonnull) getOrCgeateWithService:(NSNetService *)service inMoc:(NSManagedObjectContext *)moc
{
    
    NSDictionary * dict = [NSNetService dictionaryFromTXTRecordData:service.TXTRecordData];
    NSString * uuid = [[NSString alloc] initWithData:dict[TEACHER_UUID] encoding:NSUTF8StringEncoding];
    NSString * hourRate = [[NSString alloc] initWithData:dict[TEACHER_RATE] encoding:NSUTF8StringEncoding];
    NSString * note = [[NSString alloc] initWithData:dict[TEACHER_NOTE] encoding:NSUTF8StringEncoding];
    NSString * courseName = [[NSString alloc] initWithData:dict[TEACHER_COURSENAME] encoding:NSUTF8StringEncoding];
    NSString * name = service.name;

    Teacher * teacher;
    
    if (uuid.length > 0) {
        teacher = [Teacher getByUuid:uuid inMoc:moc];
    } else {
        teacher = [Teacher getByName:name inMoc:moc];
    }
    
    if (!teacher) {
        teacher = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(Teacher.class) inManagedObjectContext:moc];
        teacher.name = name;
    }
    
    if (uuid.length > 0) teacher.uuid = uuid;
    if (hourRate.length > 0) teacher.hourRate = hourRate.floatValue;
    if (note.length > 0) teacher.note = note;
    if (courseName.length > 0) teacher.courseName = courseName;

    teacher.service = service;
    
    return teacher;
}

+ (Teacher* _Nonnull) getOrCgeateWithService:(NSNetService *)service withTXTData:(NSData*)data inMoc:(NSManagedObjectContext *)moc
{
    
    NSDictionary * dict = [NSNetService dictionaryFromTXTRecordData:data];
    NSString * uuid = [[NSString alloc] initWithData:dict[TEACHER_UUID] encoding:NSUTF8StringEncoding];
    NSString * hourRate = [[NSString alloc] initWithData:dict[TEACHER_RATE] encoding:NSUTF8StringEncoding];
    NSString * note = [[NSString alloc] initWithData:dict[TEACHER_NOTE] encoding:NSUTF8StringEncoding];
    NSString * courseName = [[NSString alloc] initWithData:dict[TEACHER_COURSENAME] encoding:NSUTF8StringEncoding];
    NSString * name = service.name;

    Teacher * teacher;
    
    if (uuid.length > 0) {
        teacher = [Teacher getByUuid:uuid inMoc:moc];
    } else {
        teacher = [Teacher getByName:name inMoc:moc];
    }
    
    if (!teacher) {
        teacher = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(Teacher.class) inManagedObjectContext:moc];
        teacher.name = name;
    }
    
    if (uuid.length > 0) teacher.uuid = uuid;
    if (hourRate.length > 0) teacher.hourRate = hourRate.floatValue;
    if (note.length > 0) teacher.note = note;
    if (courseName.length > 0) teacher.courseName = courseName;

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

+ (Teacher * _Nullable) getByUuid:(NSString *)uuid inMoc:(NSManagedObjectContext *)moc
{
    if (uuid.length < 1) {
        DLog(@"‼️ Name is empty!");
        return nil;
    }
    
    NSFetchRequest *req = [self fetchRequest];
    req.predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
    NSError *error = nil;
    NSArray <Teacher *> *res = [moc executeFetchRequest:req error:&error];
    if (!res && error) {
        DLog(@"Cannot get Teacher for name: >>%@<< -- %@", uuid, error.localizedDescription);
        return nil;
    }

    return res.count > 0 ? res[0] : nil;
}

@end
