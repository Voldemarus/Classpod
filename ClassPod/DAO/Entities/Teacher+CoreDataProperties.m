//
//  Teacher+CoreDataProperties.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "Teacher+CoreDataProperties.h"

@implementation Teacher (CoreDataProperties)

+ (NSFetchRequest<Teacher *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Teacher"];
}

@dynamic name;
@dynamic courseName;
@dynamic hourRate;
@dynamic note;
@dynamic uuid;
@dynamic classes;
@dynamic audios;

@end
