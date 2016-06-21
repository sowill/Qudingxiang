//
//  ActivityController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "ActivityController.h"
#import "QDXLineDetailViewController.h"
#import "ActCell.h"
#import "ActModel.h"
#import "HomeModel.h"
#import "ActivityService.h"
#import "QDXNavigationController.h"
#import "QDXLoginViewController.h"
@interface ActivityController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate,UIAlertViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArr;
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
    NSInteger _curNumber;
    NSInteger _currNum;
    NSInteger _countNum;
    NSString *_goodsId;
    NSString *_status_id;
    UIButton *_button;
}
@end

@implementation ActivityController

- (void)viewDidLoad {
    [super viewDidLoad];
    _curNumber = 1;
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];;
    self.navigationItem.title = @"活动";
    [self loadData];
    [self createTableView];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)loadData
{
    [self performSelectorInBackground:@selector(loadDataWith:isRemoveAll:) withObject:nil];
}

- (void)createTableView
{
    _dataArr = [NSMutableArray arrayWithCapacity:0];
    //self.automaticallyAdjustsScrollViewInsets = false;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-60)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [self.view addSubview:_tableView];
    [self loadDataWith:@"1" isRemoveAll:NO];
    [self refreshView];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_button setImage:[UIImage imageNamed:@"index_my"] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(setClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_button];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
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
        
        QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
        QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
        regi.hidesBottomBarWhenPushed = YES;
        [self presentViewController:navController animated:YES completion:^{
            
        }];
        
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

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == _header) {
        _curNumber = 1;
        //刷新
        [self loadDataWith:[NSString stringWithFormat:@"%li", (long)_curNumber] isRemoveAll:YES];
    } else {
        _curNumber ++;
        if(_countNum/20+1 == _currNum){
            [_footer endRefreshing];
        }else{
        [self loadDataWith:[NSString stringWithFormat:@"%li", (long)_curNumber] isRemoveAll:NO];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)loadDataWith:(NSString *)cur isRemoveAll:(BOOL)isRemoveAll
{
    [self showProgessMsg:@"正在加载"];
    [ActivityService cellDataBlock:^(NSMutableDictionary *dict) {
        NSDictionary *dataDict = dict[@"Msg"][@"data"];
        _currNum = [dict[@"Msg"][@"curr"] integerValue];
        _countNum = [dict[@"Msg"][@"count"] integerValue];
        if (isRemoveAll) {
            [_dataArr removeAllObjects];
        }
        for(NSDictionary *dict in dataDict){
            ActModel *model = [[ActModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            _goodsId = model.goods_id;
            _status_id = model.good_st;
            [_dataArr addObject:model];
        }
        [self performSelectorOnMainThread:@selector(sussRes) withObject:nil waitUntilDone:YES];
        [_tableView reloadData];
        [_header endRefreshing];
        [_footer endRefreshing];
    } FailBlock:^(NSMutableArray *array) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"加载失败,请检查网络！" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }] ];
        [self presentViewController:alert animated:YES completion:nil];
    } andWithToken:save andWithCurr:cur];
}

- (void)sussRes
{
    [self hideProgess];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActCell *cell = [ActCell actCellWithTableView:_tableView];
    cell.model = _dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QDXLineDetailViewController *lineVC = [[QDXLineDetailViewController alloc] init];
    ActModel *md = (ActModel*)_dataArr[indexPath.row];
    HomeModel *homeModel = [[HomeModel alloc] init];
    homeModel.goods_id = md.goods_id;
    homeModel.goods_price = md.goods_price;
    homeModel.good_st = md.good_st;
    homeModel.goods_name = md.goods_name;
    homeModel.line = md.line;
    lineVC.homeModel = homeModel;
    lineVC.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:lineVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return QdxWidth*0.59+32+10;
}
@end
