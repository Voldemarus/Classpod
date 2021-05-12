//
//  AppDelegate.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 03.05.2021.
//

#import "AppDelegate.h"
#import "ServiceLocator.h"
#import "Preferences.h"
#import "DAO.h"

@interface AppDelegate ()  <ServiceLocatorDelegate>
{
    ServiceLocator *srl;
    Preferences *prefs;
    DAO *dao;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    prefs = [Preferences sharedPreferences];
    dao = [DAO sharedInstance];

    srl = [ServiceLocator sharedInstance];
    srl.delegate = self;
 //   if (prefs.teacherModeON) {
        [self startService];
//    } else {
//        [self browseServices];
//    }

    return YES;
}


- (void) applicationDidEnterBackground:(UIApplication *)application
{
    [prefs flush];
}

- (void) applicationWillTerminate:(UIApplication *)application
{
    [prefs flush];
}


- (void) startService
{
    NSString *clName = [NSString stringWithFormat:@"Classpod %@",prefs.myName];
    srl.classProvider = YES;
    srl.name = clName;
    [srl publishService];
}

- (void) browseServices
{
    srl.classProvider = NO;
    srl.name = prefs.myName;
    [srl startBrowsing];
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
