//
//  Music+CoreDataProperties.m
//  
//
//  Created by Dmitry Likhtarov on 01.07.2021.
//
//

#import "Music+CoreDataProperties.h"

@implementation Music (CoreDataProperties)

+ (NSFetchRequest<Music *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Music"];
}

@dynamic fileName;
@dynamic classPod;

@end
