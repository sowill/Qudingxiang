//
//  ChoseCityCollectionViewCell.m
//  趣定向
//
//  Created by Air on 2017/3/6.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "ChoseCityCollectionViewCell.h"
#import "City.h"

@interface ChoseCityCollectionViewCell()
{
    UIButton *cityBtn;
}
@end

@implementation ChoseCityCollectionViewCell

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
    cityBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, FitRealValue(218), FitRealValue(80))];
    cityBtn.layer.borderWidth = 0.5;
    cityBtn.layer.cornerRadius = 3;
    cityBtn.layer.borderColor = [QDXGray CGColor];
    [cityBtn setTitleColor:QDXBlack forState:UIControlStateNormal];
    cityBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [cityBtn addTarget:self action:@selector(cityBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cityBtn];
}

-(void)setCity:(City *)city
{
    _city = city;
    
    [cityBtn setTitle:city.city_cn forState:UIControlStateNormal];
}

-(void)cityBtnClick
{
    if (self.btnBlock) {
        self.btnBlock();
    }
}

@end
