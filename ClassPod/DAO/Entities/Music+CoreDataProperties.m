//
//  Music+CoreDataProperties.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 10.05.2021.
//
//

#import "Music+CoreDataProperties.h"

@implementation Music (CoreDataProperties)

+ (NSFetchRequest<Music *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Music"];
}

@dynamic fileName;
@dynamic fileURL;
@dynamic classes;

@end
