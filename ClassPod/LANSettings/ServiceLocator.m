//
//  ServiceLocator.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 05.05.2021.
//


#import "ServiceLocator.h"
#import "Preferences.h"
#import "DebugPrint.h"

NSString * const VVVServiceType     =   @"_classpod._tcp";
NSString * const VVVserviceDomain   =   @"local.";


@interface ServiceLocator () <NSNetServiceDelegate, GCDAsyncSocketDelegate, NSNetServiceBrowserDelegate>
{
    BOOL moreComing;
    NSInteger servicePort;  // to make individual connection

    Preferences *prefs;
    DAO         *dao;
    NSMutableData *dataBuffer;
}

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
        
        prefs = [Preferences sharedPreferences];
        dao = [DAO sharedInstance];
        
        dataBuffer = [NSMutableData data];
        self.clientArray = [NSMutableArray new];
        moreComing = YES;
        
        NSLog(@"%s: discovering...", __func__);
        
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
            
            NSDictionary *dict = @{
                TEACHER_RATE        :   @(prefs.rate).stringValue,
                TEACHER_NOTE        :   prefs.note,
                TEACHER_UUID        :   prefs.personalUUID,
                TEACHER_COURSENAME  :   prefs.courseName,
            };
            NSData *data = [NSNetService dataFromTXTRecordDictionary:dict];
            [self.service setTXTRecordData:data];
            
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
    DLog(@"stopService [%@]", self.service.name);
    if (self.service) {
        [self.service stop];
        self.service = nil;
        self.socket = nil;
    }
}

- (void) startBrowsing
{
    [self.browser searchForServicesOfType:VVVServiceType inDomain:VVVserviceDomain];
}

- (void) stopBrowsing
{
    [self.browser stop];
}

#pragma mark - NSNetServiceBrowser delegate

- (void) netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    DLog(@"Service found - %@ (Есть еще: %@)", service.name, moreComing?@"ДА":@"НЕТ");
    
    if (service) {
        [self.clientArray addObject:service];
        service.delegate = self;
        [service startMonitoring];
        [service resolveWithTimeout:30.0f];
    }
    
    if (!moreComing) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didChangedServises:)]) {
            [self.delegate didChangedServises:self.clientArray];
        }
    }
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    DLog(@"Service removed - %@ (Есть еще: %@)", service.name, moreComing?@"ДА":@"НЕТ");

    if (service) {
        [self.clientArray removeObject:service];
        [service stopMonitoring];
    }

    if (!moreComing) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didChangedServises:)]) {
            [self.delegate didChangedServises:self.clientArray];
        }
    }
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict
{
    DLog(@"didNotSearch: %@", errorDict);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangedServises:)]) {
        [self.delegate didChangedServises:self.clientArray];
    }
}

#pragma mark - NSNetService Delegate

- (void) netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    DLog(@"Find TXT for %@", sender.name);
    
#ifdef DEBUG
    NSDictionary * dict = [NSNetService dictionaryFromTXTRecordData:data];
    for (NSString *key in dict.allKeys) {
        NSData *d = dict[key];
        NSString * s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        ALog(@"%10s : %@", key.UTF8String, s);
    }
#endif
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeTXTRecordData:withServise:)]) {
        [self.delegate didChangeTXTRecordData:data withServise:sender];
    }
    
}

- (void) netServiceDidResolveAddress:(NSNetService *)sender
{
    DLog(@"netService [%@] DidResolve [%ld] Addresses", sender.name, sender.addresses.count);
    
    [NSNotificationCenter.defaultCenter postNotificationName:@"netServiceDidResolveAddress" object:sender];
}

- (void) netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    DLog(@"Did not resolved: %@", errorDict);
    
    sender.delegate = self;
}

- (void) netService: (NSNetService *) sender
      didNotPublish: (NSDictionary *) errorDict
{
    NSLog(@"Failed to publish service - %@",sender.name);
    NSLog(@"Error : %@", errorDict);
}

- (void)netServiceDidPublish:(NSNetService *)sender
{
    servicePort = sender.port;

#ifdef DEBUG
    DLog(@"Service    : %@", sender.name);
    ALog(@"Type       : %@", sender.type);
    ALog(@"Domain     : %@", sender.domain);
    ALog(@"Host       : %@", sender.hostName);
    ALog(@"Port No    : %ld", (long)servicePort);
    NSDictionary * dict = [NSNetService dictionaryFromTXTRecordData:sender.TXTRecordData];
    for (NSString *key in dict.allKeys) {
        NSData *d = dict[key];
        NSString * s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        ALog(@"%10s : %@", key.UTF8String, s);
    }
#endif
    
}

#pragma mark - Socket delegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    DLog(@"Accepted the new socked");
    
    self.socket = newSocket;

    [self.socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0f tag:0];
    if (self.delegate && [self.delegate respondsToSelector:@selector(newAbonentConnected:)]) {
        [self.delegate newAbonentConnected:newSocket];
    }
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {

    DLog(@"socket [%@] DidDisconnect with error:%@", socket, error.userInfo);

    if (self.socket == socket) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(abonentDisconnected:)]) {
            [self.delegate abonentDisconnected:error];
        }
     }
}

- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"Write data is done");
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Trying to read the data with tag - %ld",tag);

    [dataBuffer appendData:data];
    if ([sock socketAvailableBytes] == 0) {
        // All data has been gathered, try to extract info
        NSString *teacherUUID = nil;
        Student *student = [dao studentWithData:dataBuffer forTeacherUUID:&teacherUUID];
        if (student) {
            DLog(@"Student request accepted - %@", student);
            student.socket = sock;
            // process student here
            [NSNotificationCenter.defaultCenter postNotificationName:@"ОбновилсяСтудент" object:student];

        } else {
            NSError *error = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:dataBuffer options:0 error:&error];
            if (!error) {
                DLog(@"Received data - %@",jsonDict);
            } else {
                DLog(@"Cannot parse incoming packet - %@", [error localizedDescription]);
                NSString *tmp = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
                DLog(@"Data read - >>%@<<",tmp);
            }
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


@end
