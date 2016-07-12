//
//  SettingViewController.m
//  趣定向
//
//  Created by Prince on 16/3/17.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "SettingViewController.h"
#import "QDXLoginViewController.h"
#import "QDXChangePwdViewController.h"
#import "QDXNavigationController.h"
#import "TabbarController.h"
@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    UITableView *_tableView;
    UILabel *_valueDataLabel;
    CGFloat _dataValue;
    CGFloat _folderSize;
}
@end

@implementation SettingViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _dataValue = [self folderSizeWithPath:[self getPath]];
    _valueDataLabel.text = [NSString stringWithFormat:@"%.2fMB",_dataValue];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"设置";
    [self createTableView];
    [self createButtonBack];
    
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
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    //_tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
}

-(void)viewDidLayoutSubviews
{
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 2;
    }else{
        return 1;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, QdxWidth/2, 21)];;
                nameLabel.text = @"清除图片缓存";
                nameLabel.textAlignment = NSTextAlignmentLeft;
                nameLabel.font = [UIFont systemFontOfSize:14];
                nameLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
                [cell addSubview:nameLabel];
                _valueDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth*2/3, 10, QdxWidth/3-10, 21)];
                
                _valueDataLabel.text = [NSString stringWithFormat:@"%.2fMB",_dataValue];
                _valueDataLabel.font = [UIFont systemFontOfSize:14];
                _valueDataLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
                _valueDataLabel.textAlignment = NSTextAlignmentRight;
                [cell addSubview:_valueDataLabel];
            }else{
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, QdxWidth, 21)];;
                nameLabel.text = @"修改密码";
                nameLabel.font = [UIFont systemFontOfSize:14];
                nameLabel.textAlignment = NSTextAlignmentLeft;
                nameLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
                [cell addSubview:nameLabel];
            }
        }else if(indexPath.section == 1){
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, QdxWidth, 21)];;
            nameLabel.text = @"退出登录";
            nameLabel.font = [UIFont systemFontOfSize:14];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.textColor = [UIColor redColor];
            [cell addSubview:nameLabel];
        }
        
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            [self deleteFileSize:[self folderSizeWithPath:[self getPath]]];
        }else{
            QDXChangePwdViewController *changePassWord = [[QDXChangePwdViewController alloc] init];
            [self.navigationController pushViewController:changePassWord animated:YES];
        }
    }else if(indexPath.section == 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"退出后不会删除任何历史数据,下次登录依然可以使用本账号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出登录", nil];
        alert.tag = 1;
        [alert show];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1 && alertView.tag == 1){
        NSFileManager * fileManager = [[NSFileManager alloc]init];
        NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
        [fileManager removeItemAtPath:documentDir error:nil];
        
//        [self.sideMenuViewController setContentViewController:[[TabbarController alloc] init] animated:YES];
//        [self.sideMenuViewController hideMenuViewController];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stateRefresh" object:nil];
    }else if (buttonIndex == 1 && alertView.tag == 2){
        //彻底删除文件
        [self clearCacheWith:[self getPath]];
        _valueDataLabel.text = [NSString stringWithFormat:@"%.2fMB",[self folderSizeWithPath:[self getPath]]];
        
    }
}
//首先获取缓存文件的路径
-(NSString *)getPath{
    //沙盒目录下library文件夹下的cache文件夹就是缓存文件夹
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return path;
}

-(CGFloat)folderSizeWithPath:(NSString *)path{
    //初始化文件管理类
    NSFileManager * fileManager = [NSFileManager defaultManager];float folderSize = 0.0;
    if ([fileManager fileExistsAtPath:path]){
        //如果存在
        //计算文件的大小
        NSArray * fileArray = [fileManager subpathsAtPath:path];
        for (NSString * fileName in fileArray){
            //获取每个文件的路径
            NSString * filePath = [path stringByAppendingPathComponent:fileName];
            //计算每个子文件的大小
            long fileSize = [fileManager attributesOfItemAtPath:filePath error:nil].fileSize;
            //字节数
            folderSize = folderSize + fileSize / 1024.0 / 1024.0;
        }
        //删除缓存文件
        //        [self deleteFileSize:folderSize];
        return folderSize;
    }
    return 0;
}

-(void)deleteFileSize:(CGFloat)folderSize{
    if (folderSize > 0.01){
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"缓存大小:%.2fM,是否清除？",folderSize] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 2;
        [alertView show];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"缓存已全部清理" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        [alertView show];
    }
}

-(void)clearCacheWith:(NSString *)path{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]){
        NSArray * fileArray = [fileManager subpathsAtPath:path];
        for (NSString * fileName in fileArray){
            //可以过滤掉特殊格式的文件
            if ([fileName hasSuffix:@".png"]){
                NSLog(@"不删除");}
            else{
                //获取每个子文件的路径
                NSString * filePath = [path stringByAppendingPathComponent:fileName];
                //移除指定路径下的文件
                [fileManager removeItemAtPath:filePath error:nil];
            }
        }
    }
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
