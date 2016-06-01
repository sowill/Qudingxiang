//
//  HomeController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/15.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "HomeController.h"
#import "QDXGameViewController.h"
#import "CellLineController.h"
#import "LineController.h"
#import "QDXGameViewController.h"
#import "HomeModel.h"
#import "ImageModel.h"
#import "BaseCell.h"
#import "QDXProtocolViewController.h"
#import "QDXLineDetailViewController.h"
#import "HomeService.h"
#import "ImagePickerController.h"
#import "QDXOffLineController.h"
#import "MineViewController.h"
#import "QDXLoginViewController.h"
#import "QDXNavigationController.h"
#define NotificaitonChange @"code"

@interface HomeController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,MJRefreshBaseViewDelegate,UIAlertViewDelegate>
{
    UITableView *_tableView;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    UIImageView *_scrollImageView;
    UIImageView *_imageView;
    UIImageView *_topImageView;
    UIButton *_leftButton;
    UIButton *_rightButton;
    //NSMutableArray *_scrollArr;
    NSMutableArray *_dataArr;
    NSString *_result;
    NSInteger _currentIndex;
    NSTimer *_myTimer;
    NSArray *_topImage;
    NSMutableArray *_modelArr;
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    NSInteger _curNumber;
    NSInteger _countNum;
    NSInteger _currNum;
    UIButton *_button;
    BOOL _isLog;
    NSInteger _line;
    NSInteger _code;
    NSString *_msg;
    NSString *_codeMsg;
    UIButton *_scanBtn;
}
@end

@implementation HomeController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadData];
    [self addTimer];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeTimer];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _scrollArr = [NSMutableArray arrayWithCapacity:0];
    _modelArr  = [NSMutableArray arrayWithCapacity:0];
    self.navigationItem.title = @"趣定向";
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    _curNumber = 1;
    [self createTableView];
    [self createUI];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    //    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
    //        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
    //        NSLog(@"第一次启动");
    //    }else{
    //        NSLog(@"不是第一次启动");
    //    }
}

- (void)loadData
{
    
    [self showProgessMsg:@"正在加载"];
    [self performSelectorInBackground:@selector(topViewData) withObject:nil];
    [self performSelectorInBackground:@selector(cellDataWith:isRemoveAll:) withObject:nil];
    [self performSelectorInBackground:@selector(state) withObject:nil];
    [self setupCurrentLine];
}

//获取myline_id
-(void)setupCurrentLine
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *url = [hostUrl stringByAppendingString:@"Home/Myline/getCurrentLine"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1) {
            [NSKeyedArchiver archiveRootObject:infoDict[@"Msg"][@"myline_id"] toFile:QDXCurrentMyLineFile];
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-24) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [self.view addSubview:_tableView];
    [self refreshView];
    
}

- (void)createUI
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth*0.59+QdxWidth/5)];
    CGFloat viewMaxY = CGRectGetMaxY(view.frame);
    [view setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    UIView *viewFoot = [[UIView alloc] initWithFrame:CGRectMake(0, viewMaxY, QdxWidth,30)];
    viewFoot.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    [view addSubview:viewFoot];
    view.frame = CGRectMake(0, 0, QdxWidth, viewMaxY+30);
    
    _tableView.tableHeaderView = view;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth*0.59)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
    _scrollView.pagingEnabled = YES;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(4*QdxWidth, 0);
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = YES;
    _scrollView.scrollEnabled = NO;
    [view addSubview:_scrollView];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, QdxWidth*0.59-20, QdxWidth, 10)];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
    _pageControl.numberOfPages = 4;
    _pageControl.currentPage = 0;
    [view addSubview:_pageControl];
    [self createButtonWithView:view];
    [self.view addSubview:_tableView];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_button setImage:[UIImage imageNamed:@"index_my"] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(setClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_button];
    UIBarButtonItem *btn_left = [[UIBarButtonItem alloc] initWithCustomView:_button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, btn_left, nil];
    
    
    
    _scanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    [_scanBtn setImage:[UIImage imageNamed:@"index_sweep"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_scanBtn];
    UIBarButtonItem *btn_right = [[UIBarButtonItem alloc] initWithCustomView:_scanBtn];
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -10;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, btn_right, nil];
}



