//
//  LogoCollectionViewCell.m
//  趣定向
//
//  Created by Air on 2017/3/7.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "LogoCollectionViewCell.h"
#import "Partner.h"

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

-(void)setLogo:(Partner *)logo
{
    _logo = logo;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",newHostUrl,logo.partner_logo]];
    UIImage *imagea = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
    [logoBtn setImage:imagea forState:UIControlStateNormal];
}

@end
