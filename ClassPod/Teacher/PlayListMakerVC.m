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
//    }
    
    
    
}

- (UISwipeActionsConfiguration*) tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:RStr(@"Delete") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        MPMediaItem *item = arrayMediaItems[indexPath.row];
        [arrayMediaItems removeObjectAtIndex:row];
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
    arrayMediaItems = mediaItemCollection.items.mutableCopy;
        
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
    
#warning need Edit!
        // TODO: На сервер надо так же передать плейлист по образу из php
        //       пока он создается на сервере и не учитывает последовательность в папке ./music/

    NSMutableSet <MPMediaItem *>* tempSet = [NSMutableSet new];
    NSMutableArray <MPMediaItem *>* newArray = [NSMutableArray new];
    for (NSInteger i = 0; i < arrayMediaItems.count; i++) {
        MPMediaItem * obj = arrayMediaItems[i];
        if (![tempSet containsObject:obj]) {
            [tempSet addObject:obj];
            [newArray addObject:obj];
        }
    }
    
    [Utils createMP3FromMediaItems:newArray blockCurrentFile:^(NSString * _Nullable fileWithPath) {
    
        DLog(@"🦋 добавлен файл: %@", fileWithPath.lastPathComponent);
        
    } completion:^(NSArray<NSURL *> * _Nonnull arrayUrls) {
        
        DLog(@"🐝 готовы все %ld из %ld%@", arrayUrls.count, newArray.count, arrayUrls.count != newArray.count ? @" ‼️ Не все обработались ‼️":@"");
        

        [self uploadUrls:arrayUrls];
    }];
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
