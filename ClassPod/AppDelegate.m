//
//  AppDelegate.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 03.05.2021.
//

#import "AppDelegate.h"
#import "ServiceLocator.h"

@interface AppDelegate ()  <ServiceLocatorDelegate>
{
    ServiceLocator *srl;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

#warning FIX ME ! Debug only

    srl = [ServiceLocator sharedInstance];
    srl.classProvider = YES;
    srl.delegate = self;
    srl.name = @"ClassPod Voldemarus";
    [srl publishService];


    return YES;
}


#pragma mark - ServiceLocator delegate -


- (void) newAbonentConnected:(GCDAsyncSocket *)newSocket
{
    NSLog(@">>> New Abbonent  connected to the class!");
}

- (void) abonentDisconnected:(NSError *)error
{
    NSLog(@"Abonent disconnected");
    if (error) {
        NSLog(@"Error on disconnectig - %@", [error localizedDescription]);
    }
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
