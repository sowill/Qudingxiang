//
//  TeamLineController.m
//  趣定向
//
//  Created by Prince on 16/3/14.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "TeamLineController.h"
#import "QDXGameViewController.h"
#import "MineModel.h"
#import "MineCell.h"
#import "TabbarController.h"
#import "QDXNavigationController.h"
@interface TeamLineController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArr;

}
@end

@implementation TeamLineController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"团队路线";
    self.view.backgroundColor = [UIColor colorWithRed:35/255 green:138/255 blue:215/255 alpha:1];
    [self netData];
    [self createUI];
    [self createButtonBack];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)createButtonBack
{
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonBack.frame = CGRectMake(0, 0, 18, 14);
    [buttonBack addTarget:self action:@selector(buttonBackSetting) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setTitle:nil forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"sign_return"] forState:UIControlStateNormal];
    buttonBack.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

-(void)buttonBackSetting
{
    [self.sideMenuViewController setContentViewController:[[TabbarController alloc] init]
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];

}

- (void)createUI
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [self.view addSubview:_tableView];
    
}
- (void)netData
{
    [self showProgessMsg:@"加载中"];
    NSString *url = [NSString stringWithFormat:@"%@%@",hostUrl,teamUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"curr"] = @"1";
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dict = [NSDictionary dictionaryWithDictionary:responseObject];
        //NSLog(@"%@",dict);
        if (!dict[@"Code"]) {
            NSLog(@"没有线路");
        }else{
            //            NSLog(@"信息%@",dict[@"Msg"]);
            NSArray *dictData = dict[@"Msg"][@"data"];
            if([dictData isEqual:[NSNull null]]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您当前没有路线" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                [alert show];
            }else{
                
                _dataArr = [NSMutableArray arrayWithCapacity:0];
                for(NSDictionary *dict in dictData){
                    MineModel *model = [[MineModel alloc] init];
                    [model setValuesForKeysWithDictionary:dict];
                    [_dataArr addObject:model];
                }
                [_tableView reloadData];
                [self hideProgess];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    cell.model = _dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return QdxHeight*0.13+10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QDXGameViewController *gameVC = [[QDXGameViewController alloc] init];
    QDXNavigationController *nav  = [[QDXNavigationController alloc] initWithRootViewController:gameVC];
    gameVC.model = _dataArr[indexPath.row];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
