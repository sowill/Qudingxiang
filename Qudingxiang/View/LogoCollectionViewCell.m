//
//  LogoCollectionViewCell.m
//  趣定向
//
//  Created by Air on 2017/3/7.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "LogoCollectionViewCell.h"

@interface LogoCollectionViewCell()
{
    UIButton *logoBtn;
}
@end

@implementation LogoCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

-(void)setup
{
    logoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, FitRealValue(226), FitRealValue(140))];
    logoBtn.backgroundColor = [UIColor whiteColor];
    logoBtn.layer.borderWidth = 0.5;
    logoBtn.layer.cornerRadius = 3;
    logoBtn.layer.borderColor = [QDXGray CGColor];
    logoBtn.userInteractionEnabled = NO;
    [self.contentView addSubview:logoBtn];
}

-(void)setLogo:(NSString *)logo
{
    _logo = logo;
    [logoBtn setImage:[UIImage imageNamed:logo] forState:UIControlStateNormal];
}

@end
