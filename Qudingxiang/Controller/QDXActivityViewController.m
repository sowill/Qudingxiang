//
//  QDXActivityViewController.m
//  趣定向
//
//  Created by Air on 2016/12/14.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXActivityViewController.h"
#import "HomeService.h"
#import "HomeModel.h"
#import "QDXActTableViewCell.h"
#import "QDXLineDetailViewController.h"

@interface QDXActivityViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    HomeService *homehttp;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *actArray;

@end

@implementation QDXActivityViewController

- (NSMutableArray *)actArray
{
    if (_actArray == nil) {
        _actArray = [NSMutableArray array];
    }
    return _actArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = QDXBGColor;
    self.navigationItem.title = _navTitle;
    homehttp = [HomeService sharedInstance];
    [self cellDataWith:@"1" andWithType:_type];
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
    
    [self.view addSubview:self.tableView];
}

- (void)cellDataWith:(NSString *)cur andWithType:(NSString *)type
{
    [homehttp loadCellsucceed:^(id data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
        NSDictionary *dataDict = dict[@"Msg"][@"data"];
        _actArray = [[NSMutableArray alloc] init];
        for(NSDictionary *dict in dataDict){
            HomeModel *model = [[HomeModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            [_actArray addObject:model];
        }
        
        [self createTableView];
        
    } failure:^(NSError *error) {
            
    } WithCurr:cur WithType:type];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _actArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(638);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QDXActTableViewCell *cell = [QDXActTableViewCell qdxActCellWithTableView:_tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.homeModel = _actArray[indexPath.row];
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
