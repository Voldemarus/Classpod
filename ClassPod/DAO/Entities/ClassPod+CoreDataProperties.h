//
//  ClassPod+CoreDataProperties.h
//  
//
//  Created by Dmitry Likhtarov on 01.07.2021.
//
//

#import "ClassPod+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ClassPod (CoreDataProperties)

+ (NSFetchRequest<ClassPod *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *dateStarted;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *note;
@property (nullable, nonatomic, retain) NSSet<Audiochat *> *audios;
@property (nullable, nonatomic, retain) NSOrderedSet<Music *> *musics;
@property (nullable, nonatomic, retain) NSSet<Student *> *students;
@property (nullable, nonatomic, retain) Teacher *teacher;

@end

@interface ClassPod (CoreDataGeneratedAccessors)

- (void)addAudiosObject:(Audiochat *)value;
- (void)removeAudiosObject:(Audiochat *)value;
- (void)addAudios:(NSSet<Audiochat *> *)values;
- (void)removeAudios:(NSSet<Audiochat *> *)values;

- (void)insertObject:(Music *)value inMusicsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMusicsAtIndex:(NSUInteger)idx;
- (void)insertMusics:(NSArray<Music *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMusicsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMusicsAtIndex:(NSUInteger)idx withObject:(Music *)value;
- (void)replaceMusicsAtIndexes:(NSIndexSet *)indexes withMusics:(NSArray<Music *> *)values;
- (void)addMusicsObject:(Music *)value;
- (void)removeMusicsObject:(Music *)value;
- (void)addMusics:(NSOrderedSet<Music *> *)values;
- (void)removeMusics:(NSOrderedSet<Music *> *)values;

- (void)addStudentsObject:(Student *)value;
- (void)removeStudentsObject:(Student *)value;
- (void)addStudents:(NSSet<Student *> *)values;
- (void)removeStudents:(NSSet<Student *> *)values;

@end

NS_ASSUME_NONNULL_END
