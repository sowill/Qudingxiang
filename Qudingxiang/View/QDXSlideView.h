//
//  QDXSlideView.h
//  趣定向
//
//  Created by Air on 2016/11/25.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDXOrdermodel;

@interface QDXSlideView : UIView

@property (nonatomic,strong)void (^passBlock)();

@property (nonatomic,strong)void (^passWithValueBlock)(QDXOrdermodel *order);

-(instancetype)initWithFrame:(CGRect)frame titleAry:(NSArray *)titltAry;

@end
