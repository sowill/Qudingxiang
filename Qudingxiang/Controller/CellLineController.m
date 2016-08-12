//
//  CellLineController.m
//  Qudingxiang
//
//  Created by Mac on 15/10/22.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "CellLineController.h"
#import "QDXLineDetailViewController.h"
#import "CellModel.h"
#import "HomeCell.h"
#import "HomeModel.h"


//#import "QDXLineChooseViewController.h"

@interface CellLineController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArr;
}
@end

@implementation CellLineController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"路线选择";
    [self createTableView];
    [self netData];
//    [self creatButtonBack];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }

    
}

- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-49-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
}

- (void)netData
{
    NSString *url = [NSString stringWithFormat:@"%@%@",hostUrl,areaUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"area_id"] = _model.area_id;
    BaseService *cellData = [BaseService sharedInstance];
    [cellData POST:url dict:params succeed:^(id data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
        NSDictionary *dictArr = dict[@"Msg"][@"data"];
        NSString *dictA =dict[@"Msg"][@"data"];
        
        if([dictA isEqual:[NSNull null]]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有有效信息,敬请期待" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            [alert show];
            
        }else{
            //将字典转模型
            _dataArr = [NSMutableArray arrayWithCapacity:0];
            for(NSDictionary *dict in dictArr){
                CellModel *model = [[CellModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [_dataArr addObject:model];
            }
            [_tableView reloadData];
            
        }

    } failure:^(NSError *error) {
        
    }];
//    [BaseService netDataBlock:^(NSMutableDictionary *dict) {
//        NSDictionary *dictArr = dict[@"Msg"][@"data"];
//        NSString *dictA =dict[@"Msg"][@"data"];
//        
//        if([dictA isEqual:[NSNull null]]){
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有有效信息,敬请期待" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
//            [alert show];
//            
//        }else{
//            //将字典转模型
//            _dataArr = [NSMutableArray arrayWithCapacity:0];
//            for(NSDictionary *dict in dictArr){
//                CellModel *model = [[CellModel alloc] init];
//                [model setValuesForKeysWithDictionary:dict];
//                [_dataArr addObject:model];
//            }
//            [_tableView reloadData];
//            
//        }
//
//    } FailBlock:^(NSMutableArray *array) {
//        
//    } andWithUrl:url andParams:params];
    
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
    HomeCell *cell = [HomeCell baseCellWithTableView:_tableView];
//    UIImageView *IV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 40, 50)];
//    IV.backgroundColor = [UIColor clearColor];
//    IV.image = [UIImage imageNamed:[NSString stringWithFormat:@"j%li",(indexPath.row)%6]];
//    [cell addSubview:IV];
    cell.model = _dataArr[indexPath.row];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QDXLineDetailViewController *lineVC = [[QDXLineDetailViewController alloc] init];
    lineVC.hidesBottomBarWhenPushed =YES;
    //lineVC.model = _dataArr[indexPath.row];
    [self.navigationController pushViewController:lineVC animated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
