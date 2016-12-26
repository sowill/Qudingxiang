//
//  HomeController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/15.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "HomeController.h"
#import "LineController.h"
#import "HomeModel.h"
#import "BaseCell.h"
#import "QDXLineDetailViewController.h"
#import "HomeService.h"
#import "ImagePickerController.h"
#import "QDXLoginViewController.h"
#import "QDXNavigationController.h"
#import "ImageScrollView.h"
#import "AppDelegate.h"
#import "QDXActivityViewController.h"

@interface HomeController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger currNum;
    NSInteger page;
    NSInteger code;

    AppDelegate *appdelegate;
    HomeService *homehttp;
}

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) ImageScrollView *imgScrollView;

@property (nonatomic,strong) UIButton *scanBtn;

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation HomeController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
    [self topViewData];
    
    appdelegate = [[UIApplication sharedApplication] delegate];
}

-(void)reloadData
{
    [self loadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_imgScrollView stopTimer];
}

-(void)getTitle
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Util/title"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        self.navigationItem.title = infoDict[@"title"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)viewDidLoad
{
    [self getTitle];
    [super viewDidLoad];
    homehttp = [HomeService sharedInstance];
    
    self.view.backgroundColor = QDXBGColor;
    
    _scanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 18)];
    [_scanBtn setBackgroundImage:[UIImage imageNamed:@"index_sweep"] forState:UIControlStateNormal];
    [_scanBtn addTarget:self action:@selector(scanClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_scanBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateRefresh) name:@"stateRefresh" object:nil];
    
    [self createTableView];
    [self createHeaderView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stateRefresh" object:nil];
}

- (void)stateRefresh
{
    [self loadData];
}

- (void)loadDataCell
{
    dispatch_queue_t queue = dispatch_queue_create("gcdtest.rongfzh.yc", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [homehttp dbversionsucceed:^(id data) {
            
        } failure:^(NSError *error) {
            
        }];
    });
    dispatch_barrier_async(queue, ^{
        [self cellDataWith:@"1" isRemoveAll:YES andWithType:@"0"];
    });
}

- (void)loadData
{
    [self state];
    [self loadDataCell];
    _scanBtn.hidden = NO;
}

- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight- 64 - 10 - 25) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.automaticallyAdjustsScrollViewInsets = false;
    [self.view addSubview:_tableView];
    [self refreshView];
}

- (void)createHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth,FitRealValue(445 + 223))];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    //创建
    _imgScrollView = [[ImageScrollView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(445))];
    [view addSubview:_imgScrollView];
    
    UIImageView *mask = [[UIImageView alloc] initWithFrame:CGRectMake(0, FitRealValue(445)-QdxWidth*0.1, QdxWidth, QdxWidth*0.1)];
    mask.image = [UIImage imageNamed:@"index_mask"];
    [_imgScrollView addSubview:mask];
    
    NSArray *titleArr = @[@"亲子",@"交友",@"拓展",@"挑战"];
    NSArray *imageArr = @[@"index_parenting",@"index_makefriends",@"index_expand",@"index_dekaron"];
    CGFloat scrollViewMaxY = CGRectGetMaxY(_imgScrollView.frame);
    for(int i=0; i<4; i++){
        UIButton *btn = [ToolView createButtonWithFrame:CGRectMake(i*QdxWidth/4+QdxWidth/17, scrollViewMaxY+FitRealValue(50), QdxWidth/8, QdxWidth/8) title:titleArr[i] backGroundImage:imageArr[i] Target:self action:@selector(btnClick:) superView:view];
        btn.titleEdgeInsets = UIEdgeInsetsMake(QdxWidth/5, 0, 0, 0);
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.imageView.contentMode = UIViewContentModeCenter;
        btn.titleLabel.textColor = QDXGray;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.tag = 1+i;
    }
    _tableView.tableHeaderView = view;
}

- (void)refreshView
{
    __weak __typeof(self) weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    currNum = 1;
    [self cellDataWith:[NSString stringWithFormat:@"%li", (long)currNum] isRemoveAll:YES andWithType:@"0"];
    [_tableView.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    currNum ++;
    if(currNum > page){
        [_tableView reloadData];
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self cellDataWith:[NSString stringWithFormat:@"%li", (long)currNum] isRemoveAll:NO andWithType:@"0"];
    }
}

