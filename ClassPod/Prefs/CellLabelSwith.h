//
//  CellLabelSwith.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CellLabelSwithID;
extern NSString * const CellLabelButtonID;

@interface CellLabelSwith : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel * name;
@property (weak, nonatomic) IBOutlet UISwitch * swith;
@property (weak, nonatomic) IBOutlet UIButton * button;

@end

NS_ASSUME_NONNULL_END
