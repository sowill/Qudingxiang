//
//  QDXActivityViewController.m
//  趣定向
//
//  Created by Air on 2016/12/14.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXActivityViewController.h"
#import "RecentActivityViewController.h"
#import "Goods.h"
#import "QDXLineDetailViewController.h"

@interface QDXActivityViewController ()<UIScrollViewDelegate,GoodsCellSelected>
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) RecentActivityViewController *recentVC;
@property (nonatomic, strong) RecentActivityViewController *didVC;
@property (nonatomic, strong) UIView *btnContainerView;
@property (nonatomic, strong) UILabel *slideLabel;
@property (nonatomic ,strong) NSMutableArray *btnsArray;
@end

@implementation QDXActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = _navTitle;
    
    [self setMainScrollView];
}

-(void)setMainScrollView
{
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, QdxWidth, self.view.frame.size.height)];
    _mainScrollView.delegate = self;
    _mainScrollView.backgroundColor = QDXBGColor;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_mainScrollView];
    
    NSArray *views = @[self.recentVC.view,self.didVC.view];
    for (NSInteger i = 0; i<self.btnsArray.count; i++) {
        //把三个vc的view依次贴到_mainScrollView上面
        UIView *pageView = [[UIView alloc]initWithFrame:CGRectMake(QdxWidth*i, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height-100)];
        [pageView addSubview:views[i]];
        [_mainScrollView addSubview:pageView];
    }
    _mainScrollView.contentSize = CGSizeMake(QdxWidth*(views.count), 0);
}

/**
 *  标签按钮点击
 *
 *  @param sender 按钮
 */
-(void)sliderAction:(UIButton *)sender{
    [self sliderAnimationWithTag:sender.tag];
    [UIView animateWithDuration:0.3 animations:^{
        _mainScrollView.contentOffset = CGPointMake(QdxWidth*(sender.tag), 0);
    } completion:^(BOOL finished) {
        
    }];
}

/**
 *  滑动scrollView以及改变sliderLabel位置
 *
 *  @param tag 按钮tag
 */
-(void)sliderAnimationWithTag:(NSInteger)tag{
    [self.btnsArray enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        btn.selected = NO;
    }];
    //获取被选中的按钮
    UIButton *selectedBtn = self.btnsArray[tag];
    selectedBtn.selected = YES;
    //动画
    [UIView animateWithDuration:0.3 animations:^{
        _slideLabel.center = CGPointMake(selectedBtn.center.x, _slideLabel.center.y);
    } completion:^(BOOL finished) {
        [self.btnsArray enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
            btn.titleLabel.font = [UIFont systemFontOfSize:17];
        }];
        selectedBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    }];
}

#pragma mark- XXXXXXXXXXXXXXX懒加载XXXXXXXXXXXXXXXXXXXX
- (RecentActivityViewController *)recentVC {
    if (!_recentVC) {
        _recentVC = [[RecentActivityViewController alloc]init];
        _recentVC.cityId = self.cityId;
        _recentVC.stateId = @"1";
        _recentVC.typeId = self.type;
        _recentVC.delegate = self;
    }
    return _recentVC;
}

-(RecentActivityViewController *)didVC{
    if (!_didVC) {
        _didVC = [[RecentActivityViewController alloc]init];
        _didVC.cityId = self.cityId;
        _didVC.stateId = @"4";
        _didVC.typeId = self.type;
        _didVC.delegate = self;
    }
    return _didVC;
}

-(void)goodsCellSelectedWith:(Goods *)goods
{
    QDXLineDetailViewController *lineDetailVC = [[QDXLineDetailViewController alloc] init];
    lineDetailVC.goods = goods;
    lineDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lineDetailVC animated:YES];
}

- (NSMutableArray *)btnsArray {
    if (!_btnsArray) {
        _btnsArray = [NSMutableArray array];
        self.btnContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, QdxWidth, 40)];
        self.btnContainerView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_btnContainerView];
        
        _slideLabel = [[UILabel alloc]initWithFrame:CGRectMake(FitRealValue(24), 40-1, QdxWidth/2 - FitRealValue(24), 2)];
        _slideLabel.backgroundColor = QDXBlue;
        
        [_btnContainerView addSubview:_slideLabel];
        
        for (int i = 0; i < 2; i++) {
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:QDXBlue forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            if (i==0) {
                btn.frame = CGRectMake(FitRealValue(24),0, QdxWidth/2 - FitRealValue(24), _btnContainerView.frame.size.height);
            }else{
                btn.frame = CGRectMake(i*QdxWidth/2,0, QdxWidth/2 - FitRealValue(24), _btnContainerView.frame.size.height);
            }
            
            btn.titleLabel.font = [UIFont systemFontOfSize:17];
            [btn addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) {
                [btn setTitle:@"近期" forState:UIControlStateNormal];
            }else{
                [btn setTitle:@"已完成" forState:UIControlStateNormal];
            }
            btn.tag = i;
            [_btnsArray addObject:btn];
            if (i == 0) {
                btn.selected = YES;
                btn.titleLabel.font = [UIFont systemFontOfSize:18];
                
            }
            [_btnContainerView addSubview:btn];
        }
    }
    return _btnsArray;
}

//scrollView滑动代理监听
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    double index_ = scrollView.contentOffset.x/QdxWidth;
    [self sliderAnimationWithTag:(int)(index_+0.5)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
