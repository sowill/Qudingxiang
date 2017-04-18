//
//  QDXPointListViewController.m
//  趣定向
//
//  Created by Air on 2016/11/7.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXPointListViewController.h"
#import "QDXPointSettingViewController.h"
#import "PointModel.h"

@interface QDXPointListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSArray *pointArray;
}
@end

@implementation QDXPointListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(24))];
    headerView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return FitRealValue(24);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"点标管理";
    
    self.view.backgroundColor = QDXBGColor;
    
    [self getPointList];
}

-(void)getPointList
{
    NSString *url = [newHostUrl stringByAppendingString:getPointListUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        int ret = [responseObject[@"Code"] intValue];
        if (ret == 1) {
            pointArray = [PointModel mj_objectArrayWithKeyValuesArray:responseObject[@"Msg"]];
            [self createTableView];
        }else{
            
        }
        
    } failure:^(NSError *error) {
        
    }];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(96);
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QDXPointSettingViewController *pointSettingVC = [[QDXPointSettingViewController alloc] init];
    PointModel *pointModel =pointArray[indexPath.row];
    pointSettingVC.pointModel = pointModel;
    [self.navigationController pushViewController:pointSettingVC animated:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return pointArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    PointModel *point =pointArray[indexPath.row];
    cell.textLabel.text = point.point_cn;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

@end
