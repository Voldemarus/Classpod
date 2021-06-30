//
//  Student+CoreDataProperties.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "Student+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, copy) NSString *note;
@property (nullable, nonatomic, retain) NSSet<ClassPod *> *classes;
@property (nullable, nonatomic, retain) NSSet<Audiochat *> *audios;
@end

@interface Student (CoreDataGeneratedAccessors)

- (void)addClassesObject:(ClassPod *)value;
- (void)removeClassesObject:(ClassPod *)value;
- (void)addClasses:(NSSet<ClassPod *> *)values;
- (void)removeClasses:(NSSet<ClassPod *> *)values;

- (void)addAudiosObject:(Audiochat *)value;
- (void)removeAudiosObject:(Audiochat *)value;
- (void)addAudios:(NSSet<Audiochat *> *)values;
- (void)removeAudios:(NSSet<Audiochat *> *)values;

@end

NS_ASSUME_NONNULL_END
