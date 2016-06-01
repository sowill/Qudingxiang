//
//  LiftView.m
//  趣定向
//
//  Created by Prince on 16/4/7.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "LiftView.h"
@interface LiftView () <UITableViewDataSource ,UITableViewDelegate>

@property (nonatomic ,weak) UITableView *sliderView;

@end
@implementation LiftView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    // 创建一个占满屏幕的按钮,添加一个点击事件,并添加到这个自定义控件中
    UIButton *backAcitonButton = [[UIButton alloc] initWithFrame:self.bounds];
    [backAcitonButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backAcitonButton];
    // 创建侧边栏大小的CGRect, X:0 Y:0 宽度:控制器的6/10 高度:控制器的高度
    CGRect sliderFrame = CGRectMake(0, 0, CGRectGetWidth(self.bounds) * 0.6, QdxHeight);
    // 将侧滑的X设置为-宽度,这时侧滑View在屏幕窗口的左边,详见图1
    sliderFrame.origin.x = -CGRectGetWidth(sliderFrame);
    
    // 创建一个TableView作为侧边栏的View
    UITableView *sliderView = [[UITableView alloc] initWithFrame:sliderFrame];
    // 侧边栏的背景色为白色
    sliderView.backgroundColor = [UIColor whiteColor];
    // 隐藏分割线
    sliderView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 头部视图高度
    sliderView.sectionHeaderHeight = 130;
    // 行高
    sliderView.rowHeight = 55;
    // 数据源
    sliderView.dataSource = self;
    // 代理
    sliderView.delegate = self;
    // 添加到这个自定义控件中
    [self addSubview:sliderView];
    // 保存侧边栏View指针至全局
    self.sliderView = sliderView;
    
    return self;
}

- (void)showInView:(UIView *)view {
    // 将自定义控件的背景色设置为没有颜色
    self.backgroundColor = [UIColor clearColor];
    // 获取侧滑菜单当前的Frame
    CGRect sliderFrame = self.sliderView.frame;
    // 将获取到的Frame的X设置为0,还未更改控件的Frame
    sliderFrame.origin.x = 0;
    
    // 将整个自定义控件加入到传入的View中
    [view addSubview:self];
    
    // Block内的代码补间动画样式呈现
    [UIView animateWithDuration:0.25 animations:^{
        // 自定义控件的背景颜色设置为半透明灰色
        self.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:0.6];
        // 自定义控件中的侧滑ViewFrame正式设置X = 0;
        self.sliderView.frame = sliderFrame;
    }];
    
}
- (void)dismiss {
    
    CGRect sliderFrame = self.sliderView.frame;
    sliderFrame.origin.x = - CGRectGetWidth(sliderFrame);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.sliderView.frame = sliderFrame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeftSliderBaseCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LeftSliderBaseCell"];
    }
    
    UIImage *icon;
    NSString *title;
    switch (indexPath.row) {
        case 0:
            icon = [UIImage imageNamed:@"group_assistant_icon"];
            title = @"Item1";
            break;
        case 1:
            icon = [UIImage imageNamed:@"group_assistant_icon"];
            title = @"Item2";
            break;
        case 2:
            icon = [UIImage imageNamed:@"group_assistant_icon"];
            title = @"Item3";
            break;
        case 3:
            icon = [UIImage imageNamed:@"group_assistant_icon"];
            title = @"Item4";
            break;
        case 4:
            icon = [UIImage imageNamed:@"group_assistant_icon"];
            title = @"Item5";
            break;
        case 5:
            icon = [UIImage imageNamed:@"group_assistant_icon"];
            title = @"Item6";
            break;
        default:
            break;
    }
    cell.imageView.image = icon;
    cell.textLabel.text = title;
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // 设置cell的选中样式为空
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), tableView.sectionHeaderHeight)];
    headerImageView.image = [UIImage imageNamed:@"bg"];
    headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    return headerImageView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
