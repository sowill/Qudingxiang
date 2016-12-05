//
//  QDXGameViewController.m
//  Qudingxiang
//
//  Created by Air on 15/9/29.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXGameViewController.h"
#import "QRCodeGenerator.h"
//#import "HomeController.h"
#import "QDXTeamsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ImagePickerController.h"
#import "QDXGameModel.h"
#import "QDXTeamsModel.h"
#import "LineModel.h"
#import "QDXHIstoryModel.h"
#import "QDXPointModel.h"
#import "QDXAreaModel.h"
#import "QDXQuestionModel.h"
#import "point_questionModel.h"
#import "line_pointModel.h"
#import "LrdOutputView.h"
#import "QDXHistoryViewController.h"
#import "QDXHistoryTableViewCell.h"
#import "CYAlertController.h"
#import "PointAnnotationView.h"
#import "QDXMap.h"
//#import "TTSExample.h"
#import "QDXIsConnect.h"
//#import "QDXOffLineController.h"
#import "HelpViewController.h"
#import "YLPopViewController.h"
#import "UIView+EAFeatureGuideView.h"
#import "LocalDBService.h"
#import <WebKit/WebKit.h>

#define READYVIEWHEIGHT                    QdxHeight * 0.05
#define WEBVIEWHEIGHT                      QdxHeight * 0.95
#define SCOREVIEWHEIGHT                    QdxHeight * 0.28
#define MAPVIEWHEIGHT                      QdxHeight * 0.72
#define TASKWEIGHT                         QdxWidth * 0.875
#define TASKHEIGHT                         QdxHeight * 0.73
#define SHOWTASKHEIGHT                     TASKHEIGHT * 0.1

@interface QDXGameViewController () <LrdOutputViewDelegate>
{
    //搜索到的mac值
    NSString *macStr;
    
    //要求获取的mac值不带冒号用来比较
    NSArray *mac_Label;
    NSString *rmoveMacStr;
    
    //回答
    NSString *answer;
    
    NSString *oldMyLineid;
    
    BOOL lock;
    BOOL lockContinue;
    int offlinei;
    int errorCount;
    
    //准备开始view
    UIView *readyView;

    NSString *questionUrl;
    //游戏中
    UIView *playView;
    UILabel *useTime;
    int secondsCountDown;
    NSTimer *countDownTimer;
    NSString *sdateStr;

    UILabel *currentTime;
    UIView *playLineView_One;
    UIView *playLineView_Two;
    UILabel *point;
    UILabel *point_name;
    UILabel *score_sum;
    UILabel *score_sum_name;

    UIButton *showMsg_button;
    UIImageView *successView;
    UIButton *showOK_button;
    UIButton *showTitle_button;
    UIButton *cancel_button;
    UIView *buttom_line;
    //游戏完成
    UIImageView *certificate;
    BOOL mapClick;

    MAPointAnnotation *annotation_target;
    MAGroundOverlay *groundOverlay;
}
@property (nonatomic,retain) WKWebView *webView;
@property (nonatomic, strong) QDXGameModel *gameInfo;
@property (nonatomic, strong) point_questionModel *questionInfo;
@property (nonatomic, strong) QDXIsConnect *resultInfo;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) LrdOutputView *outputView;
@property (nonatomic ,strong) UIView *BGView; //遮罩
@property (nonatomic ,strong) UIView *deliverView; //底部View
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic,strong) UIScrollView *QDXScrollView;
@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) CBCentralManager *MyCentralManager;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@end

@implementation QDXGameViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self creatButtonBack];
    
    self.QDXScrollView =[[UIScrollView alloc] initWithFrame:self.view.frame];
    self.QDXScrollView.showsVerticalScrollIndicator = FALSE;
    self.QDXScrollView.backgroundColor = QDXBGColor;
    [self.view addSubview:self.QDXScrollView];
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
}

- (void)showGuideView
{
    CGRect rect = CGRectMake(QdxWidth - 38, 20, 36, 36);
    EAFeatureItem *title = [[EAFeatureItem alloc] initWithFocusRect:rect focusCornerRadius:23 focusInsets:UIEdgeInsetsZero];
    title.introduce = @"点击这里查看更多";
    //    title.actionTitle = @"我知道了";
    title.introduceFont = [UIFont systemFontOfSize:16];
    [self.navigationController.view showWithFeatureItems:@[title] saveKeyName:@"button" inVersion:nil];
}

//懒加载地图
- (MAMapView *)mapView{
    if(!_mapView) {
        self.mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0,QdxHeight - MAPVIEWHEIGHT ,QdxWidth,MAPVIEWHEIGHT)];
        self.mapView.mapType = MAMapTypeStandard;
        self.mapView.showsScale = NO;
        self.mapView.rotateCameraEnabled = NO;
        self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapClick)];
        self.doubleTap.delegate = self;
        self.doubleTap.numberOfTapsRequired = 1;
        [self.mapView addGestureRecognizer:self.doubleTap];
    }
    return _mapView;
}

//单击放大地图
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.doubleTap && [touch.view isKindOfClass:[UIControl class]])
    {
        return NO;
    }
    
    return YES;
}

