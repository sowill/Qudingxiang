//
//  MineLineController.m
//  Qudingxiang
//
//  Created by Mac on 15/10/10.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "MineLineController.h"

#import "BaseGameViewController.h"
#import "MineCell.h"
#import "QDXStateView.h"
#import "MylineList.h"
#import "Myline.h"
#import "QDXProtocolViewController.h"

@interface MineLineController ()<UITableViewDataSource,UITableViewDelegate,StateDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArr;
    NSMutableArray *_myline_idArr;
    NSString *_myline_id;
    int curr;
    int page;
    int count;
}
@property (nonatomic, strong) QDXStateView *noThingView;
@end

@implementation MineLineController

-(void)reloadData
{
    [self netDataisRemoveAll:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的路线";
    
    [self createUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    curr = 1;
    [self netDataisRemoveAll:YES];
}

- (void)createUI{
    _dataArr = [NSMutableArray arrayWithCapacity:0];
    _myline_idArr = [NSMutableArray arrayWithCapacity:0];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    [self setupRefreshView];
}

/**
 *  集成刷新控件
 */
- (void)setupRefreshView
{
    // 1.下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
//    [_tableView.mj_header beginRefreshing];
    
    // 2.上拉刷新(上拉加载更多数据)
    //    self.tableview.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
    //        [weakSelf loadMoreData];
    //    }];
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    //    self.tableview.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    //    // 忽略掉底部inset
    //    self.tableview.mj_footer.ignoredScrollViewContentInsetBottom = 30;
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    curr = 1;
    [self netDataisRemoveAll:YES];
    
    // 刷新表格
    [_tableView reloadData];
    // 拿到当前的下拉刷新控件，结束刷新状态
    [_tableView.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    curr++;
    if(curr > page ){
        // 刷新表格
        [_tableView reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self netDataisRemoveAll:NO];
    }
}

- (void)netDataisRemoveAll:(BOOL)isRemoveAll
{
    NSString *url = [newHostUrl stringByAppendingString:getListUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    params[@"curr"] = [NSString stringWithFormat:@"%d",curr];
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        
        MylineList *mylineList = [[MylineList alloc] initWithDic:responseObject];
        count = [mylineList.count intValue];
        curr = [mylineList.curr intValue];
        page = [mylineList.allpage intValue];
        
        [_noThingView removeFromSuperview];
        if (count == 0) {
            [self createSadViewWithDetail: @"还没有线路哦~"];
        }else{
            if (isRemoveAll) {
                [_dataArr removeAllObjects];
                [_myline_idArr removeAllObjects];
            }
            for (Myline *myline in mylineList.mylineArray) {
                [_dataArr addObject:myline];
                [_myline_idArr addObject:myline.myline_id];
            }
        }
        [_tableView.mj_footer endRefreshing];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

-(void)changeState
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createSadViewWithDetail :(NSString *)detail
{
    _noThingView = [[QDXStateView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - 49)];
    _noThingView.tag = 2;
    _noThingView.delegate = self;
    _noThingView.stateImg.image = [UIImage imageNamed:@"order_nothing"];
    if ([detail length] == 0) {
        _noThingView.stateDetail.text = @"还没有线路哦~";
    }else{
        _noThingView.stateDetail.text = detail;
    }
    [_noThingView.stateButton setTitle:@"返回上一页" forState:UIControlStateNormal];
    [self.view addSubview:_noThingView];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MineCell *cell = [MineCell baseCellWithTableView:_tableView];
    cell.myline = _dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(170);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([mylineid length] == 0) {
        QDXProtocolViewController *portocolVC = [[QDXProtocolViewController alloc] init];
        portocolVC.myline_id = _myline_idArr[indexPath.row];
        [self.navigationController pushViewController:portocolVC animated:YES];
    }else{
        BaseGameViewController *game = [[BaseGameViewController alloc] init];
        game.myline_id = _myline_idArr[indexPath.row];
        [self.navigationController pushViewController:game animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
