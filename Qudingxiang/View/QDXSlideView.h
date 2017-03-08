//
//  QDXSlideView.h
//  趣定向
//
//  Created by Air on 2016/11/25.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeModel;

@interface QDXSlideView : UIView

@property (nonatomic,strong)NSArray *homeModelArray;

@property (nonatomic,strong)void (^passWithValueBlock)(HomeModel *order);

-(instancetype)initWithFrame:(CGRect)frame titleAry:(NSArray *)titltAry;

@end
