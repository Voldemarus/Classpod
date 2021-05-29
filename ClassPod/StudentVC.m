//
//  StudentVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import "StudentVC.h"
#import "ServiceLocator.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "DebugPrint.h"


//NSString * const RADIO_URL = @"http://108.163.197.114:8155";
NSString * const RADIO_URL = @"https://dl.dropboxusercontent.com/s/jcq74691pet09d9/Chumbawamba%20-%20Tubthumping%20HD.mp3?dl=0";

@interface StudentVC () <AVPlayerViewControllerDelegate>
{
    DAO *dao;
    Preferences *prefs;
    NSArray <Teacher*>* arrayTeachers;
    NSMutableDictionary <NSString*, GCDAsyncSocket*> * dictSockets;

    __weak IBOutlet UILabel * labelHeader;
    __weak IBOutlet UILabel * labelDetail;
    __weak IBOutlet UIButton * buttonExit;
    __weak IBOutlet UIButton * buttonPlayStop;
}

@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) AVPlayerItem *playerItem;

@property (weak, nonatomic) IBOutlet UISwitch *swTeacherAudio;
@property (weak, nonatomic) IBOutlet UISwitch *swPersonalAudio;

@property (nonatomic, weak) IBOutlet UILabel *trackDetail;

@end

@implementation StudentVC

- (void) viewDidLoad
{
    [super viewDidLoad];

    dao = [DAO sharedInstance];
    prefs = [Preferences sharedPreferences];
    
    self.trackDetail.text = @"";
    
    dictSockets = [NSMutableDictionary new];
    NSNotificationCenter * nc = NSNotificationCenter.defaultCenter;
    [nc addObserver:self selector:@selector(serviceDidResolveAddress:) name:@"netServiceDidResolveAddress" object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateUI];
}

- (void) setTeacher:(Teacher *)teacher
{
    _teacher = teacher;
    NSNetService *service = teacher.service;
    [self connectWithService:service];
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

#pragma mark - post notif from NSNetService delegate

- (void) serviceDidResolveAddress:(NSNotification*)notif
{
    NSNetService *service = notif.object;
    [self connectWithService:service];
}

- (BOOL) connectWithService:(NSNetService*)service
{

    DLog(@"netServiceDidResolveAddress %@: %@", service.name, service.addresses);

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
                DLog(@"Connected: %@ [:%ld]", name, service.port);
                
                [self sendInfoToSocket:coSocket];
                
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

- (void) sendInfoToSocket:(GCDAsyncSocket*) socket
{
    Student * studentSelf = [dao getOrCreateStudetnSelf];
    studentSelf.socket = socket;
    NSData *dataPack = [dao dataPackForStudent:studentSelf];

    [socket writeData:dataPack withTimeout:-1.0f tag:0];
}

#pragma mark - Button pressed

- (IBAction) buttonExitPressed:(id)sender
{
    DLog(@"Exit pressed");
    Student * studentSelf = [dao getOrCreateStudetnSelf];
    [studentSelf.socket disconnect];
    studentSelf.socket = nil;
    
//    [ServiceLocator.sharedInstance stopService];
    
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

#pragma mark - AVPlayer receiver


- (void) turnAudioOn
{
    [self.playerItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:nil];
    [self.player play];
}

- (void) turnAudioOff
{
    [self.player pause];
    [self.playerItem removeObserver:self forKeyPath:@"timedMetadata"];
}

- (IBAction) playPauseButtonClicked:(id) sender
{
    UIButton *button = (UIButton *)sender;
    if (self.player.rate == 0.0) {
        if (!self.player) {
            NSURL *radioURL = [NSURL URLWithString:RADIO_URL];
            self.playerItem = [[AVPlayerItem alloc] initWithURL:radioURL];
            self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
         }
        [self turnAudioOn];
        [button setImage:[UIImage imageNamed:@"BT_Pause"] forState:UIControlStateNormal];
//        [button setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        [self turnAudioOff];
//        self.trackDetail.text = @"Waiting play...";
        [button setImage:[UIImage imageNamed:@"BT_Play"] forState:UIControlStateNormal];
//        [button setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"timedMetadata"]) {
        AVPlayerItem *_playerItem = (AVPlayerItem *)object;
        for (AVMetadataItem *mmd in _playerItem.timedMetadata) {
            if ([[mmd.key description] isEqualToString:@"title"]) {
                self.trackDetail.text = mmd.stringValue;
            }
        }
    } else {
        DLog(@"meta keyPath  - %@", keyPath);
    }
}

@end
