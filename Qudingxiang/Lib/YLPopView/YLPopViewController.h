//
// QQ:896525689
// Email:zhangyuluios@163.com
//                 _
// /\   /\        | |
// \ \_/ / _   _  | |     _   _
//  \_ _/ | | | | | |    | | | |
//   / \  | |_| | | |__/\| |_| |
//   \_/   \__,_| |_|__,/ \__,_|
//
//  Created by shuogao on 16/5/27.
//  Copyright © 2016年 Yulu Zhang. All rights reserved.
//


#import <UIKit/UIKit.h>
typedef void (^block)(NSString *contentText);
@interface YLPopViewController: UIViewController

/**
 *  内容视图
 */
@property (nonatomic,strong) UIView *contentView;
/**
 *  contentViewSize 必须设置
 *  内容视图的大小
 */
@property (nonatomic,assign) CGSize contentViewSize;
/**
 *  提示标题
 */
@property (nonatomic,strong) NSString *Title;
/**
 *  占位符
 */
@property (nonatomic,strong) NSString *placeHolder;
/**
 *  字数限制 默认无
 */
@property (nonatomic,assign) unsigned long wordCount;
/**
 *  点击确定回调的block
 */
@property (nonatomic,copy) block confirmBlock;

@property (nonatomic, strong)void (^cancelBlock)();

/**
 *  创建主视图后调用此方法初始化contentView
 */
- (void)addContentView;

/**
 *  此方法移除视图
 *  此方法尽量不要在 confirmBlock 内部调用，如果需要请参考如下调用方法避免循环引用

       __typeof(popView)weakPopView = popView;
        popView.confirmBlock = ^(NSString *text) {
        NSLog(@"输入text:%@",text);
        [weakPopView hidden];
        };
 
 */
- (void)hidden;



/**
 **使用方法  注释掉的可以不实现。

 YLPopViewController *popView = [[YLPopViewController alloc] init];
 popView.contentViewSize = CGSizeMake(240, 280);
 //    popView.Title = @"这是一个标题";
 //    popView.placeHolder = @"这是一个占位符";
 //    popView.wordCount = 20;
 //必须设置完成之后调用
 [popView addContentView];

 popView.confirmBlock = ^(NSString *text) {

 NSLog(@"输入text:%@",text);
 };
 [popView hidden];

 */



@end
