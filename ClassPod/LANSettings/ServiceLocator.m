//
//  ServiceLocator.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 05.05.2021.
//


#import <stdbool.h>  // true/false
#import <stdint.h>   // UINT8_MAX
#import <stdio.h>    // fprintf()
#import <stdlib.h>   // EXIT_SUCCESS
#import <string.h>   // strerror()

#import <errno.h>   // errno
#import <fcntl.h>   // fcntl()
#import <mach/vm_param.h>  // PAGE_SIZE
#import <unistd.h>  // close()

#import <arpa/inet.h>     // inet_ntop()
#import <netdb.h>         // gethostbyname2()
#import <netinet/in.h>    // struct sockaddr_in
#import <netinet6/in6.h>  // struct sockaddr_in6
#import <sys/socket.h>    // socket(), AF_INET
#import <sys/types.h>     // random types


#import "ServiceLocator.h"
#import "Preferences.h"

NSString * const VVVServiceType     =   @"_classpod._tcp";
NSString * const VVVserviceDomain   =   @"local.";

static const int kAcceptQueueSizeHint = 8;

static int StartListening (int *portNum);

@interface ServiceLocator () <NSNetServiceDelegate, NSNetServiceBrowserDelegate>
{
    BOOL moreComing;
    NSInteger servicePort;  // to make individual connection

    struct sockaddr_in *serverAddr;
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


- (void) publishService
{
    if (self.classProvider) {
        int portNum;
        StartListening(&portNum);           // Create and bind socket
        
        // we are working in service provider mode now.
        // port will be assigned dynamically
        NSString *serviceName = (self.name ? self.name : @"FIX ME!");
        self.service = [[NSNetService alloc] initWithDomain:VVVserviceDomain type:VVVServiceType name:serviceName port:portNum];
        [self.service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.service.delegate = self;
        NSNetServiceOptions options = NSNetServiceNoAutoRename | NSNetServiceListenForConnections;
        [self.service publishWithOptions:options];
    }
}

- (void) stopService
{
    if (self.service) {
        [self.service stop];
        self.service = nil;
    }
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

- (void)netServiceDidPublish:(NSNetService *)sender
{
    servicePort = sender.port;
    DLog(@"Service : %@",sender.name);
    DLog(@"Type    : %@", sender.type);
    DLog(@"Domain  : %@", sender.domain);
    DLog(@"Host    : %@", sender.hostName);
    DLog(@"Port No : %ld", (long)servicePort);
    NSArray <NSData *> *addrArray = sender.addresses;
    DLog(@"Addresses : ");
    for (NSData *addr in addrArray) {
        // address is a sockaddr struct stored as NSData
        const struct sockaddr *gen = [addr bytes];
        int fam = gen->sa_family;
        DLog(@"%s: family %d", __func__, fam);
        if (AF_INET == fam) {
            memcpy(serverAddr, gen, sizeof(const struct sockaddr));
            char *ip = inet_ntoa(serverAddr->sin_addr);
            NSString *ipStr = [[NSString alloc] initWithCString:ip encoding:NSUTF8StringEncoding];
            DLog(@"IP4 address - %@",ipStr);
            break;
        }
    }
    
}


#pragma mark - C Helpers

// Returns fd on success, -1 on error.  Based on main() in simpleserver.m
static int StartListening (int *portNum) {
    // get a socket
    int fd = socket (AF_INET, SOCK_STREAM, 0);

    if (fd == -1) {
        perror ("*** socket");
        goto bailout;
    }

    // Reuse the address so stale sockets won't kill us.
    int yes = 1;
    int result = setsockopt (fd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
    if (result == -1) {
        perror("*** setsockopt(SO_REUSEADDR)");
        goto bailout;
    }

    // Bind to an address and port
    struct sockaddr_in sin;

    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_len = sizeof(sin);
    sin.sin_port = 0;       // Auto assign mode

    result = bind (fd, (struct sockaddr *)&sin, sin.sin_len);
    if (result == -1) {
        perror("*** bind");
        goto bailout;
    }

    socklen_t addrLen = sizeof(sin);
    result = getsockname(fd, (struct sockaddr *)&sin, &addrLen);
    if (result == -1) {
        perror("*** listen");
        goto bailout;
    }

    result = listen (fd, kAcceptQueueSizeHint);
    if (result == -1) {
        perror("*** listen");
        goto bailout;
    }
    *portNum = sin.sin_port;
    printf("listening on port %d\n", *portNum);
    return fd;

bailout:
    if (fd != -1) {
        close(fd);
        fd = -1;
    }
    return fd;
}  // StartListening



@end
