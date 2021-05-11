//
//  ServiceLocator.h
//  ClassPod
//
//  Created by Водолазкий В.В. on 05.05.2021.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ServiceLocatorDelegate  <NSObject>

@optional
- (void) newAbonentConnected:(GCDAsyncSocket *)newSocket;
- (void) abonentDisconnected:(NSError  * _Nullable )error;

@end

@interface ServiceLocator : NSObject

+ (ServiceLocator *) sharedInstance;

/**
    YEs if this device is originator of service
 */
@property (nonatomic) BOOL classProvider;

/**
    name of the class, associated with user name/specialisation
 */
@property (nonatomic, retain) NSString *name;

@property (nonatomic, assign) id <ServiceLocatorDelegate> delegate;

- (void) publishService;
- (void) stopService;

- (void) startBrowsing;



@end

NS_ASSUME_NONNULL_END