-(void)setMylineInfo:(NSDictionary *) infoDict code:(int)code
{
    QDXGameModel *game = [QDXGameModel mj_objectWithKeyValues:infoDict];
    self.gameInfo = game;
    NSString *macLabel =self.gameInfo.point.label;
    NSArray *array3 = [macLabel componentsSeparatedByString:@":"];
    NSString *string3 = [array3 componentsJoinedByString:@""];
    mac_Label = [string3 componentsSeparatedByString:@","];
//    NSLog(@"%@   %@",mac_Label,self.gameInfo.point.point_name);
    sdateStr = self.gameInfo.sdate;
    [self intervalSinceNow];
    point.text = self.gameInfo.point.point_name;
    score_sum.text = [ToolView scoreTransfer:self.gameInfo.score];
    
    if (code == 1) {
        lock = NO;
        if([self.gameInfo.pointmap.pindex intValue]<999){
            [self setupCompleteView:0];
        }
    }
    
    switch ([self.gameInfo.mstatus_id intValue]) {
        case 1:
            self.navigationItem.title = @"准备活动";
            if ([self.gameInfo.isLeader intValue] == 1) {
                self.MyCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
            }
            [self.mapView removeFromSuperview];
            [self.QDXScrollView addSubview:readyView];
            [self.QDXScrollView addSubview:_webView];
            break;
            
        case 2:
            [self.navigationItem setTitle:[self.gameInfo.line.line_sub stringByAppendingString:@"-活动中"]];
            if ([self.gameInfo.isLeader intValue] == 1) {
                self.MyCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
            }
            if([self.gameInfo.line.linetype_id isEqualToString:@"3"])
            {
                currentTime.text = @"倒计时";
            }
            [readyView removeFromSuperview];
            [_webView removeFromSuperview];
            [self.QDXScrollView addSubview:self.mapView];
            [self.QDXScrollView addSubview:playView];
            [self.QDXScrollView addSubview:self.task_button];
            [self.QDXScrollView addSubview:self.history_button];
            break;
            
        case 3:
            lock = YES;
            if (![mylineid isEqualToString:self.model.myline_id]){
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                documentDir= [documentDir stringByAppendingPathComponent:@"QDXMyLine.data"];
                [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"stateRefresh" object:nil];
            }
            self.navigationItem.title = @"活动结束";
            [self.mapView removeFromSuperview];
            [readyView removeFromSuperview];
            [_webView removeFromSuperview];
            [playView removeFromSuperview];
            [self.task_button removeFromSuperview];
            [self.history_button removeFromSuperview];
            [self removeFromSuperViewController];
            [self createTableView];
            [self.QDXScrollView addSubview:certificate];
            [self refreshScrollView];
            break;
            
        case 4:
            lock = YES;
            if (![mylineid isEqualToString:self.model.myline_id]){
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                documentDir= [documentDir stringByAppendingPathComponent:@"QDXMyLine.data"];
                [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"stateRefresh" object:nil];
            }
            [self removeFromSuperViewController];
            [self.mapView removeFromSuperview];
            [readyView removeFromSuperview];
            [_webView removeFromSuperview];
            [playView removeFromSuperview];
            [self.task_button removeFromSuperview];
            [self.history_button removeFromSuperview];
            self.navigationItem.title = @"强制结束";
            [self createSadView];
            break;
            
        default:
            lock = YES;
            if (![mylineid isEqualToString:self.model.myline_id]){
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                documentDir= [documentDir stringByAppendingPathComponent:@"QDXMyLine.data"];
                [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
            }
            [self removeFromSuperViewController];
            [self.mapView removeFromSuperview];
            [readyView removeFromSuperview];
            [_webView removeFromSuperview];
            [playView removeFromSuperview];
            [self.task_button removeFromSuperview];
            [self.history_button removeFromSuperview];
            self.navigationItem.title = @"超时结束";
            [self createSadView];
            break;
    }
    
}

//请求当前线路1）准备 2）活动中 3）活动完成 4）强制结束
-(void)setupgetMylineInfo:(int) code
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"myline_id"] = oldMyLineid;
    NSString *url = [hostUrl stringByAppendingString:@"Home/Myline/getMyline"];
    
    //使用离线数据
    NSDictionary *res=[LocalDBService ReadMyline:oldMyLineid];
    if (res !=nil) {
        if ([res[@"mstatus_id"] intValue] == 2 &&  [res[@"online"] intValue]== 2 ) {
            
            [self setMylineInfo:res code:code];
            
            return ;
        }
        
    }
    
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret==1) {
            
            [self setMylineInfo:infoDict[@"Msg"] code:code];
            
            [LocalDBService LoadDb:^(NSDictionary *dict) {
                
            } FailBlock:^(NSMutableArray *array) {
                
            } andWithLine:self.gameInfo.line_id andWithMyline:oldMyLineid];
            //保存离线数据
            [LocalDBService WriteMyline:infoDict[@"Msg"]];
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

//检测 蓝牙状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
        {
//            NSLog(@"蓝牙已打开,请扫描外设");
            [self.MyCentralManager scanForPeripheralsWithServices:nil  options:nil];
        }
            break;
        case CBCentralManagerStatePoweredOff:
//            NSLog(@"蓝牙没有打开,请先打开蓝牙");
            break;
        default:
            break;
    }
}

//获得信号和mac地址
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //    int b = abs([RSSI.description intValue]);
    //    CGFloat ci = (b - abs([self.gameInfo.point.rssi intValue])) / (10 * 4.);
    //    NSLog(@"%f",pow(10, ci));
    //    if (pow(10,ci) < 0.9 )
    if (abs([RSSI.description intValue]) < abs([self.gameInfo.point.rssi intValue]))
    {
        NSMutableArray *macArr = [[NSMutableArray alloc] init];
        [macArr addObjectsFromArray:advertisementData[@"kCBAdvDataServiceUUIDs"]];
        NSString *string1 = [macArr componentsJoinedByString:@""];
        NSArray *array1 = [string1 componentsSeparatedByString:@"Unknown (<"];
        NSString *string2 = [array1 componentsJoinedByString:@""];
        NSArray *array2 = [string2 componentsSeparatedByString:@">)"];
        NSString *string3 = [array2 componentsJoinedByString:@""];
        //        NSLog(@"lock %@",lock?@"YES":@"NO");
        if (string3.length > 8) {
            if (lock == NO) {
                macStr = [string3 substringFromIndex:8];
                macStr = [macStr substringToIndex:12];
                for (NSString * str in mac_Label) {
                    if ([macStr isEqualToString:str] && ![macStr isEqualToString:rmoveMacStr])
                    {
                        lock = YES;
                        rmoveMacStr = macStr;
                        errorCount = 0;
                        if([self.gameInfo.mstatus_id intValue] == 1)
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确定开始本次活动？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                            alert.tag =2;
                            [alert show];
                        }else{
                            [self setupCheckTask];
                        }
                        
                    }
                    
                }
                
            }
        }
    }
    [self.MyCentralManager scanForPeripheralsWithServices:nil  options:nil];
}

//地图覆盖物
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAGroundOverlay class]])
    {
        MAGroundOverlayRenderer *groundOverlayRenderer = [[MAGroundOverlayRenderer alloc] initWithGroundOverlay:overlay];
        
        return groundOverlayRenderer;
    }
    return nil;
}

//状态4 的frame
- (void)createSadView
{
    UIImageView *sad = [[UIImageView alloc] init];
    CGFloat sadCenterX = QdxWidth * 0.5;
    CGFloat sadCenterY = QdxHeight * 0.22;
    sad.center = CGPointMake(sadCenterX, sadCenterY);
    sad.bounds = CGRectMake(0, 0,40,43);
    sad.image = [UIImage imageNamed:@"哭脸－遗憾"];
    [self.QDXScrollView addSubview:sad];
    
    UILabel *sadButton = [[UILabel alloc] init];
    sadButton.center = CGPointMake(sadCenterX, sadCenterY + 30 + 15);
    sadButton.bounds = CGRectMake(0, 0, 120, 100);
    if ([self.gameInfo.mstatus_id intValue] == 4) {
        sadButton.text = @"您已经强制结束比赛";
    }else{
        sadButton.text = @"您已经超时结束比赛";
    }
    sadButton.font = [UIFont systemFontOfSize:12];
    sadButton.textAlignment = NSTextAlignmentCenter;
    sadButton.textColor = QDXGray;
    [self.QDXScrollView addSubview:sadButton];
}

//状态3 的frame
-(void)createTableView
{
    certificate = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth * 1.425)];
    NSURL *certificate_url = [NSURL URLWithString:[hostUrl stringByAppendingString:self.gameInfo.point.area.map]];
    [certificate setImageWithURL:certificate_url placeholderImage:[UIImage imageNamed:@"加载中"] options:SDWebImageRefreshCached];
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,10 + QdxWidth * 1.425, QdxWidth, 73 * self.gameInfo.history.count + 40) style:UITableViewStylePlain];
    self.tableview.rowHeight = 73;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.backgroundColor = QDXBGColor;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.QDXScrollView addSubview:self.tableview];
}

//状态3 页面大小调整
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat sectionHeaderHeight = 40;
    
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        
    }
    
}

-(void)refreshScrollView
{
    CGFloat scrollViewHeight = 0.0f;
    scrollViewHeight += self.tableview.frame.size.height + certificate.frame.size.height + 64 + 50;
    [self.QDXScrollView setContentSize:(CGSizeMake(QdxWidth, scrollViewHeight))];
}

//状态3
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gameInfo.history.count;
}

