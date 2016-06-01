//
//  QDXHistoryViewController.m
//  趣定向
//
//  Created by Air on 16/5/4.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXHistoryViewController.h"
#import "QDXHistoryTableViewCell.h"
#import "QDXHIstoryModel.h"
#import "QDXGameModel.h"
#import "QDXPointModel.h"

@interface QDXHistoryViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, weak) MJRefreshHeaderView *header;
@end

@implementation QDXHistoryViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    self.title = @"定向足迹";
    [self createTableView];
}

-(void)createTableView
{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,10, QdxWidth, QdxHeight-64-10) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.Game.history.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QDXHistoryTableViewCell *cell = [QDXHistoryTableViewCell cellWithTableView:tableView];
//    cell.GameInfo = self.Game;
    cell.HistoryInfo = self.Game.history[self.Game.history.count-1 - indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 40)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, QdxWidth *  0.7 , 20)];
    header.text = @"定向足迹";
    header.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
    header.font = [UIFont fontWithName:@"Arial" size:15];
    [headerView addSubview:header];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40 -1, QdxWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [headerView addSubview:lineView];
    return headerView;
}

@end
