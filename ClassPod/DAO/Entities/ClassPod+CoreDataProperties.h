//
//  ClassPod+CoreDataProperties.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "ClassPod+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ClassPod (CoreDataProperties)

+ (NSFetchRequest<ClassPod *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *dateStarted;
@property (nullable, nonatomic, copy) NSString *note;
@property (nullable, nonatomic, retain) Teacher *teacher;
@property (nullable, nonatomic, retain) NSSet<Student *> *students;
@property (nullable, nonatomic, retain) NSSet<Music *> *music;
@property (nullable, nonatomic, retain) NSSet<Audiochat *> *audios;
@end

@interface ClassPod (CoreDataGeneratedAccessors)

- (void)addStudentsObject:(Student *)value;
- (void)removeStudentsObject:(Student *)value;
- (void)addStudents:(NSSet<Student *> *)values;
- (void)removeStudents:(NSSet<Student *> *)values;

- (void)addMusicObject:(Music *)value;
- (void)removeMusicObject:(Music *)value;
- (void)addMusic:(NSSet<Music *> *)values;
- (void)removeMusic:(NSSet<Music *> *)values;

- (void)addAudiosObject:(Audiochat *)value;
- (void)removeAudiosObject:(Audiochat *)value;
- (void)addAudios:(NSSet<Audiochat *> *)values;
- (void)removeAudios:(NSSet<Audiochat *> *)values;

@end

NS_ASSUME_NONNULL_END