//状态3
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QDXHistoryTableViewCell *cell = [QDXHistoryTableViewCell cellWithTableView:tableView];
    cell.HistoryInfo = self.gameInfo.history[self.gameInfo.history.count-1 - indexPath.row];
    return cell;
}

//状态3
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

//状态3
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 40)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, QdxWidth *  0.7 , 20)];
    header.text = @"定向足迹";
    header.textColor = QDXBlack;
    header.font = [UIFont fontWithName:@"Arial" size:15];
    [headerView addSubview:header];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40 -1, QdxWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [headerView addSubview:lineView];
    return headerView;
}

//设置状态1，2 的 Frame
-(void)setupFrame
{
    readyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, READYVIEWHEIGHT)];
    readyView.backgroundColor = [UIColor colorWithRed:1.000 green:0.965 blue:0.867 alpha:1.000];
    UILabel *readyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (READYVIEWHEIGHT * 0.5)/2, 170, READYVIEWHEIGHT * 0.5)];
    readyLabel.text = @"请到起点处准备开始";
    readyLabel.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
    readyLabel.font = [UIFont systemFontOfSize:14];
    [readyView addSubview:readyLabel];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, READYVIEWHEIGHT, QdxWidth, WEBVIEWHEIGHT)];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.qudingxiang.cn/home/myline/mylineweb/myline_id/%@/tmp/%@",oldMyLineid,save]]]];
    
    playView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, SCOREVIEWHEIGHT)];
    playView.backgroundColor = [UIColor whiteColor];
    
    useTime = [[UILabel alloc] init];
    CGFloat useTimeCenterX = QdxWidth * 0.5;
    CGFloat useTimeCenterY = (SCOREVIEWHEIGHT * 0.6) * 0.45;
    useTime.center = CGPointMake(useTimeCenterX, useTimeCenterY);
    useTime.bounds = CGRectMake(0, 0, QdxWidth, 25);
    useTime.textAlignment = NSTextAlignmentCenter;
    useTime.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
    useTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
    
    [playView addSubview:useTime];
    currentTime = [[UILabel alloc] init];
    CGFloat currentTimeCenterX = useTimeCenterX;
    CGFloat currentTimeCenterY = useTimeCenterY + 15 + 25/2 + 5;
    currentTime.center = CGPointMake(currentTimeCenterX, currentTimeCenterY);
    currentTime.bounds = CGRectMake(0, 0, QdxWidth/2, 15);
    currentTime.textAlignment = NSTextAlignmentCenter;
    currentTime.text = @"当前成绩";
    currentTime.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    currentTime.font = [UIFont systemFontOfSize:12];
    [playView addSubview:currentTime];
    
    float playline_Height = SCOREVIEWHEIGHT * 0.6;
    playLineView_One = [[UIView alloc] initWithFrame:CGRectMake(0, playline_Height, QdxWidth, 1)];
    playLineView_One.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1];
    [playView addSubview:playLineView_One];
    playLineView_Two = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth/2, playline_Height+1, 1, SCOREVIEWHEIGHT - playline_Height-1)];
    playLineView_Two.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1];
    [playView addSubview:playLineView_Two];
    
    float pointHeight = playline_Height +((SCOREVIEWHEIGHT - playline_Height) - (20 + 15 + 5))/2;
    point = [[UILabel alloc] initWithFrame:CGRectMake(0, pointHeight, QdxWidth/2, 20)];
    point.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
    point.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    point.textAlignment = NSTextAlignmentCenter;
    [playView addSubview:point];
    point_name = [[UILabel alloc] initWithFrame:CGRectMake(0, pointHeight + 20 + 5+ 5, QdxWidth/2, 15)];
    point_name.textAlignment = NSTextAlignmentCenter;
    point_name.text = @"目标点标";
    point_name.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    point_name.font = [UIFont systemFontOfSize:12];
    [playView addSubview:point_name];
    
    score_sum = [[UILabel alloc] initWithFrame:CGRectMake((QdxWidth/4)* 3 - 100/2, pointHeight, 100, 20)];
    score_sum.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
    score_sum.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    score_sum.textAlignment = NSTextAlignmentCenter;
    [playView addSubview:score_sum];
    
    score_sum_name = [[UILabel alloc] initWithFrame:CGRectMake((QdxWidth/4)* 3 - 100/2, pointHeight + 20 + 5+ 5, 100, 15)];
    score_sum_name.textAlignment = NSTextAlignmentCenter;
    score_sum_name.text = @"消耗时长";
    score_sum_name.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    score_sum_name.font = [UIFont systemFontOfSize:12];
    [playView addSubview:score_sum_name];
    buttom_line = [[UIView alloc] initWithFrame:CGRectMake(0, SCOREVIEWHEIGHT, QdxWidth, 1)];
    buttom_line.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1];
    [playView addSubview:buttom_line];
    
    if (QdxWidth >375) {
        self.task_button = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - 100 -20 , QdxHeight - 64 - 100 - 20, 100, 100)];
        [self.task_button setImage:[ToolView OriginImage:[UIImage imageNamed:@"悬浮－任务"] scaleToSize:CGSizeMake(100, 100)] forState:UIControlStateNormal];
        [self.task_button setImage:[ToolView OriginImage:[UIImage imageNamed:@"任务"] scaleToSize:CGSizeMake(100, 100)] forState:UIControlStateHighlighted];
        
        self.history_button = [[UIButton alloc] initWithFrame:CGRectMake(20 , QdxHeight - 64 - 100 - 20, 100, 100)];
        [self.history_button setImage:[ToolView OriginImage:[UIImage imageNamed:@"悬浮－足迹"] scaleToSize:CGSizeMake(100, 100)] forState:UIControlStateNormal];
        [self.history_button setImage:[ToolView OriginImage:[UIImage imageNamed:@"足迹"] scaleToSize:CGSizeMake(100, 100)] forState:UIControlStateHighlighted];
    }else{
        self.task_button = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - 80 -20 , QdxHeight - 64 - 80 - 20, 80, 80)];
        [self.task_button setImage:[UIImage imageNamed:@"悬浮－任务"] forState:UIControlStateNormal];
        [self.task_button setImage:[UIImage imageNamed:@"任务"] forState:UIControlStateHighlighted];
        
        self.history_button = [[UIButton alloc] initWithFrame:CGRectMake(20 , QdxHeight - 64 - 80 - 20, 80, 80)];
        [self.history_button setImage:[UIImage imageNamed:@"悬浮－足迹"] forState:UIControlStateNormal];
        [self.history_button setImage:[UIImage imageNamed:@"足迹"] forState:UIControlStateHighlighted];
    }
    
    [self.task_button addTarget:self action:@selector(task_buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.history_button addTarget:self action:@selector(history_buttonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 4)];
    [more addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [more setImage:[UIImage imageNamed:@"更多－下拉"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:more];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:more];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, buttonItem];
    
}

#pragma mark - 圆形push 和pop的转场动画
- (id<UIViewControllerAnimatedTransitioning>)
navigationController:(UINavigationController *)navigationController
animationControllerForOperation:(UINavigationControllerOperation)operation
fromViewController:(UIViewController *)fromVC
toViewController:(UIViewController *)toVC {
    
    QDXHistoryViewController *history = [[QDXHistoryViewController alloc] init];
    
    if([toVC isKindOfClass:[history class]]){
        if (operation == UINavigationControllerOperationPush) {
            CustomAnimateTransitionPush *animateTransitionPush =
            [CustomAnimateTransitionPush new];
            
            return animateTransitionPush;
            
        } else {
            return nil;
        }
    }
    
    return nil;
}

