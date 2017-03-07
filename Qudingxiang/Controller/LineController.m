//
//  LineController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/18.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "LineController.h"
#import "QDXLineDetailViewController.h"
#import "HomeController.h"
#import "LineCell.h"
#import "LineModel.h"
#import "HomeModel.h"
#import "QDXLineChooseViewController.h"
#import "ImagePickerController.h"
#import "QDXGameViewController.h"
#import "QDXProtocolViewController.h"
//#import "TabbarController.h"
#import "QDXNavigationController.h"
#import "AppDelegate.h"
@interface LineController ()<UITableViewDataSource,UITableViewDelegate,PassTicketIDDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArr;
    BOOL _isEnterToGame;
    UIImageView *_imageView;
    UIButton *_button;
    NSInteger _state;
    NSString *_str;
    NSInteger *_row;
}
@property(nonatomic,strong)NSMutableArray * dataA;
@end

@implementation LineController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"路线选择";
    _isEnterToGame = NO;
    [self btnData];
    [self createTableView];
    [self creatButtonBack];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti2) name:@"noti2" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti3) name:@"noti3" object:nil];
}

-(void)reloadData
{
    [self btnData];
}

-(void)noti3
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)noti2
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight  - 64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
}



// 返回按钮
- (void)creatButtonBack
{
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonBack.frame = CGRectMake(0, 0, 24, 24);
    [buttonBack addTarget:self action:@selector(buttonBackSetting) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setTitle:nil forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"sign_return"] forState:UIControlStateNormal];
    buttonBack.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -0;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
    
}

- (void)viewDidLayoutSubviews
{
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)buttonBackSetting
{
    //    HomeController *homeVC = [[HomeController alloc] init];
    //    UIViewController *target = nil;
    //    for(UIViewController *controller in self.navigationController.viewControllers){
    //        if([controller isKindOfClass:[homeVC class]]){
    //            target = controller;
    //        }
    //    }
    //    if(target){
    //        [self.navigationController popToViewController:target animated:YES];
    //    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti1" object:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

-(void)dealloc

{
    //移除观察者，Observer不能为nil
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)btnData
{
    NSString *url = [NSString stringWithFormat:@"%@%@",hostUrl,ticketUrl];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"ticket_id"] = self.ticketID;
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict1 = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:dict1];
        if ([dict[@"Code"] intValue] == 0) {
            
        }else{
            //将字典转模型
            NSDictionary *dictArr = dict[@"Msg"][@"data"];
            _dataArr = [NSMutableArray arrayWithCapacity:0];
            for(NSDictionary *dict in dictArr){
                LineModel *model = [[LineModel alloc] init];
                [model setValuesForKeysWithDictionary:dict[@"line"]];
                [model setLine_code:@"1"];
                if(_isEnterToGame){
                    [model setLine_line:@"1"];
                }else
                {
                    [model setLine_line:@"0"];
                }
                [_dataArr addObject:model];
            }
        }
        [_tableView reloadData];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LineCell *cell = [LineCell baseCellWithTableView:_tableView];
    cell.lineModel = _dataArr[indexPath.row];
    cell.select = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailClick= ^(){
        QDXLineChooseViewController *choiceVC = [[QDXLineChooseViewController alloc] init];
        choiceVC.model = _dataArr[indexPath.row];
        [self.navigationController pushViewController:choiceVC animated:YES];
    };
    cell.quickClick = ^(){
        
        cell.select = 1;
        _str = cell.lineModel.line_id;
        
        UIAlertController *aalert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要选择本条线路吗?" preferredStyle:UIAlertControllerStyleAlert];
        [aalert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
            
        }]];
        [aalert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
            
            AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
            mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"TokenKey"] = save;
            params[@"line_id"] = _str;
            NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Myline/selectMyline"];
            [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
                int ret = [infoDict[@"Code"] intValue];
                if (ret == 1) {
                    QDXProtocolViewController *viewController = [[QDXProtocolViewController alloc] init];
                    [self.navigationController pushViewController:viewController animated:YES];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@",infoDict[@"Msg"]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    [_tableView reloadData];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
            
        }]];
        
        [self presentViewController:aalert animated:YES completion:nil];
        
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return QdxHeight*0.114 +10;
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

- (void)PassTicket:(NSString *)tictet andClick:(NSString *)click
{
    _ticketID = tictet;
    self.click = click;
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
