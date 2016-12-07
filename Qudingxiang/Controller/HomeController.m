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
#import "HomeModel.h"
#import "ImageModel.h"
#import "BaseCell.h"
#import "QDXProtocolViewController.h"
#import "QDXLineDetailViewController.h"
#import "HomeService.h"
#import "ImagePickerController.h"
#import "QDXLoginViewController.h"
#import "QDXNavigationController.h"
#import "ImageScrollView.h"
#import "AppDelegate.h"
#import "BaseService.h"
#define NotificaitonChange @"code"

@interface HomeController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UINavigationControllerDelegate>
{
    UITableView *_tableView;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    UIImageView *_scrollImageView;
    UIImageView *_imageView;
    UIImageView *_topImageView;
    UIButton *_leftButton;
    UIButton *_rightButton;

    NSMutableArray *_dataArr;
    NSString *_result;
    NSInteger _currentIndex;
    NSTimer *_myTimer;
    NSArray *_topImage;
    NSMutableArray *_modelArr;
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
    ImageScrollView *imgScrollView;
    NSMutableArray *arr;

    AppDelegate *appdelegate;
    HomeService *homehttp;
}
@end

@implementation HomeController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
     appdelegate = [[UIApplication sharedApplication] delegate];
}

-(void)reloadData
{
    [self loadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _scrollArr = [NSMutableArray arrayWithCapacity:0];
    [imgScrollView stopTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    homehttp = [HomeService sharedInstance];
    _modelArr  = [NSMutableArray arrayWithCapacity:0];
    arr = [[NSMutableArray alloc] initWithCapacity:0];
    self.navigationItem.title = @"趣定向";
    _curNumber = 1;
    [self createTableView];
    [self loadDataCell];
    [self createUI];
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateRefresh) name:@"stateRefresh" object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stateRefresh" object:nil];
}

- (void)stateRefresh
{
    [self state];
    [self loadData];
}

- (void)loadDataCell
{
    _scrollArr = [NSMutableArray arrayWithCapacity:0];
    dispatch_queue_t queue = dispatch_queue_create("gcdtest.rongfzh.yc", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self dbversion];
    });
    dispatch_barrier_async(queue, ^{
        [self cell1];
        [self topViewData];
    });
}

- (void)cell1
{
   [self cellDataWith:@"1" isRemoveAll:YES andWithType:@"0"];
}

- (void)loadData
{
    if (save) {
        [self state];
        //[self performSelectorInBackground:@selector(state) withObject:nil];
    }else{
        _scanBtn.hidden = NO;
        [self state1];
    }
}

- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-64-10) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = QDXBGColor;
    self.automaticallyAdjustsScrollViewInsets = false;
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
    
    //创建
    imgScrollView = [[ImageScrollView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth*0.59)];
    [view addSubview:imgScrollView];
    UIImageView *mask = [[UIImageView alloc] initWithFrame:CGRectMake(0, QdxWidth*0.59-QdxWidth*0.1, QdxWidth, QdxWidth*0.1)];
    mask.image = [UIImage imageNamed:@"index_mask"];
    [imgScrollView addSubview:mask];
    
    [self createButtonWithView:view];
    [self.view addSubview:_tableView];
    
    
    _scanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 18)];
    [_scanBtn setBackgroundImage:[UIImage imageNamed:@"index_sweep"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_scanBtn];
}

- (void)createButtonWithView:(UIView *)view
{
    NSArray *titleArr = @[@"亲子",@"交友",@"拓展",@"挑战"];
    NSArray *imageArr = @[@"index_parenting",@"index_makefriends",@"index_expand",@"index_dekaron"];
    CGFloat scrollViewMaxY = CGRectGetMaxY(imgScrollView.frame);
    for(int i=0; i<4; i++){
        UIButton *btn = [ToolView createButtonWithFrame:CGRectMake(i*QdxWidth/4+QdxWidth/17, scrollViewMaxY+20, QdxWidth/8, QdxWidth/8) title:titleArr[i] backGroundImage:imageArr[i] Target:self action:@selector(btnClick:) superView:view];
        btn.titleEdgeInsets = UIEdgeInsetsMake(QdxWidth/5, 0, 0, 0);
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.imageView.contentMode = UIViewContentModeCenter;
        btn.titleLabel.textColor = QDXGray;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.tag = 1+i;
    }
}

- (void)refreshView
{
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    [_tableView.mj_header beginRefreshing];
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
//    // 设置了底部inset
//    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
//    // 忽略掉底部inset
//    _tableView.mj_footer.ignoredScrollViewContentInsetBottom = 30;
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    _curNumber = 1;
    //刷新
    
    [self cellDataWith:[NSString stringWithFormat:@"%li", (long)_curNumber] isRemoveAll:YES andWithType:@"0"];
    
    [_tableView.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    _curNumber ++;
    
    if(_countNum/13+1 == _currNum){
        [_tableView reloadData];
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self cellDataWith:[NSString stringWithFormat:@"%li", (long)_curNumber] isRemoveAll:NO andWithType:@"0"];
    }
}


- (void)sussRes
{
    
}

- (void)failRes
{
   
}

