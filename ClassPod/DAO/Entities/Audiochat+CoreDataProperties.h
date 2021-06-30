//
//  Audiochat+CoreDataProperties.h
//  
//
//  Created by Водолазкий В.В. on 30.06.2021.
//
//

#import "Audiochat+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Audiochat (CoreDataProperties)

+ (NSFetchRequest<Audiochat *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *timestamp;
@property (nonatomic) double duration;
@property (nullable, nonatomic, copy) NSString *filename;
@property (nullable, nonatomic, copy) NSString *uuid;

@property (nullable, nonatomic, retain) Teacher *teacher;
@property (nullable, nonatomic, retain) Student *student;
@property (nullable, nonatomic, retain) ClassPod *classpod;

@end

NS_ASSUME_NONNULL_END
