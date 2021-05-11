//
//  Student+CoreDataClass.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "Student+CoreDataClass.h"
#import "DebugPrint.h"


NSString * const STUDENT_UUID     =   @"Studentuuid";
NSString * const STUDENT_NAME     =   @"name";
NSString * const STUDENT_NOTE     =   @"note";
NSString * const STUDENT_TUIID    =   @"TeacherUUID";



@implementation Student

// No need to store it in database, should be valid during connection only
@synthesize socket;

- (NSData *) packetDataWithTeacherUUID:(NSUUID *) teacherId 
{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithDictionary:@{
        STUDENT_UUID    :   self.uuid,
        STUDENT_NAME    :   self.name,
        STUDENT_NOTE    :   self.note,
    }];
    if (teacherId) {
        d[STUDENT_TUIID] = teacherId;
    }
    NSError *error = nil;
    NSData *packedData = [NSJSONSerialization dataWithJSONObject:d options:0 error:&error];
    if (error) {
        DLog(@"cannot pack data - %@",d);
        DLog(@"Error returned - %@", [error localizedDescription]);
        return nil;
    }
    return packedData;
}

#pragma - Class methods -

+ (Student *) parseDataPacket:(NSData *)pack forTeacher:(NSUUID **)tUUID inMoc:(NSManagedObjectContext *)moc
{
    if (!pack) {
        return nil;
    }
    NSError *error = nil;
    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:pack options:0 error:&error];
    if (!d && error) {
        DLog(@"Cannot unpack - %@",[error localizedDescription]);
        return nil;
    }
    NSUUID *stuid = d[STUDENT_UUID];
    if (!stuid) {
        // this dictionary doesn't belong to student data
        return nil;
    }
    Student *rec = [Student getStudentByUUID:stuid inMoc:moc];
    if (!rec) {
        // No such record in database,create new record
        rec = [NSEntityDescription insertNewObjectForEntityForName:@"Student"
                                            inManagedObjectContext:moc];
        if (rec) {
            rec.name = d[STUDENT_NAME];
            rec.uuid = stuid;
            rec.note = d[STUDENT_NOTE];

            NSUUID *teachID = d[STUDENT_TUIID];
            if (teachID) {
                // teacherID is non empty - add student to class for this teacher
                *tUUID = teachID;
            }
        }
    }
    return rec;
}

+ (Student *) getStudentByUUID:(NSUUID *)aUid inMoc:(NSManagedObjectContext *)moc
{
    NSFetchRequest *req = [Student fetchRequest];
    req.predicate = [NSPredicate predicateWithFormat:@"uuid = %@", aUid];
    NSError *error = nil;
    NSArray <Student *> *res = [moc executeFetchRequest:req error:&error];
    if (!res && error) {
        DLog(@"Cannot get records for UUID >>%@<< -- %@", aUid, [error localizedDescription]);
        return nil;
    } else if (res.count > 0) {
        return res[0];
    } else {
        return nil;
    }
}

@end