- (void)createButtonWithView:(UIView *)view
{
    NSArray *titleArr = @[@"亲子",@"交友",@"拓展",@"挑战"];
    NSArray *imageArr = @[@"index_parenting",@"index_makefriends",@"index_expand",@"index_dekaron"];
    CGFloat scrollViewMaxY = CGRectGetMaxY(_scrollView.frame);
    for(int i=0; i<4; i++){
        UIButton *btn = [ToolView createButtonWithFrame:CGRectMake(i*QdxWidth/4+QdxWidth/17, scrollViewMaxY+20, QdxWidth/8, QdxWidth/8) title:titleArr[i] backGroundImage:imageArr[i] Target:self action:@selector(btnClick:) superView:view];
        btn.titleEdgeInsets = UIEdgeInsetsMake(QdxWidth/5, 0, 0, 0);
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.imageView.contentMode = UIViewContentModeCenter;
        btn.titleLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.tag = 100+i;
    }
}

- (void)refreshView
{
    _header = [MJRefreshHeaderView header];
    _header.delegate = self;
    _header.scrollView = _tableView;
    
    _footer = [MJRefreshFooterView footer];
    _footer.delegate = self;
    _footer.scrollView = _tableView;
}

- (void)dealloc

{
    [_header free];
    
    [_footer free];
}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == _header) {
        _curNumber = 1;
        //刷新
        [self cellDataWith:[NSString stringWithFormat:@"%li", (long)_curNumber] isRemoveAll:YES];
        
    } else {
        //加载更多
        _curNumber ++;
        if(_countNum/13+1 == _currNum){
            [_footer endRefreshing];
        }else{
            [self cellDataWith:[NSString stringWithFormat:@"%li", (long)_curNumber] isRemoveAll:NO];
        }
    }
}
- (void)addTimer
{
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_myTimer forMode:NSRunLoopCommonModes];
}

- (void)nextImage
{
    // 1.增加pageControl的页码
    _currentIndex = 0;
    if (_pageControl.currentPage == 3) {
        _currentIndex = 0;
    } else {
        _currentIndex = _pageControl.currentPage + 1;
    }
    
    // 2.计算scrollView滚动的位置
    CGFloat offsetX = _currentIndex * _scrollView.frame.size.width;
    CGPoint offset = CGPointMake(offsetX, 0);
    [_scrollView setContentOffset:offset animated:YES];
}

- (void)removeTimer
{
    [_myTimer invalidate];
    _myTimer = nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 停止定时器(一旦定时器停止了,就不能再使用)
    [self removeTimer];
}
//停止拖拽的时候调用

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 开启定时器
    [self addTimer];
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

- (void)sussRes
{
    [self showProgessOK:@"加载成功"];
}

- (void)failRes
{
    [self showProgessOK:@"加载失败"];
}

- (void)topViewData
{
    [HomeService topViewDataBlock:^(NSMutableDictionary *dict) {
        NSDictionary *dataDict = dict[@"Msg"][@"data"];
        for(NSDictionary *dict in dataDict){
            int i = [dict[@"goods_index"] intValue];
            if (i == 1) {
                HomeModel *model = [[HomeModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                _model_tmp = model;
                NSString *str = model.good_url;
                [_scrollArr addObject:str];
                [_modelArr addObject:model];
            }
        }
        for (int i = 0; i < _scrollArr.count; i++) {
            _imageView = [[UIImageView alloc] init];
            CGFloat contentW = i * QdxWidth;
            _imageView.frame = CGRectMake(contentW, 0, QdxWidth, QdxWidth*0.59);
            _imageView.image = [UIImage imageNamed:@"1"];
            _imageView.userInteractionEnabled = YES;
            UIButton *btn = [ToolView createButtonWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth*0.59) title:@"" backGroundImage:@"" Target:self action:@selector(topBtnClicked:) superView:_imageView];
            btn.tag = i;
            _scrollView.delegate = self;
            [_scrollView addSubview:_imageView];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,[_scrollArr objectAtIndex:i]]];
            [_imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"banner"]];
        }
    } FailBlock:^(NSMutableArray *array) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"加载失败，请检查网络！" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }] ];
        [self presentViewController:alert animated:YES completion:nil];
    } andWithToken:save];
}

- (void)state
{
    [HomeService btnStateBlock:^(NSMutableDictionary *dict) {
        _code = [[NSString stringWithFormat:@"%@",dict[@"Code"]] intValue];
        if (_code == 0) {
            
            _codeMsg = dict[@"Msg"];
        }
        [HomeService choiceLineStateBlock:^(NSMutableDictionary *dict) {
            _line = [[NSString stringWithFormat:@"%@",dict[@"Code"]] intValue];
            if (_line == 0) {
                _msg = dict[@"Msg"];
            }
            [self performSelectorOnMainThread:@selector(changeScanBtn) withObject:nil waitUntilDone:YES];
        } andWithToken:save];
    } andWithToken:save];
}

