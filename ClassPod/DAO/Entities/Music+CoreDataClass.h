//
//  Music+CoreDataClass.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ClassPod;

NS_ASSUME_NONNULL_BEGIN

@interface Music : NSManagedObject
//
//+ (Music * _Nonnull) getOrCgeateByFileName:(NSString *)fileName
//                                  classPod:(ClassPod*)classPod
//                                     inMoc:(NSManagedObjectContext *)moc;
//
//+ (Music * _Nullable) getByFileName:(NSString *)fileName
//                              inMoc:(NSManagedObjectContext *)moc;
@end

NS_ASSUME_NONNULL_END

#import "Music+CoreDataProperties.h"
