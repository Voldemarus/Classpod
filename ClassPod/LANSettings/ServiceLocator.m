//
//  ServiceLocator.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 05.05.2021.
//


#import "ServiceLocator.h"
#import "Preferences.h"

NSString * const VVVServiceType     =   @"_classpod._tcp";
NSString * const VVVserviceDomain   =   @"local.";


@interface ServiceLocator () <NSNetServiceDelegate, GCDAsyncSocketDelegate, NSNetServiceBrowserDelegate>
{
    BOOL moreComing;
    NSInteger servicePort;  // to make individual connection

    NSMutableData *dataBuffer;
}

@property (nonatomic, retain) NSMutableArray *clientArray;
@property (nonatomic, retain) NSNetService *service;
@property (nonatomic, retain) NSNetServiceBrowser *browser;
@property (nonatomic, retain) GCDAsyncSocket *socket;

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

        dataBuffer = [NSMutableData data];
        self.clientArray = [NSMutableArray new];
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
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError* error = nil;
        if ([self.socket acceptOnPort:0 error:&error]) {
          NSString *serviceName = (self.name ? self.name : @"FIX ME!");
            self.service = [[NSNetService alloc] initWithDomain:VVVserviceDomain type:VVVServiceType name:serviceName port:self.socket.localPort];
            [self.service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            self.service.delegate = self;
            [self.service publishWithOptions:0];
        } else {
            NSLog(@"Unable to create socket. Error %@ with user info %@.", error, [error userInfo]);
        }
    }
}

- (void) stopService
{
    if (self.service) {
        [self.service stop];
        self.service = nil;
        self.socket = nil;
    }
}

#pragma - NSNetServiceBrowser delegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{

}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    
}

#pragma mark - Socket delegate

-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    self.socket= newSocket;

    [self.socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0f tag:0];
    if (self.delegate && [self.delegate respondsToSelector:@selector(newAbonentConnected:)]) {
        [self.delegate newAbonentConnected:newSocket];
    }
     NSLog(@"Accepted the new socked");
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {

    NSLog(@"%@", error.userInfo);

    if (self.socket == socket) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(abonentDisconnected:)]) {
            [self.delegate abonentDisconnected:error];
        }
     }


}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"Write data is done");
}


-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{

    NSLog(@"Trying to read the data");

    [dataBuffer appendData:data];
    if ([sock socketAvailableBytes] == 0) {
        // All data has been gathered, try to extract info
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:dataBuffer options:0 error:&error];
        if (!error) {
            NSLog(@"Received data - %@",jsonDict);
        } else {
            NSLog(@"Cannot parse incoming packet - %@", [error localizedDescription]);
            NSString *tmp = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
            NSLog(@"Data read - >>%@<<",tmp);
        }

          [dataBuffer setLength:0];
    }


    [sock readDataWithTimeout:-1.0f tag:0];

}

//-(GCDAsyncSocket*)getSelectedSocket
//{
//    NSNetService* coService =[self.clientArray objectAtIndex:self.selectedIndex];
//    return  [self.dictSockets objectForKey:coService.name];
//
//}


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
}



@end
