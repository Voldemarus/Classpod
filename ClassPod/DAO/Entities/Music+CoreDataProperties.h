//
//  Music+CoreDataProperties.h
//  
//
//  Created by Dmitry Likhtarov on 01.07.2021.
//
//

#import "Music+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Music (CoreDataProperties)

+ (NSFetchRequest<Music *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *fileName;
@property (nullable, nonatomic, retain) ClassPod *classPod;

@end

NS_ASSUME_NONNULL_END