- (void)reloadData
{
    [self setupgetMylineInfo:0];
}

//将上级页面的mylineid传入
-(void)viewWillAppear:(BOOL)animated {
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    [countDownTimer setFireDate:[NSDate distantPast]];
    
    if (self.model.myline_id) {
        oldMyLineid = self.model.myline_id;
    }else{
        oldMyLineid = mylineid;
    }
    
    lock = NO;
    [self setupFrame];
    [self showGuideView];
    [self setupgetMylineInfo:0];
    [self updatadd];
    
    self.navigationController.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self getPointLonLat];
}

//将计时器 地图内存释放
-(void)viewWillDisappear:(BOOL)animated {
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode  = MAUserTrackingModeFollow;
    [self.mapView.layer removeAllAnimations];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapView = nil;
    [self removeFromSuperViewController];
    [readyView removeFromSuperview];
    [_webView removeFromSuperview];
    [playView removeFromSuperview];
    [self.history_button removeFromSuperview];
    [self.task_button removeFromSuperview];
    
    [countDownTimer setFireDate:[NSDate distantFuture]];
    [self updatadd];
}

//请求点标位置 地图位置
-(void)getPointLonLat
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"myline_id"] = oldMyLineid;
    params[@"TokenKey"] = save;
    NSString *url = [hostUrl stringByAppendingString:@"Home/Pointmap/getpointLonLat"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1) {
            QDXIsConnect *result = [QDXIsConnect mj_objectWithKeyValues:infoDict];
            self.resultInfo = result;
            
            if (self.resultInfo.MapPoint.line_map.length != 0) {
                MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake([self.resultInfo.MapPoint.bottom_lat floatValue], [self.resultInfo.MapPoint.bottom_lon floatValue]),CLLocationCoordinate2DMake([self.resultInfo.MapPoint.top_lat floatValue], [self.resultInfo.MapPoint.top_lon floatValue]));
                NSString *map_url = [hostUrl stringByAppendingString:result.MapPoint.line_map];
                NSURL *url = [NSURL URLWithString:map_url];
                UIImage *imagea = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
                groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[ToolView imageByApplyingAlpha:1.0 image:imagea]];
                [_mapView addOverlay:groundOverlay];
                [_mapView setVisibleMapRect:groundOverlay.boundingMapRect animated:YES];
            }else{
                float lat = ([self.resultInfo.MapPoint.top_lat floatValue] + [self.resultInfo.MapPoint.bottom_lat floatValue])/2;
                float lon = ([self.resultInfo.MapPoint.top_lon floatValue] + [self.resultInfo.MapPoint.bottom_lon floatValue])/2;
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
                //缩放比例
                MACoordinateSpan span = MACoordinateSpanMake(0.008, 0.008);
                if (lat == 0 && lon == 0) {
                    MACoordinateRegion region = MACoordinateRegionMake(self.mapView.userLocation.location.coordinate, span);
                    //设置地图的显示区域
                    [_mapView setRegion:region animated:YES];
                }else{
                    MACoordinateRegion region = MACoordinateRegionMake(coordinate, span);
                    //设置地图的显示区域
                    [_mapView setRegion:region animated:YES];
                }
                
            }
            
            CLLocationCoordinate2D coor;
            for (line_pointModel *line_point in self.resultInfo.All) {
                annotation_target = [[MAPointAnnotation alloc]init];
                coor.latitude = [line_point.point.LAT floatValue];
                coor.longitude = [line_point.point.LON floatValue];
                annotation_target.coordinate = coor;
                annotation_target.title = line_point.point.point_name;
                annotation_target.subtitle = line_point.pointmap_des;
                [self.mapView addAnnotation:annotation_target];
            }
            //            for (line_pointModel *line_point in self.resultInfo.History) {
            //                annotation_history = [[MAPointAnnotation alloc]init];
            //                coor.latitude = [line_point.point.LAT floatValue];
            //                coor.longitude = [line_point.point.LON floatValue];
            //                annotation_history.coordinate = coor;
            //                annotation_history.title = line_point.point.point_name;
            //                annotation_history.subtitle = line_point.pointmap_des;
            //                [self.mapView addAnnotation:annotation_history];
            //            }
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

// Override
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        PointAnnotationView *annotationView = (PointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[PointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        
        annotationView.image = [UIImage imageNamed:@"targetPoint"];
        
        NSString * result = [[annotation title] stringByReplacingOccurrencesOfString:@"点标" withString:@""]; //截取字符串
        result = [result stringByReplacingOccurrencesOfString:@"点" withString:@""];
        annotationView.point_ID.text = [result stringByReplacingOccurrencesOfString:@"号" withString:@""];
        //        annotationView.point_url = self.gameInfo.img_url;
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        annotationView.canShowCallout = NO;
        return annotationView;
    }
    
    return nil;
}

- (void)dealloc {
    if (self.mapView) {
        self.mapView.delegate = nil;
        self.mapView = nil;
    }
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)moreClick:(UIButton *)btn
{
    if ([self.gameInfo.mstatus_id intValue] == 1||[self.gameInfo.mstatus_id intValue] == 2){
        LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"扫一扫" imageName:@"下拉－扫一扫"];
        LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"帮助" imageName:@"下拉－帮助"];
        LrdCellModel *three = [[LrdCellModel alloc] initWithTitle:@"组队" imageName:@"下拉－组队"];
        LrdCellModel *four = [[LrdCellModel alloc] initWithTitle:@"退赛" imageName:@"下拉－退赛"];
        //        LrdCellModel *five = [[LrdCellModel alloc] initWithTitle:@"离线下载" imageName:@"下拉－离线"];
        self.dataArr = @[one, two, three, four];
    }else{
        LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"分享" imageName:@"下拉－分享"];
        LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"帮助" imageName:@"下拉－帮助"];
        LrdCellModel *three = [[LrdCellModel alloc] initWithTitle:@"打印成绩" imageName:@"下拉－打印"];
        self.dataArr = @[one, two, three];
    }
    
    CGFloat x = btn.center.x + 10;
    CGFloat y = btn.frame.origin.y + btn.bounds.size.height + 50;
    _outputView = [[LrdOutputView alloc] initWithDataArray:self.dataArr origin:CGPointMake(x, y) width:130 height:44 direction:kLrdOutputViewDirectionRight];
    
    _outputView.delegate = self;
    _outputView.dismissOperation = ^(){
        //设置成nil，以防内存泄露
        _outputView = nil;
    };
    [_outputView pop];
}

- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.gameInfo.mstatus_id intValue] == 1||[self.gameInfo.mstatus_id intValue] == 2){
        if (indexPath.row == 0) {
            if ([self.gameInfo.isLeader intValue] == 1) {
                [self codeClick];
            }else{
                UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"您不是队长!"preferredStyle:UIAlertControllerStyleAlert];
                //创建一个action
                UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }else if (indexPath.row == 1){
            HelpViewController *helpVC = [[HelpViewController alloc] init];
            [self.navigationController pushViewController:helpVC animated:YES];
        }else if (indexPath.row == 2){
            if ([self.gameInfo.mstatus_id intValue] == 2) {
                [MBProgressHUD showError:@"游戏中不能组队"];
            }else{
                [self ready];
            }
        }else if (indexPath.row == 3){
            [self giveUp];
        }else{
            //            QDXOffLineController *offline = [[QDXOffLineController alloc] init];
            //            [self.navigationController pushViewController:offline animated:YES];
        }
    }else{
        if (indexPath.row == 0) {
            [self shareClick];
        }else if (indexPath.row == 1){
            HelpViewController *helpVC = [[HelpViewController alloc] init];
            [self.navigationController pushViewController:helpVC animated:YES];
        }else{
            if ([self.gameInfo.mstatus_id intValue] == 3){
                [self setupCreateView];
            }else{
                [MBProgressHUD showError:@"您未完成活动"];
            }
        }
    }
}

