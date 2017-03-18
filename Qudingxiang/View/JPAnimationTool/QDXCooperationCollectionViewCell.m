//
//  QDXCooperationCollectionViewCell.m
//  趣定向
//
//  Created by Air on 2017/3/6.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QDXCooperationCollectionViewCell.h"
#import "Partner.h"

@interface QDXCooperationCollectionViewCell()

@end

@implementation QDXCooperationCollectionViewCell

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
    self.cooperationImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, FitRealValue(250), FitRealValue(120))];
    [self.contentView addSubview:self.cooperationImage];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, FitRealValue(120 - 1), FitRealValue(250), FitRealValue(1))];
    line.backgroundColor = QDXLineColor;
    [self.contentView addSubview:line];
    
    UIView *lineTwo = [[UIView alloc] initWithFrame:CGRectMake(FitRealValue(250 -1), 0, FitRealValue(1), FitRealValue(120))];
    lineTwo.backgroundColor = QDXLineColor;
    [self.contentView addSubview:lineTwo];
}

-(void)setDataString:(Partner *)dataString{
    
    _dataString = dataString;
    
    [self.cooperationImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",newHostUrl,dataString.partner_logo]] placeholderImage:[UIImage imageNamed:@"合作单位默认图"]];
}

@end
