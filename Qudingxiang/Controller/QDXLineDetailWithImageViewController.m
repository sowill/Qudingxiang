//
//  QDXLineDetailWithImageViewController.m
//  趣定向
//
//  Created by Air on 2017/1/11.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QDXLineDetailWithImageViewController.h"

@interface QDXLineDetailWithImageViewController ()

@property (strong, nonatomic) UIImageView *coverImageView;

@property (strong, nonatomic) UIImageView *detailImageView;

@property (strong, nonatomic) NSLayoutConstraint *detailImageUpCons;

@end

@implementation QDXLineDetailWithImageViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        self.fadeBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            [strongSelf.view layoutIfNeeded];
            
            strongSelf.detailImageUpCons.constant = 0;
            [UIView animateWithDuration:0.45 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                strongSelf.detailImageView.alpha = 1;
                [strongSelf.view layoutIfNeeded];
                
            }completion:nil];
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = QDXBGColor;
    
    self.coverImageView.image = _coverImage;
    
    self.detailImageView.alpha = 0;
    self.detailImageUpCons.constant = 25;
    [self.view layoutIfNeeded];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
