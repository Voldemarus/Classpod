//
//  StudentVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import "StudentVC.h"
#import "ServiceLocator.h"

@interface StudentVC ()
{
    DAO *dao;
    Preferences *prefs;
    NSArray <Teacher*>* arrayTeachers;
    NSMutableDictionary <NSString*, GCDAsyncSocket*> * dictSockets;

    __weak IBOutlet UILabel * labelHeader;
    __weak IBOutlet UILabel * labelDetail;
    __weak IBOutlet UIButton * buttonExit;
}

@property (weak, nonatomic) IBOutlet UISwitch *swTeacherAudio;
@property (weak, nonatomic) IBOutlet UISwitch *swPersonalAudio;

@end

@implementation StudentVC

- (void) viewDidLoad
{
    [super viewDidLoad];

    dao = [DAO sharedInstance];
    prefs = [Preferences sharedPreferences];
    
    dictSockets = [NSMutableDictionary new];
    NSNotificationCenter * nc = NSNotificationCenter.defaultCenter;
    [nc addObserver:self selector:@selector(serviceDidResolveAddress:) name:@"netServiceDidResolveAddress" object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateUI];
}

- (void) updateUI
{
    [DAO runMainThreadBlock:^{
        labelDetail.text = [NSString stringWithFormat:@"\
Учитель: %@ \n\
Курс:    %@ \n\
оплата:  %.2f в час \n\
Note:    %@\n\
uuid:    %@",
                            self.teacher.name,
                            self.teacher.courseName,
                            self.teacher.hourRate,
                            self.teacher.note,
                            self.teacher.uuid
                            ];
        self.swTeacherAudio.on = self->prefs.audioTeacherON;
        self.swPersonalAudio.on = self->prefs.audioPersonalON;
    }];
}

- (void) setTeacher:(Teacher *)teacher
{
    _teacher = teacher;
//    NSNetService *service = teacher.service;
//    service.delegate = self;
//    [service resolveWithTimeout:30.0f];

    [self updateUI];
}

#pragma mark - post notif from NSNetService delegate

- (void) serviceDidResolveAddress:(NSNotification*)notif
{
    NSNetService *service = notif.object;
    DLog(@"netServiceDidResolveAddress %@: %@", service.name, service.addresses);
    [self connectWithService:service];
}

- (BOOL) connectWithService:(NSNetService*)service
{
    NSString *name = service.name;
    if (service.name.length < 1) {
        DLog(@"❗️ нет имени: %@", service);
        return NO;
    }
    
    BOOL isConnected = NO;
    
    NSArray* arrAddress = service.addresses.mutableCopy;
    
    GCDAsyncSocket * coSocket= dictSockets[name];
    
    
    if (!coSocket || !coSocket.isConnected) {
        
        GCDAsyncSocket * coSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //Connect
        while (!isConnected && arrAddress.count) {
            NSData* address= arrAddress[0];
            NSError* error;
            if ([coSocket connectToAddress:address error:&error]) {
                dictSockets[name] = coSocket;
                isConnected = YES;
                DLog(@"Connected: %@", name);
                
                [self sendIfoToSocket:coSocket];
                
            } else if (error) {
                DLog(@"Unable to connect with Device %@ userinfo %@", error, error.userInfo);
            } else {
                DLog(@"Непонятно что: %@", name);
            }
        }
    } else {
        isConnected = coSocket.isConnected;
    }
    
    
    return isConnected;
    
}

- (void) sendIfoToSocket:(GCDAsyncSocket*) socket
{
    Student * studentSelf = [dao getOrCreateStudetnSelf];
    NSData *dataPack = [dao dataPackForStudent:studentSelf];

    [socket writeData:dataPack withTimeout:-1.0f tag:0];
}

#pragma mark - Button pressed

- (IBAction) buttonExitPressed:(id)sender
{
    DLog(@"Exit pressed");
    [ServiceLocator.sharedInstance stopService];
    
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}


- (IBAction) switchPressed:(UISwitch*)sw
{
    if (sw == self.swTeacherAudio) {
        
        prefs.audioTeacherON = sw.on;
        
    } else if (sw == self.swPersonalAudio) {
        
        prefs.audioPersonalON = sw.on;
        
    }
}

@end
