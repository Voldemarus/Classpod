//
//  ClassPod+CoreDataProperties.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "ClassPod+CoreDataProperties.h"

@implementation ClassPod (CoreDataProperties)

+ (NSFetchRequest<ClassPod *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"ClassPod"];
}

@dynamic name;
@dynamic dateStarted;
@dynamic note;
@dynamic teacher;
@dynamic students;
@dynamic music;
@dynamic audios;

@end