- (void)topViewData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [homehttp topViewDatasucceed:^(id data) {
            NSDictionary *dataDict = data[@"Msg"][@"data"];
            for(NSDictionary *dict in dataDict){
                int i = [dict[@"goods_index"] intValue];
                if (i == 1) {
                    HomeModel *model = [[HomeModel alloc] init];
                    [model setValuesForKeysWithDictionary:dict];
                    _model_tmp = model;
                    NSString *str = model.good_url;
                    [_scrollArr addObject:[NSString stringWithFormat:@"%@%@",hostUrl,str]];
                    [_modelArr addObject:model];
                }
            }
        
            for(int i = 0;i<4;i++){
                [arr addObject:_scrollArr[i]];
            }
            //添加数据
            imgScrollView.pics = arr;
            //点击事件
            [imgScrollView returnIndex:^(NSInteger index) {
            QDXLineDetailViewController *detailLine = [[QDXLineDetailViewController alloc] init];
                detailLine.homeModel = [_modelArr objectAtIndex:index];
                detailLine.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:detailLine animated:YES];
            }];
            //刷新（必需的步骤）
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [imgScrollView reloadView];
            });
        } failure:^(NSError *error) {
        
        }];
    });
}

- (void)state
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    appdelegate.loading = YES;
    [homehttp statesucceed:^(id data) {
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
        _code = [dict[@"Code"] intValue];
        appdelegate.code = [NSString stringWithFormat:@"%d",(int)_code];
        if(_code == 2){
            appdelegate.ticket = dict[@"Msg"][@"ticket"][@"ticket_id"];
        }else if (_code == 1) {
            [NSKeyedArchiver archiveRootObject:dict[@"Msg"][@"myline_id"] toFile:QDXCurrentMyLineFile];
        }
        appdelegate.loading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeScanBtn];

        });
        
    } failure:^(NSError *error) {

    } WithToken:save];
    });
}

- (void)state1
{
    [_scanBtn addTarget:self action:@selector(scanClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dbversion
{
    [homehttp dbversionsucceed:^(id data) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)cellDataWith:(NSString *)cur isRemoveAll:(BOOL)isRemoveAll andWithType:(NSString *)type
{

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [homehttp loadCellsucceed:^(id data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];

            });
            
            //[self performSelectorOnMainThread:@selector(sussRes) withObject:nil waitUntilDone:YES];
            [_tableView.mj_footer endRefreshing];
        } failure:^(NSError *error) {

        } WithCurr:cur WithType:type];
        });
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
        view.backgroundColor = QDXBGColor;
        UIView *view1 = [[UIView alloc] init];
        view1.frame = CGRectMake(0, 10, QdxWidth, 30);
        view1.backgroundColor = [UIColor whiteColor];
        [view addSubview:view1];
        UIView *haedView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 3, 18)];
        haedView.backgroundColor = QDXBlue;
        [view addSubview:haedView];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 200, 30)];
        titleLabel.text = @"经典推荐";
        titleLabel.textColor = QDXBlack;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont systemFontOfSize:14];
        [view1 addSubview:titleLabel];
        UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 40, QdxWidth, 0.5)];
        viewLine.backgroundColor = QDXLineColor;
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,FitRealValue(24), 0,FitRealValue(24))];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,FitRealValue(24), 0, FitRealValue(24))];
    }
}

- (void)btnClick:(UIButton *)btn
{
    NSString *type = [NSString stringWithFormat:@"%li",btn.tag];
    [self cellDataWith:@"1" isRemoveAll:YES andWithType:type];
}

- (void)changeScanBtn
{
    if(_code == 0){
        _scanBtn.hidden = NO;
        [_scanBtn addTarget:self action:@selector(scanClick) forControlEvents:UIControlEventTouchUpInside];
    }else{
        _scanBtn.hidden = YES;
    }
}

- (void)scanClick
{
    if ([save length] != 0) {
        [self scanClick1];
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"登陆后才可使用此功能" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"立即登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        
            QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
            QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
            regi.hidesBottomBarWhenPushed = YES;
            [self presentViewController:navController animated:YES completion:^{
        
            }];
        
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"暂不登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
- (void)scanClick1
{
    ImagePickerController *imageVC = [[ImagePickerController alloc] initWithBlock:^(NSString *result, BOOL flag, NSString *from) {
        imageVC.from = from;
        _result = result;
//        NSLog(@"%@",_result);
        [self netWorking];
    }];
    imageVC.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:imageVC animated:YES];
}

- (void)netWorking
{
    
    //创建请求管理对象
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"ticketinfo_name"] = _result;
    [mgr POST:[NSString stringWithFormat:@"%@%@",hostUrl,actUrl] parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dict = [[NSDictionary alloc] initWithDictionary:responseObject];
        NSDictionary *dictMsg = dict[@"Msg"];
        StartModel *model = [[StartModel alloc] init];
        [model setCode:dict[@"Code"] ];
        [model setMsg:dict[@"Msg"]];
        int temp = [model.Code intValue];
        if (!temp) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@",model.Msg] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1;
            [alert show];
            
            
            
        }else{
            [model setTicket_id:dictMsg[@"ticket_id"]];
            if([model.ticket_id longLongValue] <100000000000){
                [NSKeyedArchiver archiveRootObject:model.ticket_id toFile:QDXTicketFile];
                LineController *lineVC = [[LineController alloc] init];
                QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:lineVC];
                self.delegate = lineVC;
                [self.delegate PassTicket:model.ticket_id andClick:@"2"];
                [self presentViewController:nav animated:YES completion:^{
                    
                }];
            }else{
            }
            
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)choiceBtnClicked
{
    LineController *lineVC = [[LineController alloc] init];
    lineVC.click = @"1";
    lineVC.ticketID = saveTicket_id;
    lineVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lineVC animated:YES];
    
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
