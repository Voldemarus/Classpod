//
//  SpotifyDAO.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 20.05.2021.
//

#import "SpotifyDAO.h"
#import "Preferences.h"


NSString * const SPOTIFY_CLIENT_ID      =   @"78714228917241b8b0513804bb22cf2f";

// FIX ME!!!
NSString * const SPOTIGY_REDIRECT_URL   =   @"spotify-ios-quick-start://spotify-login-callback";


#ifdef DEBUG
#define SP_LOG_LEVEL    SPTAppRemoteLogLevelDebug
#else
#define SP_LOG_LEVEL    SPTAppRemoteLogLevelNone
#endif


@interface SpotifyDAO ()

@property (nonatomic, retain) SPTConfiguration *configuration;

@end

@implementation SpotifyDAO


+ (SpotifyDAO *) sharedInsance
{
    static SpotifyDAO *__spDao = nil;
    of (!__spDao) {
        __spDao = [[SpotifyDAO alloc] init];
    }
    return __spDao;
}

- (instancetype) init
{
    if (self = [super init]) {
        self.configuration = [[SPTConfiguration alloc] initWithClientID:SPOTIFY_CLIENT_ID
                                                            redirectURL:[NSURL URLWithString:SPOTIGY_REDIRECT_URL]];

        self.appRemote = [[SPTAppRemote alloc] initWithConfiguration:self.configuration
                                                            logLevel:SP_LOG_LEVEL];
    }
    return self;
}

@end
