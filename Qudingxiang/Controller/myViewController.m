//
//  myViewController.m
//  Qudingxiang
//
//  Created by  stone020 on 15/9/21.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "myViewController.h"
#import "LineController.h"
#import "myViewCellTableViewCell.h"
#import "MineLineController.h"
#import "QDXChangePwdViewController.h"
#import "QDXLoginViewController.h"
#import "QDXChangeNameViewController.h"
#import "TeamLineController.h"
#import "SettingViewController.h"
#import "MineService.h"
@interface myViewController ()

@end

@implementation myViewController{
    NSDictionary *imageDict;
    NSDictionary *peopleDict;
}
   
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"我的";
    self.view.backgroundColor=[UIColor whiteColor];
    peopleDict=[[NSDictionary alloc]init];
    [self zoomInAction];
    [self myTableView];
    if ([_myTableview respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_myTableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_myTableview respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_myTableview setLayoutMargins:UIEdgeInsetsZero];
    }
    UIButton *setting = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [setting addTarget:self action:@selector(setClick) forControlEvents:UIControlEventTouchUpInside];
    [setting setImage:[UIImage imageNamed:@"icon_setup@2x"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:setting];
    
}

- (void)loadData
{
    [self performSelectorInBackground:@selector(zoomInAction) withObject:nil];
}

-(void)setClick
{
    SettingViewController *setVC = [[SettingViewController alloc] init];
    setVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setVC animated:YES];

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


-(void)myTableView{
    
    _myTableview=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-49-64) style:UITableViewStyleGrouped];
    _myTableview.dataSource=self;
    _myTableview.delegate=self;
    _myTableview.showsVerticalScrollIndicator = NO;
    _myTableview.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    _myTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];    
    [self.view addSubview:_myTableview];
    
}


-(void)zoomInAction{
    [MineService cellDataBlock:^(NSDictionary *dict) {
        NSDictionary* _dic = [[NSDictionary alloc] initWithDictionary:dict];
        peopleDict=[NSDictionary dictionaryWithDictionary:_dic];
        [self performSelectorOnMainThread:@selector(sussRes) withObject:nil waitUntilDone:YES];
        [_myTableview reloadData];

    } FailBlock:^(NSMutableArray *array) {
        [self performSelectorOnMainThread:@selector(failRes) withObject:nil waitUntilDone:YES];
    } andWithToken:save];
    
}

- (void)sussRes
{

}

- (void)failRes
{

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 4;
    }else{
        return 1;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdetify = @"SvTableViewCell";
    myViewCellTableViewCell* cell=(myViewCellTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"myViewCellTableViewCell" owner:self options:nil]lastObject];
}
    if (indexPath.section==0&&indexPath.row==0) {
        cell._name.text=@"账号";
        cell._name.textColor = [UIColor grayColor];
        cell.imageV.image = [UIImage imageNamed:@"zhanghao"];
        cell.imageV.contentMode = UIViewContentModeScaleAspectFit;
    }else if (indexPath.section==0&&indexPath.row==1){
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell._name.text=@"昵称";
        cell._name.textColor = [UIColor grayColor];
        cell.imageV.image = [UIImage imageNamed:@"nic"];
         cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.imageV.contentMode = UIViewContentModeScaleAspectFit;
    }else if (indexPath.section==0&&indexPath.row==2){
        cell._name.text=@"我的线路";
        cell._name.textColor = [UIColor grayColor];
        cell.imageV.image = [UIImage imageNamed:@"myline_lux"];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.imageV.contentMode = UIViewContentModeScaleAspectFit;
       }else if (indexPath.section==1&&indexPath.row==0){
        cell._name.text=@"修改密码";
        cell._name.textColor = [UIColor grayColor];
        cell.imageV.image = [UIImage imageNamed:@"xiu"];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.imageV.contentMode = UIViewContentModeScaleAspectFit;
       }else if(indexPath.section==0&&indexPath.row==3){
           cell._name.text=@"团队线路";
           cell._name.textColor = [UIColor grayColor];
           cell.imageV.image = [UIImage imageNamed:@"myline_lux"];
           cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
           cell.imageV.contentMode = UIViewContentModeScaleAspectFit;

       }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0&&indexPath.row==2) {
        MineLineController *mineVC = [[MineLineController alloc] init];
        mineVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:mineVC animated:YES];
    }else if (indexPath.section==0&&indexPath.row==1){
        QDXChangeNameViewController* regi=[[QDXChangeNameViewController alloc]init];
        regi.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:regi animated:YES];
    }else if(indexPath.section==1&&indexPath.row==0){
        QDXChangePwdViewController* reg=[[QDXChangePwdViewController alloc]init];
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:reg];
        [self presentViewController:navController animated:YES completion:^{
            
        }];
//        reg.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:reg animated:YES];
    }else if(indexPath.section==0&&indexPath.row==3){
        TeamLineController *teamVC = [[TeamLineController alloc] init];
        teamVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:teamVC animated:YES];
    }else if (indexPath.section == 0 && indexPath.row == 0){
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return QdxWidth/2;
    }else{
        return  15;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth/2)];
    if (section==0) {
        UIImageView * imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth/2)];
        int value = (arc4random() % 3) + 1;
        NSString *url= [hostUrl stringByAppendingString:[NSString stringWithFormat:@"index.php/public/uploads/00%u.jpg",value]];
        [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"1"]];
        [view addSubview:imageView];
    }
    return view;
}

@end
