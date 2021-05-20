//
//  SceneDelegate.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 03.05.2021.
//

#import "DebugPrint.h"
#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "SpotifyDAO.h"

@interface SceneDelegate () <SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate>

@property (nonatomic, retain) SpotifyDAO *spDao;


@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    self.spDao = [SpotifyDAO sharedInstance];
}

// Spotify related callback
- (void) scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts
{
    if (!URLContexts || URLContexts.count == 0) {
        return;
    }
    NSURL * url = [URLContexts anyObject].URL;
    if (!url) {
        return;
    }

#warning MOVE to spDAO!

    SPTAppRemote *rapp = self.spDao.appRemote;
    NSDictionary *authParams = [rapp authorizationParametersFromURL:url];
    DLog(@"AuthParameters for Spotify - %@", authParams);

    NSString *authToken = authParams[SPTAppRemoteAccessTokenKey];
    if (authToken) {
        SPTAppRemoteConnectionParams *cparams = rapp.connectionParameters;
//        rapp.accessToken = authToken;
#warning !!!! Mybe cparams.accessToken = authToken; ??
        cparams.accessToken = authToken;
    } else {
        NSString *errDesc = authParams[SPTAppRemoteErrorDescriptionKey];
        DLog(@"Error - %@",errDesc);
    }
    rapp.delegate = self;
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.

    // Save changes in the application's managed object context when the application transitions to the background.
    [DAO.sharedInstance saveContext:nil];
}

#pragma mark SPTAppRemote delegate -




@end
