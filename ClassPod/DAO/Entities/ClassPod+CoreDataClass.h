//
//  ClassPod+CoreDataClass.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Music, Student, Teacher;

NS_ASSUME_NONNULL_BEGIN

@interface ClassPod : NSManagedObject

+ (ClassPod* _Nonnull) getOrCgeateWithTeacher:(Teacher * _Nonnull)teacher
                                    nameIfNew:(NSString * _Nullable)newName
                                    noteIfNew:(NSString * _Nullable)newNote
                                        inMoc:(NSManagedObjectContext *)moc;

+ (ClassPod * _Nullable) getWithTeacher:(Teacher *)teacher
                                  inMoc:(NSManagedObjectContext *)moc;

@end

NS_ASSUME_NONNULL_END

#import "ClassPod+CoreDataProperties.h"
