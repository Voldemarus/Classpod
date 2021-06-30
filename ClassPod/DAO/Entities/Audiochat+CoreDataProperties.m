//
//  Audiochat+CoreDataProperties.m
//  
//
//  Created by Водолазкий В.В. on 30.06.2021.
//
//

#import "Audiochat+CoreDataProperties.h"

@implementation Audiochat (CoreDataProperties)

+ (NSFetchRequest<Audiochat *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Audiochat"];
}

@dynamic timestamp;
@dynamic duration;
@dynamic filename;
@dynamic uuid;
@dynamic teacher;
@dynamic student;
@dynamic classpod;

@end
