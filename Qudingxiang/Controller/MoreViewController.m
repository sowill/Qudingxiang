//
//  MoreViewController.m
//  趣定向
//
//  Created by Prince on 16/4/1.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "MoreViewController.h"
#import "QDXNavigationController.h"
#import "QDXLoginViewController.h"
//#import "XDMultTableView.h"
#import "DWViewCell.h"
#import "DWFlowLayout.h"
#import "MCLeftSliderManager.h"

//@interface MoreViewController ()<UIAlertViewDelegate,XDMultTableViewDatasource,XDMultTableViewDelegate>
//@interface MoreViewController ()<UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>
@interface MoreViewController ()<UIAlertViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    UIButton *_button;
//    UILabel *rowOne;
//    UILabel *rowTwo;
//    UILabel *rowThree;
    NSArray *data;
}
//@property(nonatomic, readwrite, strong)XDMultTableView *tableView;
//@property(nonatomic, readwrite, strong)UITableView *tableView;
@property(nonatomic, readwrite, strong)UICollectionView *collectionView;
@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"玩法";
    self.view.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    
//    [self createUI];
    
//    [self createTableView];
    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 20, 18);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"index_my"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    DWFlowLayout *layout = [[DWFlowLayout alloc] init];
    //设置是否需要分页
//    layout.move_x = - FitRealValue(60);
    [layout setPagingEnabled:YES];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - 64) collectionViewLayout:layout];
    [_collectionView registerClass:[DWViewCell class] forCellWithReuseIdentifier:@"DWViewCell"];
    _collectionView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    
    data = @[@"01",@"02",@"03"];
    [_collectionView reloadData];
}

- (void) openOrCloseLeftList
{
    
    if ([MCLeftSliderManager sharedInstance].LeftSlideVC.closed)
    {
        [[MCLeftSliderManager sharedInstance].LeftSlideVC openLeftView];
    }
    else
    {
        [[MCLeftSliderManager sharedInstance].LeftSlideVC closeLeftView];
    }
}

#pragma mark cell的数量
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return data.count;
}

#pragma mark cell的视图
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"DWViewCell";
    DWViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    if (row == 0) {
        cell.showImg.image = [UIImage imageNamed:@"依次穿越"];
        cell.showLab.text = @"依次穿越";
        cell.showText.text = @"依次按提示依次到达各点标，直至终点，用时少胜。";
    }else if (row == 1){
        cell.showImg.image = [UIImage imageNamed:@"自由规划"];
        cell.showLab.text = @"自由规划";
        cell.showText.text = @"一次性给出所有点标，自行规划线路，直至寻访所有点标，用时少胜。";
    }else{
        cell.showImg.image = [UIImage imageNamed:@"自由挑战"];
        cell.showLab.text = @"自由挑战";
        cell.showText.text = @"一次性给出所有点标，在规定时间内，以寻访点标数量多为胜。";
    }
    return cell;
}

#pragma mark cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(FitRealValue(574), FitRealValue(938));
}

#pragma mark cell的点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击图片%ld",indexPath.row);
}



//- (void) createTableView
//{
////    _tableView = [[XDMultTableView alloc] initWithFrame:CGRectMake(0,0, QdxWidth, QdxHeight-64)];
////    _tableView.delegate = self;
////    _tableView.datasource = self;
////    _tableView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
////    _tableView.openSectionArray = [NSArray arrayWithObjects:@0,nil];
////    [self.view addSubview:self.tableView];
//    
//    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,10, QdxWidth, QdxHeight-64-60) style:UITableViewStylePlain];
//    _tableView.delegate = self;
//    _tableView.dataSource = self;
//    _tableView.showsVerticalScrollIndicator = NO;
//    _tableView.rowHeight = 117;
//    _tableView.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
//    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.view addSubview:_tableView];
//}

//#pragma mark - Table view data source
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 3;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CMainCell = @"CMainCell";     //  0
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];      //   1
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: CMainCell];    //  2
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
////    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
//    
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 150)];
//    bgView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
//    [cell addSubview:bgView];
//    
//    UIView *frontView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, QdxWidth - 20, 130)];
//    frontView.backgroundColor = [UIColor whiteColor];
//    [bgView addSubview:frontView];
//    
//    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
//    
//    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.000 green:0.600 blue:0.992 alpha:1.000].CGColor,(__bridge id)[UIColor blueColor].CGColor];
//    gradientLayer.startPoint = CGPointMake(0, 1);
//    gradientLayer.endPoint = CGPointMake(1, 1);
//    gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(frontView.frame), CGRectGetHeight(frontView.frame));
//    [frontView.layer addSublayer:gradientLayer];
//    
//    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, QdxWidth - 20, 30)];
//    [frontView addSubview:infoLabel];
//    
//    if (indexPath.row == 0) {
//        infoLabel.text = @"依次穿越";
//    }else if (indexPath.row == 1){
//        infoLabel.text = @"自由规划";
//    }else{
//        infoLabel.text = @"自由挑战";
//    }
//    
//    return cell;
//}
//
//#pragma mark - 代理方法
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 150;
//}


