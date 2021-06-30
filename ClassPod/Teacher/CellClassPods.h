//
//  CellClassPods.h
//  ClassPod
//
//  Created by Dmitry Likhtarov on 30.06.2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CellClassPodsID;

@interface CellClassPods : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel * name;
@property (weak, nonatomic) IBOutlet UILabel * note;
@property (weak, nonatomic) IBOutlet UIImageView * imageClassPod;

@end

NS_ASSUME_NONNULL_END
