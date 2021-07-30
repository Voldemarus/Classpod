//
//  ViewController.m
//  MultiPeerTest
//
//  Created by Водолазкий В.В. on 29.07.2021.
//


#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *teacherButton;
@property (weak, nonatomic) IBOutlet UIButton *studentButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UIButton *b in @[_teacherButton, _studentButton]) {
        CALayer *l = b.layer;
        l.backgroundColor = [UIColor orangeColor].CGColor;
        l.borderColor = [UIColor darkGrayColor].CGColor;
        l.borderWidth = 2.0;
        l.cornerRadius = 6.0;
    }

}


@end
