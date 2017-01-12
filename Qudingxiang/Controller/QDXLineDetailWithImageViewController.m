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

@property (strong, nonatomic) UIButton *backButton;

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
    
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(480))];
    self.coverImageView.image = _coverImage;
    [self.view addSubview:self.coverImageView];
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 22, 20, 18)];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"sign_return"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(buttonBackSetting) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.backButton];
    
    self.detailImageView.alpha = 0;
    self.detailImageUpCons.constant = 25;
    [self.view layoutIfNeeded];

}

-(void)buttonBackSetting
{
    if (self.closeBlock) {
        self.closeBlock(self);
    }
    self.view.alpha = 0;
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
