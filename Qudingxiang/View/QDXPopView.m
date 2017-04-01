//
//  QDXPopView.m
//  趣定向
//
//  Created by Air on 2017/4/1.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QDXPopView.h"

#define TASKWEIGHT                         QdxWidth * 0.875
#define TASKHEIGHT                         QdxHeight * 0.73
#define SHOWTASKHEIGHT                     TASKHEIGHT * 0.1

@implementation QDXPopView

- (instancetype)init{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    self.frame = [UIScreen mainScreen].bounds;
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    self.deliverView = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth* 0.08,(QdxHeight - TASKHEIGHT)/2,TASKWEIGHT/2,TASKHEIGHT/2)];
    self.deliverView.backgroundColor = [UIColor clearColor];
    self.deliverView.layer.borderWidth = 1;
    self.deliverView.layer.cornerRadius = 12;
    self.deliverView.layer.borderColor = [[UIColor clearColor]CGColor];
    [self addSubview:self.deliverView];
    
    
    _showOK_button = [[UIButton alloc] initWithFrame:CGRectMake(0, TASKHEIGHT - SHOWTASKHEIGHT,TASKWEIGHT, SHOWTASKHEIGHT)];
    [_showOK_button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    [_showOK_button setBackgroundImage:[[UIImage imageNamed:@"任务卡－按钮"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [_showOK_button setTitle:@"好的" forState:UIControlStateNormal];
    [_showOK_button setTitleColor:[UIColor colorWithRed:0.000 green:0.600 blue:0.992 alpha:1.000] forState:UIControlStateNormal];
    [self.deliverView addSubview:_showOK_button];
    
    _showTitle_button = [[UIButton alloc] initWithFrame:CGRectMake(0,0,TASKWEIGHT, SHOWTASKHEIGHT)];
    _showTitle_button.userInteractionEnabled = NO;
    [_showTitle_button setBackgroundImage:[[UIImage imageNamed:@"任务卡－按钮上面"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [_showTitle_button setTitleColor:[UIColor colorWithWhite:0.067 alpha:1.000] forState:UIControlStateNormal];
    _showTitle_button.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.deliverView addSubview:_showTitle_button];
    
    // 添加手势
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self addGestureRecognizer:gesture];
}

#pragma mark- 显示view
-(void)show
{
    [_showTitle_button setTitle:_title forState:UIControlStateNormal];
    
    CGPoint finalPoint;
    
    finalPoint = CGPointMake(TASKWEIGHT, TASKHEIGHT);
    
    CGFloat radius = sqrt((finalPoint.x * finalPoint.x) + (finalPoint.y * finalPoint.y));
    UIBezierPath *maskFinalBP = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.deliverView.frame, -radius, -radius)];

    UIBezierPath *maskStartBP =  [UIBezierPath bezierPathWithOvalInRect:_task_button.frame];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskFinalBP.CGPath;
    self.deliverView.layer.mask = maskLayer;
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (__bridge id)(maskStartBP.CGPath);
    maskLayerAnimation.toValue = (__bridge id)((maskFinalBP.CGPath));
    maskLayerAnimation.duration = 0.7;
    maskLayerAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    maskLayerAnimation.delegate = self;
    
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];

    
//    [self.passwordField becomeFirstResponder];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[UIApplication sharedApplication].keyWindow addSubview:self.deliverView];
}
#pragma mark- 隐藏view
-(void)dismiss
{
    UIBezierPath *finalPath = [UIBezierPath bezierPathWithOvalInRect:self.task_button.frame];
    
    CGPoint finalPoint;
    
    finalPoint = CGPointMake(self.task_button.center.x - 0, self.task_button.center.y - 0);
    
    CGFloat radius = sqrt(finalPoint.x * finalPoint.x + finalPoint.y * finalPoint.y);
    UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.task_button.frame, -radius, -radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = finalPath.CGPath;
    self.deliverView.layer.mask = maskLayer;
    
    CABasicAnimation *pingAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pingAnimation.fromValue = (__bridge id)(startPath.CGPath);
    pingAnimation.toValue   = (__bridge id)(finalPath.CGPath);
    pingAnimation.duration = 0.7;
    pingAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    pingAnimation.delegate = self;
    
    [maskLayer addAnimation:pingAnimation forKey:@"pingInvert"];
    
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.7 *NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self.deliverView removeFromSuperview];
        [self removeFromSuperview];
    });
}

@end