- (void)topViewData
{
    [homehttp topViewDatasucceed:^(id data) {
        NSMutableArray *modelArr  = [NSMutableArray arrayWithCapacity:0];
        NSDictionary *dataDict = data[@"Msg"][@"data"];
        _scrollArr = [NSMutableArray arrayWithCapacity:0];
        for(NSDictionary *dict in dataDict){
            int i = [dict[@"goods_index"] intValue];
            if (i == 1) {
                HomeModel *model = [[HomeModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                _model_tmp = model;
                NSString *str = model.good_url;
                [_scrollArr addObject:[NSString stringWithFormat:@"%@%@",hostUrl,str]];
                [modelArr addObject:model];
            }
        }
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
        for(int i = 0;i < 4;i++){
            [arr addObject:_scrollArr[i]];
        }
        //添加数据
        _imgScrollView.pics = arr;
        //点击事件
        [_imgScrollView returnIndex:^(NSInteger index) {
        QDXLineDetailViewController *detailLine = [[QDXLineDetailViewController alloc] init];
            detailLine.homeModel = [modelArr objectAtIndex:index];
            detailLine.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailLine animated:YES];
        }];
        //刷新（必需的步骤）
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_imgScrollView reloadView];
        });
    } failure:^(NSError *error) {
    
    }];
}

- (void)state
{
    appdelegate.loading = YES;
    [homehttp statesucceed:^(id data) {
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
        code = [dict[@"Code"] intValue];
        appdelegate.code = [NSString stringWithFormat:@"%d",(int)code];
        if(code == 2){
            appdelegate.ticket = dict[@"Msg"][@"ticket"][@"ticket_id"];
        }else if (code == 1) {
            [NSKeyedArchiver archiveRootObject:dict[@"Msg"][@"myline_id"] toFile:QDXCurrentMyLineFile];
        }
        appdelegate.loading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(code == 0){
                _scanBtn.hidden = NO;
            }else{
                _scanBtn.hidden = YES;
            }
        });
    } failure:^(NSError *error) {

    } WithToken:save];
}

- (void)cellDataWith:(NSString *)cur isRemoveAll:(BOOL)isRemoveAll andWithType:(NSString *)type
{
    [homehttp loadCellsucceed:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
        NSDictionary *dataDict = dict[@"Msg"][@"data"];
        
        if (![dict[@"Msg"][@"count"] isEqualToString:@"0"]){
            currNum = [dict[@"Msg"][@"curr"] integerValue];
            page = [dict[@"Msg"][@"page"] integerValue];
            if (isRemoveAll) {
                [_dataArr removeAllObjects];
            }
            _dataArr = [[NSMutableArray alloc] init];
            for(NSDictionary *dict in dataDict){
                HomeModel *model = [[HomeModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [_dataArr addObject:model];
            }
        }
        [_tableView.mj_footer endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    } failure:^(NSError *error) {

    } WithCurr:cur WithType:type];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return FitRealValue(80) + 10;
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
        view1.frame = CGRectMake(0, 10, QdxWidth, FitRealValue(80));
        view1.backgroundColor = [UIColor whiteColor];
        [view addSubview:view1];
        UIView *haedView = [[UIView alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(24), 3, FitRealValue(36))];
        haedView.backgroundColor = QDXBlue;
        [view1 addSubview:haedView];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24 + 10) + 3, FitRealValue(24), 200, FitRealValue(36))];
        titleLabel.text = @"最新资讯";
        titleLabel.textColor = QDXBlack;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont systemFontOfSize:17];
        [view1 addSubview:titleLabel];
        UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, FitRealValue(80) + 10, QdxWidth, 0.5)];
        viewLine.backgroundColor = QDXLineColor;
        [view addSubview:viewLine];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(584);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QDXLineDetailViewController *lineVC = [[QDXLineDetailViewController alloc] init];
    lineVC.homeModel = _dataArr[indexPath.row];
    lineVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lineVC animated:YES];
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsMake(0,FitRealValue(24), 0,FitRealValue(24))];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsMake(0,FitRealValue(24), 0, FitRealValue(24))];
//    }
//}

- (void)btnClick:(UIButton *)btn
{
    NSString *type = [NSString stringWithFormat:@"%li",btn.tag];
    QDXActivityViewController *qdxActVC = [[QDXActivityViewController alloc] init];
    qdxActVC.type = type;
    qdxActVC.hidesBottomBarWhenPushed = YES;
    qdxActVC.navTitle = btn.titleLabel.text;
    [self.navigationController pushViewController:qdxActVC animated:YES];
}

- (void)scanClick
{
    if ([save length] != 0) {
        ImagePickerController *imageVC = [[ImagePickerController alloc] initWithBlock:^(NSString *result, BOOL flag, NSString *from) {
            imageVC.from = from;
            [self netWorkingwith:result];
        }];
        imageVC.hidesBottomBarWhenPushed =YES;
        [self.navigationController pushViewController:imageVC animated:YES];
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

- (void)netWorkingwith:(NSString *)result
{
    //创建请求管理对象
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"ticketinfo_name"] = result;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
