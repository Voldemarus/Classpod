//
//  Teacher+CoreDataClass.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ClassPod;

NS_ASSUME_NONNULL_BEGIN

@interface Teacher : NSManagedObject

+ (Teacher * _Nonnull) getOrCgeateWithService:(NSNetService *)service inMoc:(NSManagedObjectContext *)moc;
+ (Teacher * _Nullable) getByName:(NSString *)name inMoc:(NSManagedObjectContext *)moc;

// Only RAM^ no need save to disk
@property (nonatomic, retain) NSNetService * _Nullable service;

@end

NS_ASSUME_NONNULL_END

#import "Teacher+CoreDataProperties.h"
