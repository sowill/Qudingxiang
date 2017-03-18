//
//  RecentActivityViewController.m
//  趣定向
//
//  Created by Air on 2017/3/17.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "RecentActivityViewController.h"

#import "QDXActTableViewCell.h"
#import "QDXLineDetailViewController.h"
#import "Goods.h"
#import "GoodsList.h"

@interface RecentActivityViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSString *url;
    int curr;
    int page;
    int count;
}
@property (nonatomic,strong) NSMutableArray *recentArray;

@property (nonatomic,strong)UITableView *tableView;

@end

static NSString *QDXSlideTableCellIdentifier = @"QDXSlideTableCellIdentifier";

@implementation RecentActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpTableView];
    
    [self getMatchorAction];
    
}

-(void)getMatchorAction
{
    _recentArray = [NSMutableArray arrayWithCapacity:0];
    if ([_typeId isEqualToString:@"2"]){
        url = [newHostUrl stringByAppendingString:getMatchUrl];
    }else{
        url = [newHostUrl stringByAppendingString:getActionUrl];
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"city_id"] = _cityId;
    params[@"goodstatus_id"] = _stateId;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        GoodsList *goodsList = [[GoodsList alloc] initWithDic:responseObject];
        curr = [goodsList.curr intValue];
        count = [goodsList.count intValue];
        page = [goodsList.allpage intValue];
        for (Goods *goods in goodsList.goodsArray) {
            [_recentArray addObject:goods];
        }
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

-(void)setUpTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, QdxWidth, QdxHeight - 40 - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = QDXBGColor;
    //    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.tableView registerClass:[QDXActTableViewCell class] forCellReuseIdentifier:QDXSlideTableCellIdentifier];
    
    [self setupRefreshView];
    
    [self.view addSubview:self.tableView];
}

/**
 *  集成刷新控件
 */
- (void)setupRefreshView
{
    // 1.下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
//    [self.tableView.mj_header beginRefreshing];
    
    // 2.上拉刷新(上拉加载更多数据)
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    // 忽略掉底部inset
    //    self.tableView.mj_footer.ignoredScrollViewContentInsetBottom = 30;
    
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    curr = 1;
    [self getMatchorAction];
    
    // 刷新表格
    [self.tableView reloadData];
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    curr++;
    if(curr > page ){
        // 刷新表格
        [self.tableView reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self getMatchorAction];
    }
}


#pragma mark - tableView的代理方法 -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.recentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QDXActTableViewCell *cell = [QDXActTableViewCell qdxActCellWithTableView:self.tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.goods = self.recentArray[indexPath.row];
    return cell;
}

#pragma mark - 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(556 + 20);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate goodsCellSelectedWith:self.recentArray[indexPath.row]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
