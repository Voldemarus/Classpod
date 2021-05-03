//
//  AppDelegate.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 03.05.2021.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

