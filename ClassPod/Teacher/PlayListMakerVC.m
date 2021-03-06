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
@property (weak, nonatomic) IBOutlet UIView *activityView;

@end

@implementation PlayListMakerVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.tableMusic.editing = YES;
    self.activityView.alpha = 0.0;
}

- (void) setClassPod:(ClassPod *)classPod
{
    _classPod = classPod;
    [self loadArrayMediaItemsFromClasspod];
}

- (void) loadArrayMediaItemsFromClasspod
{
    // заполнить массив по сохраненным песням
    if (arrayMediaItems) {
        [arrayMediaItems removeAllObjects];
    } else {
        arrayMediaItems = [NSMutableArray new];
    }

    NSArray *arrayMusic = self.classPod.musics.array;
    for (NSInteger i = 0; i < arrayMusic.count; i++) {
        Music * music = arrayMusic[i];
        NSString *fileName = music.fileName;
        if (fileName.length > 0) {
            MPMediaQuery * songQuery = [MPMediaQuery new];
            MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:fileName forProperty:MPMediaItemPropertyPersistentID];;
            [songQuery addFilterPredicate: predicate];
            NSArray <MPMediaItem *>* findItems = songQuery.items;
            if (findItems.count > 0) {
                [arrayMediaItems addObject:findItems[0]];
            }
        }
    }
    [self.tableMusic reloadData];
}

- (void) synchronizationMediaAddClassPod
{
    [self.classPod deleteAllMusicAndDeleteFile:NO];
    for (NSInteger i = 0; i < arrayMediaItems.count; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%llu", arrayMediaItems[i].persistentID];
        [self.classPod addMusicName:fileName];
    }
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

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(nonnull NSIndexPath *)fromIndexPath toIndexPath:(nonnull NSIndexPath *)toIndexPath
{
    
//    if (fromIndexPath && toIndexPath) {
        MPMediaItem *item = arrayMediaItems[fromIndexPath.row];
        
        [arrayMediaItems removeObject:item];
        [arrayMediaItems insertObject:item atIndex:toIndexPath.row];
        [self synchronizationMediaAddClassPod];
//    }
}

- (UISwipeActionsConfiguration*) tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:RStr(@"Delete") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        MPMediaItem *item = arrayMediaItems[indexPath.row];
        [arrayMediaItems removeObjectAtIndex:row];
        [self synchronizationMediaAddClassPod];
        [self.tableMusic reloadData];
        
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UISwipeActionsConfiguration *swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    swipeActions.performsFirstActionWithFullSwipe = NO;
    return swipeActions;
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
    [arrayMediaItems addObjectsFromArray:mediaItemCollection.items.mutableCopy];
    [self synchronizationMediaAddClassPod];

    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.tableMusic reloadData];
}

- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    
    DLog(@"🐝 mediaPickerDidCancel %@", mediaPicker);

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) buttonUploadPressed:(id)sender
{
    
    DLog(@"🐝 Запуск конвертирования %ld файлов", arrayMediaItems.count);
    
    self.activityView.alpha = 1.0;
        
    [Utils createMP3FromMediaItems:arrayMediaItems blockCurrentFile:^(NSString * _Nullable fileWithPath) {
    
        DLog(@"🦋 добавлен файл: %@", fileWithPath.lastPathComponent);
        
    } completion:^(NSArray<NSURL *> * _Nonnull arrayUrls, NSDictionary * _Nonnull dictParams, NSURL * _Nullable urlMusicDB) {
        
        DLog(@"🐝 готовы все %ld из %ld%@", arrayUrls.count, arrayMediaItems.count, arrayUrls.count != arrayMediaItems.count ? @" ‼️ Не все обработались ‼️":@"");
        NSMutableArray <NSURL *> * arrayUslsSend = arrayUrls.mutableCopy;
        if (urlMusicDB) {
            // На сервер надо так же передать плейлист в json
            [arrayUslsSend addObject:urlMusicDB];
        }
        [LDWWWTools.sharedInstance getListExistMusicOnServerCompletion:^(NSError * _Nonnull error, NSDictionary * _Nonnull dictMusic) {
            
            for (NSInteger i = 0; i < arrayUrls.count; i++) {
                NSURL *url = arrayUrls[i];
                NSString *fileName = url.lastPathComponent;
                NSDictionary *dServer = dictMusic[fileName];
                NSDictionary *dLocal = dictParams[fileName];
                DLog(@"🦋 1 проверяем Файл %@  (%@ %@)", fileName, dServer.class, dLocal.class);
                if ([dServer isKindOfClass:NSDictionary.class] && [dLocal isKindOfClass:NSDictionary.class]) {
                    NSNumber *nLocal = dLocal[@"filesize"];
                    NSNumber *nServer = dServer[@"filesize"];
                    DLog(@"🦋 2 проверяем Файл %@  (%@ %@)", fileName, nLocal, nServer);
                    if (nLocal && nServer && nLocal.integerValue > 0 && nLocal.integerValue == nServer.integerValue ) {
                        DLog(@"🦋 Файл %@ есть на сервере, не грузим его", fileName);
                        [arrayUslsSend removeObject:url];
                    }
                }
            }
            
            [self uploadUrls:arrayUslsSend];
        }];
    }];
}

- (void) excludeExistingFile
{
    
}

- (void) uploadUrls:(NSArray*)urls
{
    DLog(@"🦋 Выгрузка на сайт файлов: %ld", urls.count);
    
    [LDWWWTools.sharedInstance saveToWWWFilesWithUrls:urls cursor:0 error:nil completion:^(NSError *error) {
        
        if (error) {
            DLog(@"‼️ Ошибка выгрузки прайса");
            [Utils alertError:error target:self];
        } else {
            [Utils runMainThreadBlock:^{
                self.activityView.alpha = 0.0;
            }];
            
            ALog(@"🦋 Выгрузка всех файлов на сервер завершена. ‼️ Теперь надо уведомить девайсы учеников перезапустить плеер");
            [Utils alertInfoTitle:RStr(@"Upload audio completed") message:[NSString stringWithFormat:RStr(@"All audio files uploaded to server")] target:self];
        }

    }];
}


@end
