//
//  CellTecherList.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 12.05.2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CellTecherListID;

@interface CellTecherList : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel * name;
@property (weak, nonatomic) IBOutlet UILabel * courseName;
@property (weak, nonatomic) IBOutlet UILabel * hourRate;
@property (weak, nonatomic) IBOutlet UILabel * note;
@property (weak, nonatomic) IBOutlet UIButton * buttonCheck;
@property (weak, nonatomic) IBOutlet UIImageView * imageCheck;

@end

NS_ASSUME_NONNULL_END