- (void)cellDataWith:(NSString *)cur isRemoveAll:(BOOL)isRemoveAll
{
    [HomeService cellDataBlock:^(NSMutableDictionary *dict) {
        
        NSDictionary *dataDict = dict[@"Msg"][@"data"];
        _currNum = [dict[@"Msg"][@"curr"] integerValue];
        _countNum = [dict[@"Msg"][@"count"] integerValue];
        if (isRemoveAll) {
            [_dataArr removeAllObjects];
        }
        _dataArr = [[NSMutableArray alloc] init];
        for(NSDictionary *dict in dataDict){
            HomeModel *model = [[HomeModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            [_dataArr addObject:model];
        }
        [self performSelectorOnMainThread:@selector(sussRes) withObject:nil waitUntilDone:YES];
        [_tableView reloadData];
        [_header endRefreshing];
        [_footer endRefreshing];
    } FailBlock:^(NSMutableArray *array) {
        [_header endRefreshing];
        [_footer endRefreshing];
        [self performSelectorOnMainThread:@selector(failRes) withObject:nil waitUntilDone:YES];
    } andWithToken:save andWithCurr:cur];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseCell *cell = [BaseCell baseCellWithTableView:_tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.homeModel = _dataArr[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, QdxWidth, 10);
        view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
        UIView *view1 = [[UIView alloc] init];
        view1.frame = CGRectMake(0, 10, QdxWidth, 29);
        view1.backgroundColor = [UIColor whiteColor];
        [view addSubview:view1];
        UIView *haedView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 3, 18)];
        haedView.backgroundColor = [UIColor colorWithRed:13/255.0 green:131/255.0 blue:252/255.0 alpha:1];
        [view addSubview:haedView];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 200, 30)];
        titleLabel.text = @"经典推荐";
        titleLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont systemFontOfSize:14];
        [view1 addSubview:titleLabel];
        UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 39, QdxWidth, 1)];
        viewLine.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:0.1];
        [view addSubview:viewLine];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QDXLineDetailViewController *lineVC = [[QDXLineDetailViewController alloc] init];
    lineVC.homeModel = _dataArr[indexPath.row];
    lineVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lineVC animated:YES];
}

- (void)btnClick:(UIButton *)btn
{
    
}

- (void)changeScanBtn
{
    if (!save) {
        [_scanBtn setUserInteractionEnabled:YES];
        [_scanBtn addTarget:self action:@selector(scanClick) forControlEvents:UIControlEventTouchUpInside];
    }else
    {
        
        if((_code == 0) && (_line == 0)){
            [_scanBtn setUserInteractionEnabled:YES];
            [_scanBtn addTarget:self action:@selector(scanClick1) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            [_scanBtn setUserInteractionEnabled:NO];
        }
    }
}

- (void)scanClick
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆后才可使用此功能" delegate:self cancelButtonTitle:@"暂不登录" otherButtonTitles:@"立即登录", nil];
    [alert show];
}
- (void)scanClick1
{
    ImagePickerController *imageVC = [[ImagePickerController alloc] init];
    imageVC.from = @"1";
    imageVC.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:imageVC animated:YES];
    
}


- (void)setClick
{
    if(save == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆后才可使用此功能" delegate:self cancelButtonTitle:@"暂不登录" otherButtonTitles:@"立即登录", nil];
        [alert show];
    }else{
        [self.sideMenuViewController presentLeftMenuViewController];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }else if(buttonIndex == 1){
        //        NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //        documentDir= [documentDir stringByAppendingPathComponent:@"QDXAccount.data"];
        //        [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
        self.hidesBottomBarWhenPushed = YES;
        QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
        QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
        [self presentViewController:navController animated:YES completion:^{
            
        }];
        
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=com.qudingxiang.app.sporttest"]];
    }
}

- (void)choiceBtnClicked
{
    LineController *lineVC = [[LineController alloc] init];
    lineVC.click = @"1";
    lineVC.ticketID = saveTicket_id;
    lineVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lineVC animated:YES];
    
}
- (void)rightBtnClicked
{
    
}

- (void)rBtnClicked
{
    
}

- (void)topBtnClicked:(UIButton *)btn
{
    QDXLineDetailViewController *detailLine = [[QDXLineDetailViewController alloc] init];
    btn.tag = _currentIndex;
    detailLine.homeModel = [_modelArr objectAtIndex:btn.tag];
    detailLine.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailLine animated:YES];
}

- (void)startGame
{
    NSString *isHave = [NSKeyedUnarchiver unarchiveObjectWithFile:QDXMyLineFile];
    if (isHave) {
        QDXGameViewController *viewController = [[QDXGameViewController alloc] init];
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        QDXProtocolViewController *viewController = [[QDXProtocolViewController alloc] init];
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
