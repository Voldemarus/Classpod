//
//  ServiceLocator.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 05.05.2021.
//

#import "ServiceLocator.h"

NSString * const VVVServiceType     =   @"_chatter._tcp.";
NSString * const VVVserviceDomain   =   @"local.";


@interface ServiceLocator () <NSNetServiceDelegate, NSNetServiceBrowserDelegate>
{
    BOOL moreComing;
}

@property (nonatomic, retain) NSNetService *service;
@property (nonatomic, retain) NSNetServiceBrowser *browser;

- (BOOL) discover;  // blocks
- (BOOL) resolve;   // blocks

- (NSMutableData *) address;



@end

@implementation ServiceLocator

+ (ServiceLocator *) sharedInstance
{
    static ServiceLocator * __service = nil;
    if (!__service) {
        __service = [[ServiceLocator alloc] init];
    }
    return __service;
}

- (instancetype) init
{
    if (self = [super init]) {
        self.browser = [[NSNetServiceBrowser alloc] init];
        [self.browser setDelegate:self];

        moreComing = YES;

        NSLog(@"%s: discovering...", __func__);

        [self.browser searchForServicesOfType:VVVServiceType
                                 inDomain:VVVserviceDomain];
    }
    return self;
}


#pragma - NSNetServiceBrowser delegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{

}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    
}


#pragma mark - NSNetService delegate

- (void) netService: (NSNetService *) sender
      didNotPublish: (NSDictionary *) errorDict
{
    NSLog(@"Failed to publish service - %@",sender.name);
    NSLog(@"Error : %@", errorDict);
}


@end
