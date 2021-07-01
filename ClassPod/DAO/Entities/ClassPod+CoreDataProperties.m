//
//  ClassPod+CoreDataProperties.m
//  
//
//  Created by Dmitry Likhtarov on 01.07.2021.
//
//

#import "ClassPod+CoreDataProperties.h"

@implementation ClassPod (CoreDataProperties)

+ (NSFetchRequest<ClassPod *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"ClassPod"];
}

@dynamic dateStarted;
@dynamic name;
@dynamic note;
@dynamic audios;
@dynamic music;
@dynamic students;
@dynamic teacher;

@end
