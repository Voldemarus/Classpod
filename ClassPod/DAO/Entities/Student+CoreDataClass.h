//
//  Student+CoreDataClass.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GCDAsyncSocket.h"

@class ClassPod;

NS_ASSUME_NONNULL_BEGIN

@interface Student : NSManagedObject

@property (nonatomic, retain) GCDAsyncSocket * _Nullable socket;

/**
    Scan local database and return record about Student from data packet
    or create new record.
 */
+ (Student *) parseDataPacket:(NSData *)pack
                   forTeacher:(NSString *_Nullable * _Nullable)tUUID
                        inMoc:(NSManagedObjectContext *)moc;
/**
    Returns record for given UUID or nil, if no such record is present in the database
 */

+ (Student *) getStudentByUUID:(NSString *)aUUID
                         inMoc:(NSManagedObjectContext *)moc;

/**
 Packs current Studen' data into packet to stream.  if TeacherID is not empty, field with
 request to assign particular class is added.
 */
- (NSData *) packetDataWithTeacherUUID:(NSString * _Nullable) teacherId;


@end

NS_ASSUME_NONNULL_END

#import "Student+CoreDataProperties.h"
