//
//  QDXSlideHeaderView.h
//  趣定向
//
//  Created by Air on 2016/11/25.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HeaderCellClick)(NSInteger index);

@interface QDXSlideHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame titleAry:(NSArray *)titleAry;

- (void)customHeaderCellClick:(HeaderCellClick)headerCellClick;

@end
