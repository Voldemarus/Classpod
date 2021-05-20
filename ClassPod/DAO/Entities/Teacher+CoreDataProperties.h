//
//  Teacher+CoreDataProperties.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "Teacher+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Teacher (CoreDataProperties)

+ (NSFetchRequest<Teacher *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *courseName;
@property (nonatomic) float hourRate;
@property (nullable, nonatomic, copy) NSString *note;
@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, retain) NSSet<ClassPod *> *classes;

@end

@interface Teacher (CoreDataGeneratedAccessors)

- (void)addClassesObject:(ClassPod *)value;
- (void)removeClassesObject:(ClassPod *)value;
- (void)addClasses:(NSSet<ClassPod *> *)values;
- (void)removeClasses:(NSSet<ClassPod *> *)values;

@end

NS_ASSUME_NONNULL_END
