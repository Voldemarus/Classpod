//
//  PlayListMakerVC.m
//  ClassPod
//
//  Created by Dmitry Likhtarov on 21.06.2021.
//

#import "PlayListMakerVC.h"
#import "CellMusic.h"
#import "Utils.h"
#import "LDWWWTools.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PlayListMakerVC ()
<UITableViewDelegate, UITableViewDataSource,
MPMediaPickerControllerDelegate>
{
    NSMutableArray <MPMediaItem *>* arrayMediaItems;
    MPMediaPickerController * mediaPicker;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonClose;
@property (weak, nonatomic) IBOutlet UIButton *buttonMusicSelect;
@property (weak, nonatomic) IBOutlet UIButton *buttonUpload;
@property (weak, nonatomic) IBOutlet UITableView *tableMusic;

@end

@implementation PlayListMakerVC

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction) closePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma mark Table methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayMediaItems.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellMusic * cell = (CellMusic*)[tableView dequeueReusableCellWithIdentifier:CellMusicID forIndexPath:indexPath];
    
    MPMediaItem *song = arrayMediaItems[indexPath.row];
    cell.name1.text = song.title;
    cell.name2.text = song.artist;
    cell.iconAlbum.image = [Utils imageCoverSong:song size:cell.iconAlbum.frame.size];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

#pragma mark - Выбор треков для плейлиста

- (IBAction) selectMusicPressed:(id)sender
{
    // Выбрать музыку
    if (!mediaPicker) {
        mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        mediaPicker.showsCloudItems = NO; // Only local music
    }
    [self presentViewController: mediaPicker animated:YES completion:nil];
}

- (void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    arrayMediaItems = mediaItemCollection.items.mutableCopy;
    
//    if (arrayMediaItems .count < 1) {
//        return;
//    }
    
    for (NSInteger i = 0; i < arrayMediaItems.count; i++) {
        
        MPMediaItem *song = arrayMediaItems[i];
        
        DLog(@"\n🐝 title: %llu\n🐝 title: %@\n🐝 artist: %@\n🐝 album: %@", song.persistentID, song.title, song.artist, song.albumTitle);
        
        [Utils createMP3FromMediaItem:song completion:^(NSString * _Nullable fileName, NSString * _Nullable fileWithPath) {

            DLog(@"🐝 файл: %@,  %@(%@)", fileName, song.title, song.artist );

//            self.wakeUp.alarmMelody = filName;
//            self.wakeUp.alarmMelodyPersistentID = song.persistentID;

        }];
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.tableMusic reloadData];
    
}

- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    
    DLog(@"🐝 mediaPickerDidCancel %@", mediaPicker);

    [self dismissViewControllerAnimated:YES completion:nil ];
    //CODE
}

- (IBAction) buttonUploadPressed:(id)sender
{
    NSMutableArray <NSURL *>* urls = [NSMutableArray new];
    for (NSInteger i = 0; i < arrayMediaItems.count; i++) {
        NSString *fileWithPath =  mySoundFile([NSString stringWithFormat:@"%llu", arrayMediaItems[i].persistentID]);
        NSURL *url = [NSURL fileURLWithPath:fileWithPath];
        if (url && [NSFileManager.defaultManager fileExistsAtPath:fileWithPath]) {
            DLog(@"‼️ файл: %@  %@", fileWithPath, url);
            [urls addObject:url];
        }
    }
    DLog(@"‼️ Выгрузка на сайт файлов: %ld", urls.count);
    
    [LDWWWTools.sharedInstance saveToWWWFilesWithUrls:urls cursor:0 error:nil completion:^(NSError *error) {
        
        if (error) {
            DLog(@"‼️ Ошибка выгрузки прайса");
            [Utils alertError:error];
        } else {
            [Utils alertInfoTitle:RStr(@"Upload audio completed") message:[NSString stringWithFormat:RStr(@"All audio files uploaded to server")]];
        }

    }];
}


@end
