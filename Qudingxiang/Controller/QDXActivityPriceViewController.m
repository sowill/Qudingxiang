//
//  QDXActivityPriceViewController.m
//  趣定向
//
//  Created by Air on 2017/3/8.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QDXActivityPriceViewController.h"

#import "QDXActTableViewCell.h"
#import "QDXLineDetailViewController.h"

#import "GoodsList.h"
#import "Goods.h"
#import "Area.h"

@interface QDXActivityPriceViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int curr;
    int page;
    int count;
}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *actArray;
@end

@implementation QDXActivityPriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = self.area.area_cn;
    
    [self createTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    curr = 1;
    [self getGoodsisRemoveAll:YES];
}

-(void)reloadData{
    [self getGoodsisRemoveAll:YES];
}

-(void)getGoodsisRemoveAll:(BOOL)isRemoveAll
{
    NSString *url = [newHostUrl stringByAppendingString:getGoodsUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"area_id"] = self.area.area_id;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        GoodsList *goodsList = [[GoodsList alloc] initWithDic:responseObject];
        if (isRemoveAll) {
            [_actArray removeAllObjects];
        }
        for (Goods *goods in goodsList.goodsArray) {
            [_actArray addObject:goods];
        }
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)createTableView
{
    _actArray = [NSMutableArray arrayWithCapacity:0];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, QdxWidth, QdxHeight -64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = QDXBGColor;
    //    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
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
    [self getGoodsisRemoveAll:YES];
    
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
        [self getGoodsisRemoveAll:NO];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _actArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(556 + 20);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QDXActTableViewCell *cell = [QDXActTableViewCell qdxActCellWithPriceWithTableView:_tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.goods = _actArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QDXLineDetailViewController *lineVC = [[QDXLineDetailViewController alloc] init];
    lineVC.goods = _actArray[indexPath.row];
    [self.navigationController pushViewController:lineVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
