//
//  Teacher+CoreDataClass.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#if !TARGET_OS_OSX
    #import <UIKit/UIKit.h>
#endif

@class ClassPod;

NS_ASSUME_NONNULL_BEGIN

@interface Teacher : NSManagedObject

+ (Teacher * _Nonnull) getOrCgeateWithService:(NSNetService *)service
                                        inMoc:(NSManagedObjectContext *)moc;

+ (Teacher* _Nonnull) getOrCgeateWithService:(NSNetService *)service
                                 withTXTData:(NSData*)data
                                       inMoc:(NSManagedObjectContext *)moc;

+ (Teacher* _Nonnull) getAndModyfyOrCreateWithUUID:(NSString * _Nonnull)uuid
                                           newName:(NSString *)name
                                           newNote:(NSString *)note
                                     newCourseName:(NSString *)courseName
                                       newHourRate:(CGFloat)hourRate
                                             inMoc:(NSManagedObjectContext *)moc;

+ (Teacher * _Nullable) getByName:(NSString *)name
                            inMoc:(NSManagedObjectContext *)moc;

+ (Teacher * _Nullable) getByUuid:(NSString *)uuid
                            inMoc:(NSManagedObjectContext *)moc;

// Only RAM^ no need save to disk
@property (nonatomic, retain) NSNetService * _Nullable service;

@end

NS_ASSUME_NONNULL_END

#import "Teacher+CoreDataProperties.h"
