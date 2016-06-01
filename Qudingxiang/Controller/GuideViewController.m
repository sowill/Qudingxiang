//
//  GuideViewController.m
//  趣定向
//
//  Created by Prince on 16/4/14.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "GuideViewController.h"
#import "HomeController.h"
#import "TabbarController.h"
#import "MineViewController.h"
@interface GuideViewController ()<UIScrollViewDelegate,RESideMenuDelegate>
{
    UIImageView *_imageView;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    NSInteger _currentIndex;
}
@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
}

- (void)createUI
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
    _scrollView.pagingEnabled = YES;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(3*QdxWidth, 0);
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.bounces = YES;
    _scrollView.scrollEnabled = YES;
    [self.view addSubview:_scrollView];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, QdxHeight-100, QdxWidth, 0)];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
    _pageControl.numberOfPages = 3;
    _pageControl.currentPage = 0;
    [self.view addSubview:_pageControl];
    
    for(int i = 0;i<3;i++){
        _imageView = [[UIImageView alloc] init];
        CGFloat contentW = i * QdxWidth;
        _imageView.frame = CGRectMake(contentW, 0, QdxWidth, QdxHeight);
        _imageView.image = [UIImage imageNamed:@"1"];
        _imageView.userInteractionEnabled = YES;
        [_scrollView addSubview:_imageView];
        if(i == 2){
            _imageView.userInteractionEnabled = YES;
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((QdxWidth - 80)/2, (QdxHeight-80)/2, 80, 40)];
            button.backgroundColor = [UIColor orangeColor];
            [button setTitle:@"进入应用" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(gotoHomeController) forControlEvents:UIControlEventTouchUpInside];
            [_imageView addSubview:button];

        }
    }
}

- (void)gotoHomeController
{
    
        [UIView animateWithDuration:1.0 animations:^{
            _scrollView.alpha = 0.0;
    
        } completion:^(BOOL finished) {
            [_scrollView removeFromSuperview];
            [_pageControl removeFromSuperview];
            TabbarController *mainTabbarVC = [[TabbarController alloc] init];
            MineViewController *mine = [[MineViewController alloc] init];
            
            RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:mainTabbarVC
                                                                            leftMenuViewController:mine
                                                                           rightMenuViewController:nil];
            sideMenuViewController.mainController = mainTabbarVC;
            sideMenuViewController.menuPreferredStatusBarStyle = 1;
            sideMenuViewController.delegate = self;
            sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
            sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
            sideMenuViewController.contentViewShadowOpacity = 0.6;
            sideMenuViewController.contentViewShadowRadius = 12;
            sideMenuViewController.contentViewShadowEnabled = YES;
            //是否缩小
            sideMenuViewController.scaleContentView = NO;
            [self presentViewController:sideMenuViewController animated:YES completion:^{
                
            }];
        }];

    }
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat scrollW = _scrollView.frame.size.width;
    _currentIndex = (scrollView.contentOffset.x + scrollW * 0.5) / scrollW;
    _pageControl.currentPage = _currentIndex;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentIndex = _scrollView.contentOffset.x/QdxWidth;
    if(_scrollView.contentOffset.x >=QdxWidth*3){
        _scrollView.contentOffset = CGPointMake(0, 0);
    }
    _pageControl.currentPage = _currentIndex;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