-(void)history_buttonClick
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    QDXHistoryViewController *viewController = [[QDXHistoryViewController alloc] init];
    viewController.Game = self.gameInfo;
    //    NSLog(@"count  %ld",(long)self.gameInfo.history.count);
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)task_buttonClick
{
    [self setupCompleteView:1];
    //    [self setupCheckTask];
}

-(void)mapClick
{
    mapClick = !mapClick;
    if (!mapClick) {
        [playView addGestureRecognizer:self.doubleTap];
        [playLineView_One removeFromSuperview];
        [score_sum removeFromSuperview];
        [score_sum_name removeFromSuperview];
        //        [self.mapView removeAnnotations:self.mapView.annotations];
        self.mapView.showsCompass =NO;
        [UIView animateWithDuration:1 animations:^{
            playView.frame = CGRectMake(0, 0, QdxWidth, QdxHeight * 0.1);
            self.mapView.frame = CGRectMake(0,QdxHeight * 0.1,QdxWidth,QdxHeight * 0.9);
            float pointHeight = (QdxHeight * 0.1 - (20 + 15 + 5))/2;
            playLineView_Two.frame = CGRectMake(QdxWidth/2, 0, 1, QdxHeight * 0.1);
            buttom_line.frame = CGRectMake(0, QdxHeight * 0.1, QdxWidth, 1);
            point.frame = CGRectMake(0, pointHeight, QdxWidth/2, 20);
            point_name.frame = CGRectMake(0,pointHeight + 20 + 5+ 5, QdxWidth/2, 15);
            useTime.frame = CGRectMake((QdxWidth/4)* 3 - QdxWidth/2/2,pointHeight, QdxWidth/2, 20);
            useTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
            currentTime.frame = CGRectMake((QdxWidth/4)* 3 - 100/2,pointHeight + 20 + 5+ 5, 100, 15);
            
            if (QdxWidth >375){
                self.task_button.frame = CGRectMake(QdxWidth - 80 -20 , QdxHeight - 64 - 80 - 20, 80, 80);
                self.history_button.frame = CGRectMake(20 , QdxHeight - 64 - 80 - 20, 80, 80);
            }else{
                self.task_button.frame = CGRectMake(QdxWidth - 60 -20 , QdxHeight - 64 - 60 - 20, 60, 60);
                self.history_button.frame = CGRectMake(20 , QdxHeight - 64 - 60 - 20, 60, 60);
            }
            
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [self.mapView addGestureRecognizer:self.doubleTap];
        
        [UIView animateWithDuration:1 animations:^{
            self.mapView.frame = CGRectMake(0,QdxHeight - MAPVIEWHEIGHT ,QdxWidth,MAPVIEWHEIGHT);
            playView.frame = CGRectMake(0, 0, QdxWidth, SCOREVIEWHEIGHT);
            CGFloat useTimeCenterX = QdxWidth * 0.5;
            CGFloat useTimeCenterY = (SCOREVIEWHEIGHT * 0.6) * 0.45;
            useTime.center = CGPointMake(useTimeCenterX, useTimeCenterY);
            useTime.bounds = CGRectMake(0, 0, QdxWidth, 25);
            useTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
            CGFloat currentTimeCenterX = useTimeCenterX;
            CGFloat currentTimeCenterY = useTimeCenterY + 15 + 25/2+ 5;
            currentTime.center = CGPointMake(currentTimeCenterX, currentTimeCenterY);
            currentTime.bounds = CGRectMake(0, 0, QdxWidth/2, 15);
            float playline_Height = SCOREVIEWHEIGHT * 0.6;
            float pointHeight = playline_Height +((SCOREVIEWHEIGHT - playline_Height) - (20 + 15 + 5))/2;
            buttom_line.frame = CGRectMake(0, SCOREVIEWHEIGHT, QdxWidth, 1);
            playLineView_Two.frame = CGRectMake(QdxWidth/2, playline_Height+1, 1, SCOREVIEWHEIGHT - playline_Height-1);
            point.frame = CGRectMake(0, pointHeight, QdxWidth/2, 20);
            point_name.frame = CGRectMake(0,pointHeight + 20 + 5+ 5, QdxWidth/2, 15);
            score_sum.frame = CGRectMake((QdxWidth/4)* 3 - 100/2, pointHeight, 100, 20);
            score_sum_name.frame = CGRectMake((QdxWidth/4)* 3 - 100/2,pointHeight + 20 + 5+ 5, 100, 15);
            
            if (QdxWidth >375){
                self.task_button.frame = CGRectMake(QdxWidth - 100 -20 , QdxHeight - 64 - 100 - 20, 100, 100);
                self.history_button.frame = CGRectMake(20 , QdxHeight - 64 - 100 - 20, 100, 100);
            }else{
                self.task_button.frame = CGRectMake(QdxWidth - 80 -20 , QdxHeight - 64 - 80 - 20, 80, 80);
                self.history_button.frame = CGRectMake(20 , QdxHeight - 64 - 80 - 20, 80, 80);
            }
            
            
        } completion:^(BOOL finished) {
            [playView addSubview:playLineView_One];
            [playView addSubview:score_sum_name];
            [playView addSubview:score_sum];
            self.mapView.showsCompass =YES;
        }];
    }
}

//设置任务
-(void)setupCheckTask
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"myline_id"] = oldMyLineid;
    
    if(![answer isEqualToString:@""] && answer != nil){
        params[@"answer"] = answer;
    }
    if(![macStr isEqualToString:@""] && macStr != nil){
        params[@"mac"] = macStr;
    }
    
    //离线验证
    if ([self.gameInfo.mstatus_id intValue] == 2 && [self.gameInfo.online intValue] == 2 ) {
        NSDictionary *dic = [LocalDBService CheckTask:params];
        int ret = [dic[@"Code"] intValue];
        if (ret==1) {
            if (errorCount != 0) {
                [MBProgressHUD showMessage:@"回答错误!"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 3.0s后执行block里面的代码
                    [MBProgressHUD hideHUD];
                });
            }
            point_questionModel *p_questionModel = [point_questionModel mj_objectWithKeyValues:dic[@"Msg"]];
            self.questionInfo = p_questionModel;
//            NSLog(@"%@    ",self.questionInfo.question.qkey);
            [self  setupTaskView];
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            errorCount++;
        }else if (ret == 2){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [self setupgetMylineInfo:1];
            [self updatadd];
        }
        return ;
    }
    
    
    NSString *url = [hostUrl stringByAppendingString:@"Home/Myline/checkTaskv2"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret==1) {
            if (errorCount != 0) {
                [MBProgressHUD showMessage:@"回答错误!"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 3.0s后执行block里面的代码
                    [MBProgressHUD hideHUD];
                });
            }
            point_questionModel *p_questionModel = [point_questionModel mj_objectWithKeyValues:infoDict[@"Msg"]];
            self.questionInfo = p_questionModel;
