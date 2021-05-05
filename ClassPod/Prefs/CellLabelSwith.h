//
//  CellLabelSwith.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 05.05.2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CellLabelSwithID;

@interface CellLabelSwith : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel * name;
@property (weak, nonatomic) IBOutlet UISwitch * swith;

@end

NS_ASSUME_NONNULL_END
