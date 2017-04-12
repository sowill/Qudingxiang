//
//  QDXStateView.h
//  趣定向
//
//  Created by Air on 2016/12/5.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StateDelegate <NSObject>
@optional

/** 重新加载数据 */
- (void)changeState;

@end

@interface QDXStateView : UIView

@property (nonatomic,strong) UIImageView *stateImg;

@property (nonatomic,strong) UILabel *stateDetail;

@property (nonatomic,strong) UIButton *stateButton;

@property (nonatomic,weak) id<StateDelegate> delegate;

@end
