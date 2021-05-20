//
//  SpotifyDAO.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 20.05.2021.
//

#import <Foundation/Foundation.h>
#import <SpotifyiOS/SpotifyiOS.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpotifyDAO : NSObject

+ (SpotifyDAO *) sharedInstance;

@property (nonatomic, retain) SPTAppRemote *appRemote;

@end

NS_ASSUME_NONNULL_END
