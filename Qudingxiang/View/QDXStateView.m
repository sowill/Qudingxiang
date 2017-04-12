//
//  QDXStateView.m
//  趣定向
//
//  Created by Air on 2016/12/5.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXStateView.h"

@implementation QDXStateView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // UI搭建
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI
{
    self.backgroundColor = QDXBGColor;
    
    _stateImg = [[UIImageView alloc] init];
    CGFloat stateImgCenterX = QdxWidth * 0.5;
    CGFloat stateImgCenterY = QdxHeight * 0.22;
    _stateImg.center = CGPointMake(stateImgCenterX, stateImgCenterY);
    _stateImg.bounds = CGRectMake(0, 0, FitRealValue(276), FitRealValue(198));
    [self addSubview:_stateImg];
    
    _stateDetail = [[UILabel alloc] init];
    _stateDetail.center = CGPointMake(stateImgCenterX, stateImgCenterY + FitRealValue(198/2 + 30/2 + 60));
    _stateDetail.bounds = CGRectMake(0, 0, QdxWidth, FitRealValue(30));
    _stateDetail.textColor = QDXGray;
    _stateDetail.font = [UIFont systemFontOfSize:14];
    _stateDetail.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_stateDetail];
    
    _stateButton = [[UIButton alloc] init];
    _stateButton.center = CGPointMake(stateImgCenterX, stateImgCenterY + FitRealValue(198/2 + 30 + 60 + 60 + 60/2));
    _stateButton.bounds = CGRectMake(0, 0, FitRealValue(200), FitRealValue(60));
    [_stateButton addTarget:self action:@selector(changeState) forControlEvents:UIControlEventTouchUpInside];
    [_stateButton setBackgroundImage:[ToolView createImageWithColor:QDXBlue] forState:UIControlStateNormal];
    [_stateButton setBackgroundImage:[ToolView createImageWithColor:QDXDarkBlue] forState:UIControlStateHighlighted];
    _stateButton.layer.borderWidth = 0.5;
    _stateButton.layer.cornerRadius = 2;
    _stateButton.layer.borderColor = [QDXBlue CGColor];
    [_stateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _stateButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:_stateButton];
}

/** 重新查看按钮点击 */
- (void)changeState{
    
    if ([self.delegate respondsToSelector:@selector(changeState)]) {
        [self.delegate changeState];
    }

}

@end
