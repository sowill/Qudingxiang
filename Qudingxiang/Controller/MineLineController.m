//
//  MineLineController.m
//  Qudingxiang
//
//  Created by Mac on 15/10/10.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "MineLineController.h"
#import "MineModel.h"
#import "QDXGameViewController.h"
#import "MineCell.h"
#import "QDXNavigationController.h"
#import "MineCellService.h"

@interface MineLineController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArr;
    NSString *_myline_id;
    int curr;
    int page;
    int count;
}
@end

@implementation MineLineController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self netData];
}

-(void)reloadData
{
    [self netData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的路线";

    [self createUI];

    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)createUI
{
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
    [_tableView.mj_header beginRefreshing];
    
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
    [self netData];
    
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
        [self netData];
    }
}

- (void)netData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    MineCellService *mineCell = [MineCellService sharedInstance];
    [mineCell cellDatasucceed:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
        if ([dict[@"Code"] intValue] == 0) {
            
        }else{
            NSArray *dictData = dict[@"Msg"][@"data"];
            if([dictData isEqual:[NSNull null]]){
                
                UIAlertController *aalert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您当前没有路线" preferredStyle:UIAlertControllerStyleAlert];
                [aalert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
                    
                }]];
                
                [self presentViewController:aalert animated:YES completion:nil];
                
            }else{
                curr = [dict[@"Msg"][@"curr"] intValue];
                page = [dict[@"Msg"][@"page"] intValue];
                
                if(curr ==1){
                    _dataArr = [NSMutableArray arrayWithCapacity:0];
                }

                for(NSDictionary *dict in dictData){
                    MineModel *model = [[MineModel alloc] init];
                    [model setValuesForKeysWithDictionary:dict];
                    [_dataArr addObject:model];
                }
                [_tableView reloadData];
                [_tableView.mj_footer endRefreshing];
            }
        }

    } failure:^(NSError *error) {

    }andWithCurr:[NSString stringWithFormat:@"%d",curr]];
        
    });
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
    cell.model = _dataArr[indexPath.row];
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
    QDXGameViewController *gameVC = [[QDXGameViewController alloc] init];

    gameVC.model = _dataArr[indexPath.row];
    
    [self.navigationController pushViewController:gameVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
