//
//  TabbarView.m
//  趣定向
//
//  Created by Prince on 16/4/29.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "TabbarView.h"
//#import "TipsManager.h"

@interface TabbarView()
// 加号按钮 存储的属性
@property (nonatomic, weak) UIButton *plusButton;

@end
@implementation TabbarView

#pragma mark - 4、监听方法------
// 点击加号按钮的时候调用
- (void)plusClick
{
//    NSLog(@"加号按钮点击事件");
//    [[TipsManager sharedInstance] showTips:@"加号按钮点击事件"];
    
    //如果tabbar的代理实现了对应的代理方法，那么就调用代理的该方法
    if ([self.delegate respondsToSelector:@selector(tabBarDidClickedPlusButton:)]) {
        [self.delegate tabBarDidClickedPlusButton:self];
    }
}

#pragma mark - 2、给tabBar内部bottom进行位置布局------

// self.items UITabBarItem模型，有多少个子控制器就有多少个UITabBarItem模型
// 调整子控件的位置
- (void)layoutSubviews
{
    [super layoutSubviews];
    // 取得tabBarItem的宽和高
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    // 设置按钮在tabBarItem内部的Frame
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = w / (self.items.count + 1);
    CGFloat btnH = self.bounds.size.height;
    NSUInteger i = 0;
    // 设置tabBarButton的frame
    for (UIView *tabBarButton in self.subviews) {
        NSLog(@"%@",NSStringFromClass([tabBarButton class]));
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            // 将加号按钮的位置腾出来
            if (i == 2) {
                i = 3;
            }
            btnX = i * btnW;
            tabBarButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
            i++;
        }
        
    }
    // 设置添加按钮的位置
    self.plusButton.center = CGPointMake(w * 0.5, h * 0.7 - 2*10);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        //        ----runtime - test----
        
        //        unsigned int count = 0;
        //        Ivar *ivarList = class_copyIvarList([UITabBar class], &count);
        //        for (int i =0; i<count; i++) {
        //            Ivar ivar = ivarList[i];
        //            LBLog(@"%s",ivar_getName(ivar));
        //        }
        
        //        [self setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]];
        self.backgroundColor = [UIColor whiteColor];
        //        [self setShadowImage:[UIImage imageWithColor:[UIColor whiteColor]]];

    }
    return self;
}

/// 关键的方法如果在加号里面返回YES
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if ([super pointInside:point withEvent:event]) {
        return [super pointInside:point withEvent:event];
    }else{
        CGRect rect = [self convertRect:self.plusButton.frame toView:self];
        return CGRectContainsPoint(rect, point);
    }
}

// 重写加号按钮的getter方法进行赋值
- (UIButton *)plusButton
{
    if (_plusButton == nil) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
//        [btn setImage:[UIImage imageNamed:@"tabbar_compose_icon_add_highlighted"] forState:UIControlStateNormal];
//        [btn setImage:[UIImage imageNamed:@"tabbar_compose_background_icon_add"] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[UIImage imageNamed:@"index_go"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"index_go"] forState:UIControlStateHighlighted];
        // 默认按钮的尺寸跟背景图片一样大
        // sizeToFit:默认会根据按钮的背景图片或者image和文字计算出按钮的最合适的尺寸
        [btn sizeToFit];
        // 监听按钮的点击
        [btn addTarget:self action:@selector(plusClick) forControlEvents:UIControlEventTouchUpInside];
        _plusButton = btn;
        [self addSubview:_plusButton];
    }
    return _plusButton;
}


@end