//            NSLog(@"%@    %@",self.questionInfo.question.question_name,self.questionInfo.question.qkey);
            
            [self setupTaskView];
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            errorCount++;
        }else if (ret == 2){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [self setupgetMylineInfo:1];
//            answer = @"";
//            macStr = @"";
        }else{
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请稍候再试" preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
                lock = NO;
                rmoveMacStr = @"";
//            }];
//            [alertController addAction:okAction];
//            [self presentViewController:alertController animated:YES completion:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        lock = NO;
        rmoveMacStr = @"";
    }];
}

-(void)updatadd
{
    [LocalDBService UploadHistory:oldMyLineid];
}

//任务的frame
-(void)setupTaskView
{
    [self removeFromSuperViewController];
    lock = YES;
    
    NSString *stringurl = [NSString stringWithFormat:@"http://www.qudingxiang.cn/home/Myline/getQuestionWeb/myline_id/%@/tmp/%@",oldMyLineid,save]; //默认是在线
    if ([self.gameInfo.online intValue] ==2) { //离线题
        stringurl = [accountFile stringByAppendingString:@"/question.html"];
    }
    
    if ([self.questionInfo.question.ischoice intValue] == 2) {
        YLPopViewController *popView = [[YLPopViewController alloc] init];
        popView.webStr = stringurl;
        popView.contentViewSize = CGSizeMake(TASKWEIGHT, TASKHEIGHT);
        popView.Title = self.gameInfo.line.line_sub;
        popView.placeHolder = @"请输入答案";
//        popView.wordCount = 6 + self.questionInfo.question.qkey.length;//不设置则没有
        [popView addContentView];//最后调用
        __typeof(popView)weakPopView = popView;
        popView.confirmBlock = ^(NSString *text) {
            answer = text;
            [self setupCheckTask];
            [weakPopView hidden];
        };
        popView.cancelBlock = ^(){
            lock = NO;
            rmoveMacStr = @"0";
        };
    }else if ([self.questionInfo.question.ischoice intValue] == 1){
        
        CYAlertController *alert = [CYAlertController alertWithTitle:self.gameInfo.line.line_sub message:stringurl];
        
        alert.alertViewCornerRadius = 10;
        
        CYAlertAction *cancelAction_A = [CYAlertAction actionWithTitle:[@"A. " stringByAppendingString:self.questionInfo.question.qa] style:CYAlertActionStyleCancel handler:^{
            answer = @"A";
            [self setupCheckTask];
        }];
        CYAlertAction *cancelAction_B = [CYAlertAction actionWithTitle:[@"B. " stringByAppendingString:self.questionInfo.question.qb] style:CYAlertActionStyleCancel handler:^{
            answer = @"B";
            [self setupCheckTask];
        }];
        CYAlertAction *cancelAction_C = [CYAlertAction actionWithTitle:[@"C. " stringByAppendingString:self.questionInfo.question.qc] style:CYAlertActionStyleCancel handler:^{
            answer = @"C";
            [self setupCheckTask];
        }];
        CYAlertAction *cancelAction_D = [CYAlertAction actionWithTitle:[@"D. " stringByAppendingString:self.questionInfo.question.qd] style:CYAlertActionStyleCancel handler:^{
            answer = @"D";
            [self setupCheckTask];
        }];
        [alert addActions:@[cancelAction_A, cancelAction_B, cancelAction_C ,cancelAction_D]];
        
        alert.presentStyle = CYAlertPresentStyleBounce;
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//完成动画的frame
-(void)setupCompleteView:(int )code
{
    [self removeFromSuperViewController];
    
    self.BGView = [[UIView alloc] init];
    self.BGView.frame = [[UIScreen mainScreen] bounds];
    [self.view addSubview:self.BGView];
    
    self.deliverView = [[UIView alloc] init];
    self.deliverView.frame = CGRectMake(QdxWidth* 0.08,0,TASKWEIGHT/2,TASKHEIGHT/2);
    [self.view addSubview:self.deliverView];
    
    if (code == 0) {
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.3
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.BGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
                             self.deliverView.frame = CGRectMake(QdxWidth/2 - TASKWEIGHT/2,(QdxHeight-64 - TASKHEIGHT)/2,TASKWEIGHT,TASKHEIGHT);
                             self.deliverView.backgroundColor = [UIColor clearColor];
                             self.deliverView.layer.borderWidth = 1;
                             self.deliverView.layer.cornerRadius = 12;
                             self.deliverView.layer.borderColor = [[UIColor clearColor]CGColor];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        
        successView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TASKWEIGHT, TASKHEIGHT)];
        
        [successView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,self.gameInfo.img_url]] placeholderImage:[UIImage imageNamed:@"加载中"] options:SDWebImageRefreshCached];
        
        //        [successView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,self.gameInfo.img_url]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
        [self.deliverView addSubview:successView];
        
        showMsg_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,TASKWEIGHT, TASKHEIGHT)];
        [showMsg_button addTarget:self action:@selector(showMsg_buttonClick) forControlEvents:UIControlEventTouchUpInside];
        showMsg_button.backgroundColor = [UIColor clearColor];
        [self.deliverView addSubview:showMsg_button];
    }else{
        self.BGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        self.deliverView.frame = CGRectMake(QdxWidth/2 - TASKWEIGHT/2,(QdxHeight-64 - TASKHEIGHT)/2,TASKWEIGHT,TASKHEIGHT);
        self.deliverView.backgroundColor = [UIColor whiteColor];
        self.deliverView.layer.borderWidth = 1;
        self.deliverView.layer.cornerRadius = 12;
        self.deliverView.layer.borderColor = [[UIColor clearColor]CGColor];
        
        
        CGPoint finalPoint;
        
        finalPoint = CGPointMake(TASKWEIGHT, TASKHEIGHT);
        
        CGFloat radius = sqrt((finalPoint.x * finalPoint.x) + (finalPoint.y * finalPoint.y));
        UIBezierPath *maskFinalBP = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.deliverView.frame, -radius, -radius)];
        UIBezierPath *maskStartBP =  [UIBezierPath bezierPathWithOvalInRect:self.task_button.frame];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = maskFinalBP.CGPath;
        self.deliverView.layer.mask = maskLayer;
        
        CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskLayerAnimation.fromValue = (__bridge id)(maskStartBP.CGPath);
        maskLayerAnimation.toValue = (__bridge id)((maskFinalBP.CGPath));
        maskLayerAnimation.duration = 0.7;
        maskLayerAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        maskLayerAnimation.delegate = self;
        
        [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
        
        [self showMsg_buttonClick];
    }
}

