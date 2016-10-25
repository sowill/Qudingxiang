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
#import "LBTabBarController.h"
#import "QDXNavigationController.h"
#import "MineCellService.h"
@interface MineLineController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArr;
    NSString *_myline_id;
}
@end

@implementation MineLineController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(save){
    [self netData];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的路线";
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [self createButtonBack];
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
    [self.sideMenuViewController setContentViewController:[[LBTabBarController alloc] init]
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];
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

}
- (void)netData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self showProgessMsg:@"加载中"];
    MineCellService *mineCell = [MineCellService sharedInstance];
    [mineCell cellDatasucceed:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
        [self hideProgess];
        if ([dict[@"Code"] intValue] == 0) {
            
        }else{
            NSArray *dictData = dict[@"Msg"][@"data"];
            if([dictData isEqual:[NSNull null]]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您当前没有路线" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                _dataArr = [NSMutableArray arrayWithCapacity:0];
                for(NSDictionary *dict in dictData){
                    MineModel *model = [[MineModel alloc] init];
                    [model setValuesForKeysWithDictionary:dict];
                    [_dataArr addObject:model];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                    
                });
                
            }
        }

    } failure:^(NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"加载失败，请检查网络！" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]
         ];
        [self presentViewController:alert animated:YES completion:^{
            
        }];

    }];
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
