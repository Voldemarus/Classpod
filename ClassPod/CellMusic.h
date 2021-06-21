//
//  CellMusic.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 21.06.2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CellMusicID;

@interface CellMusic : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel * name1;
@property (weak, nonatomic) IBOutlet UILabel * name2;
@property (weak, nonatomic) IBOutlet UIImageView * iconAlbum;

@end

NS_ASSUME_NONNULL_END