-(void)showMsg_buttonClick
{
    [showMsg_button removeFromSuperview];
    [successView removeFromSuperview];
    lock = NO;
    
    showOK_button = [[UIButton alloc] initWithFrame:CGRectMake(0, TASKHEIGHT - SHOWTASKHEIGHT,TASKWEIGHT, SHOWTASKHEIGHT)];
    [showOK_button addTarget:self action:@selector(showOK_buttonClick) forControlEvents:UIControlEventTouchUpInside];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    [showOK_button setBackgroundImage:[[UIImage imageNamed:@"任务卡－按钮"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [showOK_button setTitle:@"好的" forState:UIControlStateNormal];
    [showOK_button setTitleColor:[UIColor colorWithRed:0.000 green:0.600 blue:0.992 alpha:1.000] forState:UIControlStateNormal];
    [self.deliverView addSubview:showOK_button];
    
    showTitle_button = [[UIButton alloc] initWithFrame:CGRectMake(0,0,TASKWEIGHT, SHOWTASKHEIGHT)];
    showTitle_button.userInteractionEnabled = NO;
    [showTitle_button setBackgroundImage:[[UIImage imageNamed:@"任务卡－按钮上面"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [showTitle_button setTitle:self.gameInfo.line.line_sub forState:UIControlStateNormal];
    [showTitle_button setTitleColor:[UIColor colorWithWhite:0.067 alpha:1.000] forState:UIControlStateNormal];
    showTitle_button.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.deliverView addSubview:showTitle_button];
    
    //    cancel_button = [[UIButton alloc] initWithFrame:CGRectMake(TASKWEIGHT - 30, 15,15, 15)];
    //    [cancel_button addTarget:self action:@selector(cancel_buttonClick) forControlEvents:UIControlEventTouchUpInside];
    //    [cancel_button setBackgroundImage:[UIImage imageNamed:@"任务卡－取消"]  forState:UIControlStateNormal];
    //    [self.deliverView addSubview:cancel_button];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,SHOWTASKHEIGHT, TASKWEIGHT, TASKHEIGHT - 2 * SHOWTASKHEIGHT)];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.qudingxiang.cn/home/Myline/getTaskWeb/myline_id/%@/tmp/%@",oldMyLineid,save]]]];
    [self.deliverView addSubview:self.webView];
}

-(void)showOK_buttonClick
{
    UIBezierPath *finalPath = [UIBezierPath bezierPathWithOvalInRect:self.task_button.frame];
    
    CGPoint finalPoint;
    
    finalPoint = CGPointMake(self.task_button.center.x - 0, self.task_button.center.y - 0);
    
    CGFloat radius = sqrt(finalPoint.x * finalPoint.x + finalPoint.y * finalPoint.y);
    UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.task_button.frame, -radius, -radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = finalPath.CGPath;
    self.deliverView.layer.mask = maskLayer;
    
    CABasicAnimation *pingAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pingAnimation.fromValue = (__bridge id)(startPath.CGPath);
    pingAnimation.toValue   = (__bridge id)(finalPath.CGPath);
    pingAnimation.duration = 0.7;
    pingAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    pingAnimation.delegate = self;
    
    [maskLayer addAnimation:pingAnimation forKey:@"pingInvert"];
    
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.7 *NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self removeFromSuperViewController];
    });
}

//-(void)cancel_buttonClick
//{
//    [self removeFromSuperViewController];
//}

-(void)removeFromSuperViewController
{
    lock = NO;
    [self.BGView removeFromSuperview];
    [self.deliverView removeFromSuperview];
}

//二维码的frame
- (void)setupCreateView
{
    self.BGView                 = [[UIView alloc] init];
    self.BGView.frame           = [[UIScreen mainScreen] bounds];
    self.BGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:self.BGView];
    float codeHeight = TASKHEIGHT;
    if (QdxWidth > 320) {
        codeHeight  = TASKHEIGHT * 0.75;
    }
    self.deliverView                 = [[UIView alloc] init];
    self.deliverView.frame           = CGRectMake(QdxWidth/2 - TASKWEIGHT/2,(QdxHeight-64 - codeHeight)/2,TASKWEIGHT,codeHeight);
    self.deliverView.backgroundColor = [UIColor whiteColor];
    self.deliverView.layer.borderWidth = 1;
    self.deliverView.layer.cornerRadius = 8;
    self.deliverView.layer.borderColor = [[UIColor clearColor]CGColor];
    [self.view addSubview:self.deliverView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,15, TASKWEIGHT, 20)];
    title.text = @"请扫描二维码";
    title.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
    title.font = [UIFont systemFontOfSize:16];
    title.textAlignment = NSTextAlignmentCenter;
    [self.deliverView addSubview:title];
    UILabel *printTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 15 + 20 + 15, TASKWEIGHT, 15)];
    printTitle.text = @"请到自助终端打印成绩单: ";
    printTitle.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    printTitle.font = [UIFont systemFontOfSize:14];
    printTitle.textAlignment = NSTextAlignmentCenter;
    [self.deliverView addSubview:printTitle];
    UILabel *printCode = [[UILabel alloc] initWithFrame:CGRectMake(0, 15 + 20 + 15 + 15 + 10, TASKWEIGHT, 15)];
    printCode.text = self.gameInfo.printcode;
    printCode.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    printCode.font = [UIFont systemFontOfSize:14];
    printCode.textAlignment = NSTextAlignmentCenter;
    [self.deliverView addSubview:printCode];
    UIView *printLine = [[UIView alloc] initWithFrame:CGRectMake(0, 15 + 20 + 15 + 15 + 10 + 15 + 15, TASKWEIGHT, 1)];
    printLine.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [self.deliverView addSubview:printLine];
    UIImageView * createCode = [[UIImageView alloc] initWithFrame:CGRectMake(TASKWEIGHT/2 - (300)/2, 15 + 20 + 15 + 15 + 10 + 15 + 15 + 1 , 300, 300)];
    if (QdxWidth < 640) {
        createCode.frame = CGRectMake(TASKWEIGHT/2 - (200)/2, 15 + 20 + 15 + 15 + 10 + 15 + 15 + 1 , 200, 200);
    }
    createCode.image = [QRCodeGenerator qrImageForString:self.gameInfo.printcode imageSize:createCode.bounds.size.width];
    [self.deliverView addSubview:createCode];
    
    UIButton *cancelbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, codeHeight - SHOWTASKHEIGHT,TASKWEIGHT, SHOWTASKHEIGHT)];
    [cancelbutton addTarget:self action:@selector(cancelbuttonClick) forControlEvents:UIControlEventTouchUpInside];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    [cancelbutton setBackgroundImage:[[UIImage imageNamed:@"任务卡－按钮"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelbutton setTitleColor:[UIColor colorWithRed:0.000 green:0.600 blue:0.992 alpha:1.000] forState:UIControlStateNormal];
    [self.deliverView addSubview:cancelbutton];
}

-(void)cancelbuttonClick
{
    [self removeFromSuperViewController];
}

//放弃比赛
-(void)giveUp
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"真的要结束活动吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 1;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1 && alertView.tag == 1) {
        
        AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
        mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"TokenKey"] = save;
        params[@"myline_id"] = oldMyLineid;
        NSString *url = [hostUrl stringByAppendingString:@"Home/Myline/gameover"];
        [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
            int ret = [infoDict[@"Code"] intValue];
            if (ret==1) {
                NSDictionary *res=[LocalDBService ReadMyline:oldMyLineid];
                [res setValue:@"4" forKey:@"mstatus_id"];
                [LocalDBService WriteMyline:res];
                [self setupgetMylineInfo:0];
                lock = YES;
            }else{
                
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }else if (buttonIndex ==1 && alertView.tag == 2){
        //        TTSExample * example = [[TTSExample alloc] init];
        //        [example read:@" 活动开始!"];
        [self setupCheckTask];
    }else if (buttonIndex ==1 && alertView.tag == 3){
        
    }else if (buttonIndex ==0 && alertView.tag == 1) {
        
    }else if (buttonIndex ==0 && alertView.tag == 2){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 1.0s后执行block里面的代码
            lock = NO;
            rmoveMacStr = @"0";
        });
    }else if (buttonIndex ==0 && alertView.tag == 3){
        
    }
}

