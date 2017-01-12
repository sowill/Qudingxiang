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

@interface ActivityController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger currNum;
    NSInteger page;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArr;
@end

@implementation ActivityController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadDataWith:@"1" isRemoveAll:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = QDXBGColor;
    self.navigationItem.title = @"活动";
    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 20, 18);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"index_my"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    [self createTableView];
}

-(void)reloadData
{
    [self loadDataWith:@"1" isRemoveAll:NO];
}

- (void)createTableView
{
    _dataArr = [NSMutableArray arrayWithCapacity:0];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - 49 - 64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    [self refreshView];
}

- (void)refreshView
{
    // 1.下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
//    [_tableView.mj_header beginRefreshing];
    
    // 2.上拉刷新(上拉加载更多数据)
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    // 忽略掉底部inset
    _tableView.mj_footer.ignoredScrollViewContentInsetBottom = 30;
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    currNum = 1;
    //刷新
    [self loadDataWith:[NSString stringWithFormat:@"%li", (long)currNum] isRemoveAll:YES];
    // 刷新表格
    [_tableView reloadData];
    // 拿到当前的下拉刷新控件，结束刷新状态
    [_tableView.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    currNum ++;
    if(currNum > page){
        // 刷新表格
        [_tableView reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        [_tableView.mj_footer endRefreshingWithNoMoreData];
       
    }else{
        [self loadDataWith:[NSString stringWithFormat:@"%li", (long)currNum] isRemoveAll:NO];
    }
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
//    {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
//    {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}

- (void)loadDataWith:(NSString *)cur isRemoveAll:(BOOL)isRemoveAll
{
    [ActivityService cellDataBlock:^(NSDictionary *dict) {
        NSDictionary *dataDict = dict[@"Msg"][@"data"];
        
        if (![dict[@"Msg"][@"count"] isEqualToString:@"0"]){
            currNum = [dict[@"Msg"][@"curr"] integerValue];
            page = [dict[@"Msg"][@"page"] integerValue];
            if (isRemoveAll) {
                [_dataArr removeAllObjects];
            }
            for(NSDictionary *dict in dataDict){
                ActModel *model = [[ActModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [_dataArr addObject:model];
            }
        }
        
        [_tableView.mj_footer endRefreshing];
        [_tableView reloadData];
        
    } FailBlock:^(NSMutableArray *array) {
        
    } andWithToken:save andWithCurr:cur];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(528);
}

@end
