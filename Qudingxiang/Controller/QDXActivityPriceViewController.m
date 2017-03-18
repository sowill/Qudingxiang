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
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *actArray;
@end

@implementation QDXActivityPriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = self.area.area_cn;
    
    [self createTableView];
    [self getGoods];
}

-(void)getGoods
{
    _actArray = [NSMutableArray arrayWithCapacity:0];
    NSString *url = [newHostUrl stringByAppendingString:getGoodsUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"area_id"] = self.area.area_id;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        GoodsList *goodsList = [[GoodsList alloc] initWithDic:responseObject];
        for (Goods *goods in goodsList.goodsArray) {
            [_actArray addObject:goods];
        }
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)createTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, QdxWidth, QdxHeight -64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = QDXBGColor;
    //    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // 设置了底部inset
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    // 忽略掉底部inset
    _tableView.mj_footer.ignoredScrollViewContentInsetBottom = 30;
    
    [self.view addSubview:self.tableView];
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
    lineVC.homeModel = _actArray[indexPath.row];
    [self.navigationController pushViewController:lineVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
