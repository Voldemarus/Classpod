//
//  Music+CoreDataProperties.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "Music+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Music (CoreDataProperties)

+ (NSFetchRequest<Music *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *fileName;
@property (nullable, nonatomic, copy) NSString *fileURL;
@property (nullable, nonatomic, retain) NSSet<ClassPod *> *classes;

@end

@interface Music (CoreDataGeneratedAccessors)

- (void)addClassesObject:(ClassPod *)value;
- (void)removeClassesObject:(ClassPod *)value;
- (void)addClasses:(NSSet<ClassPod *> *)values;
- (void)removeClasses:(NSSet<ClassPod *> *)values;

@end

NS_ASSUME_NONNULL_END