//#pragma mark - datasource
//- (NSInteger)mTableView:(XDMultTableView *)mTableView numberOfRowsInSection:(NSInteger)section{
//    return 1;
//}
//
//- (XDMultTableViewCell *)mTableView:(XDMultTableView *)mTableView
//              cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *cellIdentifier = @"cell";
//    UITableViewCell *cell = [mTableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    UIView *view = [[UIView alloc] initWithFrame:cell.bounds] ;
//    view.layer.backgroundColor  = [UIColor whiteColor].CGColor;
//    view.layer.masksToBounds    = YES;
//    view.layer.borderWidth      = 10;
//    view.layer.borderColor      = [UIColor colorWithWhite:0.961 alpha:1.000].CGColor;
//    
//    cell.backgroundView = view;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//
//
//    
//    if (indexPath.section==0) {
//        rowOne = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, QdxWidth - 20, 300-20)];
//        rowOne.numberOfLines = 0;
//        rowOne.text = @"本线路为依次穿越式，即从点标处获取任务并完成，按照顺序从起点到达终点。所有参赛队员严禁在比赛过程中故意跟随其它队伍，或是损藏比赛器材。";
//        [view addSubview:rowOne];
//    }else if (indexPath.section==1){
//        rowTwo = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, QdxWidth - 20, 300-20)];
//        rowTwo.numberOfLines = 0;
//        rowTwo.text = @"本线路为自由规划式，即从点标处获取任务并完成，按照顺序从起点到达终点。若发现有身体不适的参赛队员，要及时帮助联系并给予救助。";
//        [view addSubview:rowTwo];
//    }else if(indexPath.section==2){
//        rowThree = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, QdxWidth - 20, 300-20)];
//        rowThree.numberOfLines = 0;
//        rowThree.text = @"本线路为自由挑战式，即从点标处获取任务并完成，按照顺序从起点到达终点。所有参赛队员必须坚持“安全第一、友谊第一”的运动精神.";
//        [view addSubview:rowThree];
//    }
//    
//    return cell;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(XDMultTableView *)mTableView{
//    return 3;
//}
//
//-(NSString *)mTableView:(XDMultTableView *)mTableView titleForHeaderInSection:(NSInteger)section{
//    if (section == 0){
//        return @"依次穿越";
//    }else if (section == 1){
//        return @"自由规划";
//    }else{
//        return @"自由挑战";
//    }
//}
//
//#pragma mark - delegate
//- (CGFloat)mTableView:(XDMultTableView *)mTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 300;
//}
//
//- (CGFloat)mTableView:(XDMultTableView *)mTableView heightForHeaderInSection:(NSInteger)section{
//    return 100;
//}
//
//
//- (void)mTableView:(XDMultTableView *)mTableView willOpenHeaderAtSection:(NSInteger)section{
//
//}
//
//
//- (void)mTableView:(XDMultTableView *)mTableView willCloseHeaderAtSection:(NSInteger)section{
//    if (section == 0) {
//        rowOne.text = nil;
//        [rowOne removeFromSuperview];
//    }else if (section == 1){
//        rowTwo.text = nil;
//        [rowTwo removeFromSuperview];
//    }else if (section == 2){
//        rowThree.text = nil;
//        [rowThree removeFromSuperview];
//    }
//}
//
//- (void)mTableView:(XDMultTableView *)mTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"点击cell");
//}

- (void)createUI
{
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(QdxWidth/2-28, QdxHeight/5, 57, 68)];
    image.image = [UIImage imageNamed:@"程序员哥哥"];
    [self.view addSubview:image];
    CGFloat imageMaxY = CGRectGetMaxY(image.frame);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageMaxY + QdxHeight*0.018, QdxWidth, 10)];
    label.text = @"程序员哥哥正在搭建社区模块";
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    [self.view addSubview:label];
    CGFloat labelMaxY = CGRectGetMaxY(label.frame);
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, labelMaxY + QdxHeight*0.018, QdxWidth, 10)];
    label1.text = @"敬请期待~~";
    label1.font = [UIFont systemFontOfSize:12];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    [self.view addSubview:label1];
    
//    _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    [_button setImage:[UIImage imageNamed:@"index_my"] forState:UIControlStateNormal];
//    [_button addTarget:self action:@selector(setClick) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_button];
//    
//    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_button];
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    negativeSpacer.width = -10;
//    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

- (void)setClick
{
    if(save == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆后才可使用此功能" delegate:self cancelButtonTitle:@"暂不登录" otherButtonTitles:@"立即登录", nil];
        [alert show];
    }else{
//        [self.sideMenuViewController presentLeftMenuViewController];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }else if(buttonIndex == 1){

        QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
        QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
        regi.hidesBottomBarWhenPushed = YES;
        [self presentViewController:navController animated:YES completion:^{
            
        }];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
