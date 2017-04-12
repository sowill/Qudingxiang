//
//  QDXPopView.h
//  趣定向
//
//  Created by Air on 2017/4/1.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface QDXPopView : UIView

@property(nonatomic ,strong)UIView *deliverView;

@property(nonatomic ,strong)UIButton *showOK_button;

@property(nonatomic ,strong)UIButton *showTitle_button;

@property(nonatomic ,strong)UIButton *task_button;

@property(nonatomic ,strong)NSString *title;

- (void) show;
- (void) dismiss;

@end
