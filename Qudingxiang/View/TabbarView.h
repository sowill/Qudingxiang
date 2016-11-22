//
//  TabbarView.h
//  趣定向
//
//  Created by Prince on 16/4/29.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TabbarView;

@protocol TabbarViewDelegate <NSObject>

@optional
//- (void)tabBar:(TabbarView *)tabBar didSelectedButtonFrom:(int)from to:(int)to;
- (void)tabBarDidClickedPlusButton:(TabbarView *)tabBar;

@end

@interface TabbarView : UITabBar

//- (void)addTabBarButtonWithItem:(UITabBarItem *)item;

@property (nonatomic, weak) id<TabbarViewDelegate> delegate;
@end