//组队按钮
-(void)ready
{
    QDXTeamsViewController *viewController = [[QDXTeamsViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

//计时
- (void)intervalSinceNow
{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    int mNow = [[locationString substringWithRange:NSMakeRange(5,2)] intValue];
    int mOld = [[sdateStr substringWithRange:NSMakeRange(5,2)] intValue];
    
    int dNow = [[locationString substringWithRange:NSMakeRange(8,2)] intValue];
    int dOld = [[sdateStr substringWithRange:NSMakeRange(8,2)] intValue];
    
    int HNow = [[locationString substringWithRange:NSMakeRange(11,2)] intValue];
    int HOld = [[sdateStr substringWithRange:NSMakeRange(11,2)] intValue];
    
    int MNow = [[locationString substringWithRange:NSMakeRange(14,2)] intValue];
    int MOld = [[sdateStr substringWithRange:NSMakeRange(14,2)] intValue];
    
    int sNow = [[locationString substringWithRange:NSMakeRange(17,2)] intValue];
    int sOld = [[sdateStr substringWithRange:NSMakeRange(17,2)] intValue];
    
    //    int SNow = [[locationString substringWithRange:NSMakeRange(20,2)] intValue];
    //    int SOld = [[sdateStr substringWithRange:NSMakeRange(20,2)] intValue];
    
    if((mNow - mOld) == 0 ){
        int a = sNow + MNow * 60 + HNow * 60 * 60 + dNow * 24 * 60 * 60;
        int b = sOld + MOld * 60 + HOld * 60 * 60 + dOld * 24 * 60 * 60;
        secondsCountDown = a - b;}
    else{
        int a = sNow + MNow * 60 + HNow * 60 * 60;
        int b = sOld + MOld * 60 + HOld * 60 * 60;
        secondsCountDown = a - b + 86400 * dNow;
    }
}

-(void)timeFireMethod
{
    secondsCountDown++;
    if ([self.gameInfo.line.linetype_id isEqualToString:@"3"]) {
        useTime.text =[NSString stringWithFormat:@"%@",[ToolView scoreTransfer:[NSString stringWithFormat:@"%d",[self.gameInfo.line.countdown intValue] -secondsCountDown]] ];
        if([self.gameInfo.line.countdown intValue] -secondsCountDown <= 900){
            useTime.textColor = [UIColor redColor];
            if ([self.gameInfo.line.countdown intValue] -secondsCountDown <= 0) {
                lock = YES;
                [countDownTimer setFireDate:[NSDate distantFuture]];
                NSDictionary *res=[LocalDBService ReadMyline:oldMyLineid];
                [res setValue:@"4" forKey:@"mstatus_id"];
                [LocalDBService WriteMyline:res];
                [self setupgetMylineInfo:0];
            }
        }
    }else{
        useTime.text =[NSString stringWithFormat:@"%@",[ToolView scoreTransfer:[NSString stringWithFormat:@"%d",secondsCountDown]] ];
    }
}

-(void)finish_print
{
    [self setupCreateView];
}

-(void)shareClick
{
    NSArray *shareButtonTitleArray = [[NSArray alloc] init];
    NSArray *shareButtonImageNameArray = [[NSArray alloc] init];
    shareButtonTitleArray = @[@"QQ好友",@"QQ空间",@"微信好友",@"朋友圈"];
    shareButtonImageNameArray = @[@"qq好友",@"qq空间",@"微信好友",@"朋友圈"];
    LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消分享" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
    
    UIWindow *appWindow = [[UIApplication sharedApplication] keyWindow];
    [appWindow addSubview:lxActivity];
}

#pragma mark - LXActivityDelegate

- (void)didClickOnImageIndex:(NSInteger *)imageIndex
{
    NSString *shareUrl = [[NSString alloc] init];
    shareUrl = [NSString stringWithFormat:@"http://www.qudingxiang.cn/home/myline/mylineweb/myline_id/%@/tmp/%@",oldMyLineid,save];
    if (imageIndex == 0) {
        TencentOAuth *auth = [[TencentOAuth alloc] initWithAppId:@"1104830915"andDelegate:self];
        NSURL *imgurl = [NSURL URLWithString:shareUrl];
        NSString *title = @"趣定向";
        NSString *description = @"我的成绩";
        NSString *imgPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icon-76@2x.png"];
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:imgurl title:title description:description previewImageData:imgData];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    } else if (imageIndex == 1){
        TencentOAuth *auth = [[TencentOAuth alloc] initWithAppId:@"1104830915"andDelegate:self];
        NSURL *imgurl = [NSURL URLWithString:shareUrl];
        NSString *utf8String =[imgurl absoluteString];
        NSString *title = @"趣定向";
        NSString *description = @"我的成绩";
        NSString *imgPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icon-76@2x.png"];
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:[NSURL URLWithString:utf8String] title:title description:description previewImageData:imgData];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    }else if (imageIndex == 2){
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = @"趣定向";
        message.description = @"我的成绩";
        [message setThumbImage:[UIImage imageNamed:@"Icon-76@2x.png"]];
        WXWebpageObject *webpageObject = [WXWebpageObject object];
        webpageObject.webpageUrl = shareUrl;
        message.mediaObject = webpageObject;
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneSession;
        [WXApi sendReq:req];
    }else if (imageIndex == 3){
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = @"趣定向";
        message.description = @"我的成绩";
        [message setThumbImage:[UIImage imageNamed:@"Icon-76@2x.png"]];
        WXWebpageObject *webpageObject = [WXWebpageObject object];
        webpageObject.webpageUrl = shareUrl;
        message.mediaObject = webpageObject;
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneTimeline;
        [WXApi sendReq:req];
        
    }
}

- (void)didClickOnCancelButton
{
//    NSLog(@"didClickOnCancelButton");
}

-(void)codeClick
{
    ImagePickerController *gameVC = [[ImagePickerController alloc] initWithBlock:^(NSString *result, BOOL flag,NSString *from) {
        gameVC.from = from;
        macStr = result;
        if (lock == NO) {
            
            for (NSString * str in mac_Label) {
                if ([macStr isEqualToString:str] && ![macStr isEqualToString:rmoveMacStr])
                {
                    lock = YES;
                    rmoveMacStr = macStr;
                    errorCount = 0;
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 3.0s后执行block里面的代码
                        if([self.gameInfo.mstatus_id intValue] == 1)
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确定开始本次活动？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                            alert.tag =2;
                            [alert show];
                        }else{
                            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                            dispatch_sync(queue, ^{
                                [self setupCheckTask];
                            });
                        }
                    });
                }
            }
        }
        
    }];
    gameVC.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:gameVC animated:YES];
}

// 返回按钮
- (void)creatButtonBack
{
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonBack.frame = CGRectMake(0, 0, 20, 18);
    [buttonBack addTarget:self action:@selector(buttonBackSetting) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setTitle:nil forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"sign_return"] forState:UIControlStateNormal];
    buttonBack.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

- (void)buttonBackSetting
{
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti3" object:nil];
    [self dismissViewControllerAnimated:YES completion:^{}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
