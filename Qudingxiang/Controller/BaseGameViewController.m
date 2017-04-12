//
//  BaseGameViewController.m
//  趣定向
//
//  Created by Air on 2017/3/23.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "BaseGameViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ImagePickerController.h"
#import "QDXTeamsViewController.h"
#import "QDXHistoryViewController.h"
#import "QDXHistoryTableViewCell.h"
#import "HelpViewController.h"
#import "LrdOutputView.h"
#import <WebKit/WebKit.h>
#import "TaskRefreshModel.h"
#import "MapViewController.h"

#import "HistoryList.h"
#import "HistoryModel.h"

#import "QDXHistoryViewController.h"
#import "CustomAnimateTransitionPush.h"
#import "gameToMapPush.h"

#import "QDXProtocolViewController.h"
#import "QDXNavigationController.h"
#import "QDXPopView.h"

@interface BaseGameViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource,LrdOutputViewDelegate,WKScriptMessageHandler,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView* tableview;

@property (nonatomic, strong) UIScrollView* QDXScrollView;

@property (nonatomic, strong) CBCentralManager* MyCentralManager;

@property (nonatomic, strong) UITapGestureRecognizer* doubleTap;

@property (nonatomic, strong) NSArray* dataArr;

@property (nonatomic, strong) LrdOutputView* outputView;

@property (nonatomic, retain) WKWebView* webView;

@property (nonatomic, strong) TaskRefreshModel* taskRefresh;

@property (nonatomic, strong) NSTimer *countDownTimer;

@property (nonatomic, strong) UILabel *timeScoreLabel;

@property (nonatomic, assign) int secondsCountDown;

@property (nonatomic, strong) UILabel *pointLabel;

@property (nonatomic, strong) UIView* topView;

@property (nonatomic, strong) UIView* bottomView;

@property (nonatomic, strong) UIImageView *certificate;

@property (nonatomic, strong) NSMutableArray *historyArr;

@property (nonatomic, strong) NSString *macStr;

@property (nonatomic, strong) NSString *rmoveMacStr;

@property (nonatomic, strong) QDXPopView *popView;

@end

@implementation BaseGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.QDXScrollView =[[UIScrollView alloc] initWithFrame:self.view.frame];
    self.QDXScrollView.showsVerticalScrollIndicator = FALSE;
    self.QDXScrollView.backgroundColor = QDXBGColor;
    [self.view addSubview:self.QDXScrollView];
    
    if (_myline_id.length == 0) {

        QDXProtocolViewController *protocolVC = [[QDXProtocolViewController alloc] init];
        QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:protocolVC];
        protocolVC.declineBlock = ^(){
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        };
        [self.navigationController presentViewController:nav animated:YES completion:^{
            
        }];
    }
    
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    
    UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 4)];
    [more addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [more setImage:[UIImage imageNamed:@"更多－下拉"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:more];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:more];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, buttonItem];

    [self getTaskRefresh];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 必须在viewDidAppear或者viewWillAppear中写，因为每次都需要将delegate设为当前界面
    self.navigationController.delegate=self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.MyCentralManager stopScan];
}

-(void)getTaskRefresh{
    NSString *url = [newHostUrl stringByAppendingString:taskRefreshUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"myline_id"] = _myline_id;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        
        TaskRefreshModel *taskRefreshModel = [[TaskRefreshModel alloc] initWithDic:responseObject];
        _taskRefresh = taskRefreshModel;
        
        switch ([_taskRefresh.mylinest_id intValue]) {
            case 1:
                [self startUI];
                break;
                
            case 2:
                [self playUI];
                break;
            
            case 3:
                [self finishUI];
                break;
                
            case 4:
                [self failedUI];
                break;
                
            default:
                break;
        }

    } failure:^(NSError *error) {
        
    }];
}

-(void)startUI{
    
    self.MyCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,0, QdxWidth, QdxHeight)];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[newHostUrl stringByAppendingString:[taskIndexUrl stringByAppendingString:[NSString stringWithFormat:@"/myline_id/%@",_myline_id]]]]]];
    [self.QDXScrollView addSubview:self.webView];
}

-(void)playUI{
    [self showOK_buttonClick];
    [_webView removeFromSuperview];
    
    self.MyCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight)];
    _topView.backgroundColor = QDXBlue;
    [self.QDXScrollView addSubview:_topView];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,QdxHeight - 300, QdxWidth, 300)];
    [self.QDXScrollView addSubview:_bottomView];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = QDXLightBlue.CGColor;
    [_bottomView.layer addSublayer:shapeLayer];
    
    UIBezierPath *tPath = [UIBezierPath bezierPath];
    
    [tPath moveToPoint:CGPointMake(0, 0)];
    [tPath addQuadCurveToPoint:CGPointMake(QdxWidth, 0)
                  controlPoint:CGPointMake(QdxWidth/2.0, 130)];
    [tPath addLineToPoint:CGPointMake(QdxWidth, QdxHeight - 300)];
    [tPath addLineToPoint:CGPointMake(0, QdxHeight - 300)];
    
    [tPath closePath];
    shapeLayer.path = tPath.CGPath;
    
    UILabel *mapLabel = [[UILabel alloc] init];
    [_bottomView addSubview:mapLabel];
    mapLabel.text = @"点击地图放大";
    mapLabel.center = CGPointMake(QdxWidth/2,FitRealValue(290 + 30));
    mapLabel.bounds = CGRectMake(0, 0, QdxWidth, 30);
    mapLabel.textAlignment = NSTextAlignmentCenter;
    mapLabel.textColor = [UIColor whiteColor];
    mapLabel.font = [UIFont systemFontOfSize:14];
    
    UIImageView *iconImage = [[UIImageView alloc] init];
    [_topView addSubview:iconImage];
    iconImage.center = CGPointMake(QdxWidth/2, FitRealValue(74+ 85/2));
    iconImage.bounds = CGRectMake(0, 0, FitRealValue(138), FitRealValue(85));
    iconImage.image = [UIImage imageNamed:@"趣定向logo副本"];
    
    UILabel *scoreLabel = [[UILabel alloc] init];
    [_topView addSubview:scoreLabel];
    scoreLabel.text = @"当前成绩";
    scoreLabel.center = CGPointMake(QdxWidth/2,FitRealValue(230 + 30));
    scoreLabel.bounds = CGRectMake(0, 0, QdxWidth, 30);
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.font = [UIFont systemFontOfSize:18];
    
    [self intervalSinceNow];
    _timeScoreLabel = [[UILabel alloc] init];
    [_topView addSubview:_timeScoreLabel];
    _timeScoreLabel.center = CGPointMake(QdxWidth/2,FitRealValue(308 + 55));
    _timeScoreLabel.bounds = CGRectMake(0, 0, QdxWidth, 55);
    _timeScoreLabel.textAlignment = NSTextAlignmentCenter;
    _timeScoreLabel.textColor = [UIColor whiteColor];
    _timeScoreLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:70];
    
    UILabel *point_cnLabel = [[UILabel alloc] init];
    [_topView addSubview:point_cnLabel];
    point_cnLabel.text = @"目标点标";
    point_cnLabel.center = CGPointMake(QdxWidth/2,FitRealValue(474 + 30));
    point_cnLabel.bounds = CGRectMake(0, 0, QdxWidth, 30);
    point_cnLabel.textAlignment = NSTextAlignmentCenter;
    point_cnLabel.textColor = [UIColor whiteColor];
    point_cnLabel.font = [UIFont systemFontOfSize:18];
    
    _pointLabel = [[UILabel alloc] init];
    [_topView addSubview:_pointLabel];
    _pointLabel.center = CGPointMake(QdxWidth/2, FitRealValue(546 + 55));
    _pointLabel.bounds = CGRectMake(0, 0, QdxWidth, 55);
    _pointLabel.textAlignment = NSTextAlignmentCenter;
    _pointLabel.textColor = [UIColor whiteColor];
    _pointLabel.text = _taskRefresh.pointmap_cn;
    _pointLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:50];
    
    self.presentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_QDXScrollView addSubview:self.presentButton];
    self.presentButton.center = CGPointMake(QdxWidth/2, QdxHeight - FitRealValue(208 + 214));
    self.presentButton.bounds = CGRectMake(0, 0, FitRealValue(214), FitRealValue(214));
    self.presentButton.layer.cornerRadius = 25;
    self.presentButton.layer.masksToBounds = YES;
    [self.presentButton setImage:[UIImage imageNamed:@"地图"] forState:UIControlStateNormal];
    [self.presentButton addTarget:self action:@selector(presentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.task_button = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(70 + 120), QdxHeight - FitRealValue(234+120) - 64, FitRealValue(120), FitRealValue(120))];
    [self.task_button setImage:[ToolView OriginImage:[UIImage imageNamed:@"任务"] scaleToSize:CGSizeMake(FitRealValue(120), FitRealValue(120))] forState:UIControlStateNormal];
    [self.task_button setImage:[ToolView OriginImage:[UIImage imageNamed:@"任务"] scaleToSize:CGSizeMake(FitRealValue(120), FitRealValue(120))] forState:UIControlStateHighlighted];
    [self.task_button addTarget:self action:@selector(task_buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [_QDXScrollView addSubview:self.task_button];
    
    self.history_button = [[UIButton alloc] initWithFrame:CGRectMake(FitRealValue(70), QdxHeight - FitRealValue(234+120)  - 64, FitRealValue(120), FitRealValue(120))];
    [self.history_button setImage:[ToolView OriginImage:[UIImage imageNamed:@"足迹"] scaleToSize:CGSizeMake(FitRealValue(120), FitRealValue(120))] forState:UIControlStateNormal];
    [self.history_button setImage:[ToolView OriginImage:[UIImage imageNamed:@"足迹"] scaleToSize:CGSizeMake(FitRealValue(120), FitRealValue(120))] forState:UIControlStateHighlighted];
    [self.history_button addTarget:self action:@selector(history_buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [_QDXScrollView addSubview:self.history_button];
}

#pragma mark - 圆形push 和pop的转场动画
- (id<UIViewControllerAnimatedTransitioning>)
navigationController:(UINavigationController *)navigationController
animationControllerForOperation:(UINavigationControllerOperation)operation
fromViewController:(UIViewController *)fromVC
toViewController:(UIViewController *)toVC {
    
    QDXHistoryViewController *history = [[QDXHistoryViewController alloc] init];
    MapViewController *map = [[MapViewController alloc] init];
    if([toVC isKindOfClass:[history class]]){
        if (operation == UINavigationControllerOperationPush) {
            CustomAnimateTransitionPush *animateTransitionPush =
            [CustomAnimateTransitionPush new];
            
            return animateTransitionPush;
            
        } else {
            return nil;
        }
    }else if ([toVC isKindOfClass:[map class]]){
        if (operation == UINavigationControllerOperationPush) {
            gameToMapPush *animateTransitionPush =
            [gameToMapPush new];
            
            return animateTransitionPush;
            
        } else {
            return nil;
        }
    }
    return nil;
}

-(void)task_buttonClick
{
    NSString *myline_id = [NSString stringWithFormat:@"/myline_id/%@",_myline_id];
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSString *imei = [NSString stringWithFormat:@"/imei/%@",identifierForVendor];
    NSString *allString = [NSString stringWithFormat:@"%@%@",myline_id,imei];
    
    [self showMsg_buttonClickWith:[newHostUrl stringByAppendingString:[taskTaskUrl stringByAppendingString:allString]]];
}

-(void)history_buttonClick
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    QDXHistoryViewController *historyVC = [[QDXHistoryViewController alloc] init];;
    historyVC.myline_id = _myline_id;
    [self.navigationController pushViewController:historyVC animated:YES];
}

-(void)timeFireMethod
{
    _secondsCountDown++;
    if ([_taskRefresh.linetype_id isEqualToString:@"3"]) {
        _timeScoreLabel.text =[NSString stringWithFormat:@"%@",[ToolView scoreTransfer:[NSString stringWithFormat:@"%d",[_taskRefresh.line_time intValue] -_secondsCountDown]] ];
        if([_taskRefresh.line_time intValue] -_secondsCountDown <= 900){
            _timeScoreLabel.textColor = [UIColor redColor];
            if ([_taskRefresh.line_time intValue] -_secondsCountDown <= 0) {
                [_countDownTimer setFireDate:[NSDate distantFuture]];
                [self taskRefresh];
            }
        }
    }else{
        _timeScoreLabel.text =[NSString stringWithFormat:@"%@",[ToolView scoreTransfer:[NSString stringWithFormat:@"%d",_secondsCountDown]] ];
    }
}

//计时
- (void)intervalSinceNow
{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    int mNow = [[locationString substringWithRange:NSMakeRange(5,2)] intValue];
    int mOld = [[_taskRefresh.myline_adate substringWithRange:NSMakeRange(5,2)] intValue];
    
    int dNow = [[locationString substringWithRange:NSMakeRange(8,2)] intValue];
    int dOld = [[_taskRefresh.myline_adate substringWithRange:NSMakeRange(8,2)] intValue];
    
    int HNow = [[locationString substringWithRange:NSMakeRange(11,2)] intValue];
    int HOld = [[_taskRefresh.myline_adate substringWithRange:NSMakeRange(11,2)] intValue];
    
    int MNow = [[locationString substringWithRange:NSMakeRange(14,2)] intValue];
    int MOld = [[_taskRefresh.myline_adate substringWithRange:NSMakeRange(14,2)] intValue];
    
    int sNow = [[locationString substringWithRange:NSMakeRange(17,2)] intValue];
    int sOld = [[_taskRefresh.myline_adate substringWithRange:NSMakeRange(17,2)] intValue];
    
    if((mNow - mOld) == 0 ){
        int a = sNow + MNow * 60 + HNow * 60 * 60 + dNow * 24 * 60 * 60;
        int b = sOld + MOld * 60 + HOld * 60 * 60 + dOld * 24 * 60 * 60;
        _secondsCountDown = a - b;}
    else{
        int a = sNow + MNow * 60 + HNow * 60 * 60;
        int b = sOld + MOld * 60 + HOld * 60 * 60;
        _secondsCountDown = a - b + 86400 * dNow;
    }
}

- (void)presentButtonClick{
    MapViewController *mapVC = [[MapViewController alloc]init];
    mapVC.myline_id = _myline_id;
    [self.navigationController pushViewController:mapVC animated:YES];
}

-(void)finishUI{
    [_topView removeFromSuperview];
    [_bottomView removeFromSuperview];
    [_history_button removeFromSuperview];
    [_presentButton removeFromSuperview];
    [_task_button removeFromSuperview];
    
    
    _historyArr = [NSMutableArray arrayWithCapacity:0];
    NSString *url = [newHostUrl stringByAppendingString:historyUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"myline_id"] = _myline_id;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        
        if ([responseObject[@"Code"] intValue] == 0) {
            
        }else{
            HistoryList *historyList = [[HistoryList alloc] initWithDic:responseObject];
            
            for (HistoryModel *history in historyList.historyArray) {
                [_historyArr addObject:history];
            }
            
        }
        _certificate = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth * 1.425)];
        NSString *myline_idurl = [NSString stringWithFormat:@"/myline_id/%@",_myline_id];
        NSString *allString = [NSString stringWithFormat:@"%@%@",toimgUrl,myline_idurl];
        
        NSURL *certificate_url = [NSURL URLWithString:[newHostUrl stringByAppendingString:allString]];
        [_certificate setImageWithURL:certificate_url placeholderImage:[UIImage imageNamed:@"加载中"] options:SDWebImageRefreshCached];
        [self.QDXScrollView addSubview:_certificate];
        
        self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,10 + QdxWidth * 1.425, QdxWidth, 73 * _historyArr.count + 40) style:UITableViewStylePlain];
        self.tableview.rowHeight = 73;
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        self.tableview.showsVerticalScrollIndicator = NO;
        self.tableview.backgroundColor = QDXBGColor;
        self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.QDXScrollView addSubview:self.tableview];
        
        [self refreshScrollView];
    } failure:^(NSError *error) {
        
    }];
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
    scrollViewHeight += self.tableview.frame.size.height + _certificate.frame.size.height + 64 + 50;
    [self.QDXScrollView setContentSize:(CGSizeMake(QdxWidth, scrollViewHeight))];
}

//状态3
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyArr.count;
}

//状态3
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QDXHistoryTableViewCell *cell = [QDXHistoryTableViewCell cellWithTableView:tableView];
    cell.HistoryInfo = _historyArr[_historyArr.count-1 - indexPath.row];
    
    __weak __typeof(cell) weakSelf = cell;
    cell.historyBtnBlock = ^(){
        __strong __typeof(cell) strongSelf = weakSelf;
        NSString *url = [newHostUrl stringByAppendingString:[pointhistoryUrl stringByAppendingString:[NSString stringWithFormat:@"/pointmap_id/%@",strongSelf.HistoryInfo.pointmap_id]]];
        
        self.popView = [[QDXPopView alloc] init];
        
        self.popView.task_button = strongSelf.viewHistory;
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.mediaPlaybackRequiresUserAction = NO;
        config.allowsInlineMediaPlayback = YES;
        self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,FitRealValue(90), FitRealValue(710), FitRealValue(1074) - 2 * FitRealValue(90)) configuration:config];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        
        [self.popView.deliverView addSubview:self.webView];
        
        [self.popView show];
        
    };
    
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


-(void)failedUI{
    [_webView removeFromSuperview];
    [_topView removeFromSuperview];
    [_bottomView removeFromSuperview];
    [_history_button removeFromSuperview];
    [_presentButton removeFromSuperview];
    [_task_button removeFromSuperview];
    
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
    if ([_taskRefresh.mylinest_id intValue] == 4) {
        sadButton.text = @"您已经强制结束比赛";
    }else{
        sadButton.text = @"您已经超时结束比赛";
    }
    sadButton.font = [UIFont systemFontOfSize:12];
    sadButton.textAlignment = NSTextAlignmentCenter;
    sadButton.textColor = QDXGray;
    [self.QDXScrollView addSubview:sadButton];
}

-(void)showMsg_buttonClickWith:(NSString *)url{

    self.popView = [[QDXPopView alloc] init];

    self.popView.task_button = _task_button;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.mediaPlaybackRequiresUserAction = NO;
    config.allowsInlineMediaPlayback = YES;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,FitRealValue(90), FitRealValue(710), FitRealValue(1074) - 2 * FitRealValue(90)) configuration:config];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    WKUserContentController *userCC = config.userContentController;
    //JS调用OC 添加处理脚本
    [userCC addScriptMessageHandler:self name:@"Success"];

    [self.popView.deliverView addSubview:self.webView];
    
    [self.popView show];
}

-(void)showOK_buttonClick{
    [self.popView dismiss];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
//    NSLog(@"%@",NSStringFromSelector(_cmd));
//    NSLog(@"%@",message.body);
    
    if ([message.name isEqualToString:@"Success"]) {
        [self getTaskRefresh];
        [self.MyCentralManager scanForPeripheralsWithServices:nil  options:nil];
    }
}

//检测 蓝牙状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
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
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    [self.MyCentralManager scanForPeripheralsWithServices:nil  options:nil];
    
    if (abs([RSSI.description intValue]) < abs([_taskRefresh.pointmap_rssi intValue])){
        
        NSMutableArray* macArr = [[NSMutableArray alloc] init];
        [macArr addObjectsFromArray:advertisementData[@"kCBAdvDataServiceUUIDs"]];
        NSString *string1 = [macArr componentsJoinedByString:@""];
        NSArray *array1 = [string1 componentsSeparatedByString:@"Unknown (<"];
        NSString *string2 = [array1 componentsJoinedByString:@""];
        NSArray *array2 = [string2 componentsSeparatedByString:@">)"];
        NSString *string3 = [array2 componentsJoinedByString:@""];
        if (string3.length > 8) {
            _macStr = [string3 substringFromIndex:8];
            _macStr = [_macStr substringToIndex:12];
            if ([_taskRefresh.pointmap_mac containsString:_macStr] && ![_macStr isEqualToString:_rmoveMacStr]) {
                [self.MyCentralManager stopScan];
                _rmoveMacStr = _macStr;
                
                if([_taskRefresh.mylinest_id intValue] == 1)
                {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定开始本次活动？" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action){
                        _rmoveMacStr = @"0";
                        [self.MyCentralManager scanForPeripheralsWithServices:nil  options:nil];
                    }];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
                        [self taskRefresh];
                    }];
                    [alertController addAction:cancelAction];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                }else{
                    
                    NSString *myline_id = [NSString stringWithFormat:@"/myline_id/%@",_myline_id];
                    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
                    NSString *imei = [NSString stringWithFormat:@"/imei/%@",identifierForVendor];
                    NSString *pointmap_mac = [NSString stringWithFormat:@"/pointmap_mac/%@",_macStr];
                    NSString *allString = [NSString stringWithFormat:@"%@%@%@",myline_id,imei,pointmap_mac];
                    
                    [self showMsg_buttonClickWith:[newHostUrl stringByAppendingString:[taskTaskUrl stringByAppendingString:allString]]];
                }
            } else {
                
            }
        }
        
        
    }
    
}

-(void)codeClick{
    ImagePickerController *gameVC = [[ImagePickerController alloc] initWithBlock:^(NSString *result, BOOL flag,NSString *from) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *myline_id = [NSString stringWithFormat:@"/myline_id/%@",_myline_id];
            NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
            NSString *imei = [NSString stringWithFormat:@"/imei/%@",identifierForVendor];
            NSString *pointmap_qr = [NSString stringWithFormat:@"/pointmap_qr/%@",result];
            NSString *allString = [NSString stringWithFormat:@"%@%@%@",myline_id,imei,pointmap_qr];
            
            [self showMsg_buttonClickWith:[newHostUrl stringByAppendingString:[taskTaskUrl stringByAppendingString:allString]]];
        });
        

    }];
    [self.navigationController pushViewController:gameVC animated:YES];
}

-(void)moreClick:(UIButton *)btn{
    LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"扫一扫" imageName:@"下拉－扫一扫"];
    LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"帮助" imageName:@"下拉－帮助"];
    LrdCellModel *three = [[LrdCellModel alloc] initWithTitle:@"组队" imageName:@"下拉－组队"];
    LrdCellModel *four = [[LrdCellModel alloc] initWithTitle:@"退赛" imageName:@"下拉－退赛"];
    self.dataArr = @[one, two, three, four];
    
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
    if (indexPath.row == 0) {
        [self codeClick];
    }else if (indexPath.row == 1){
        HelpViewController *helpVC = [[HelpViewController alloc] init];
        [self.navigationController pushViewController:helpVC animated:YES];
    }else if (indexPath.row == 2){
        QDXTeamsViewController *teamVC = [[QDXTeamsViewController alloc] init];
        teamVC.myLineid = _myline_id;
        [self.navigationController pushViewController:teamVC animated:YES];
    }else if (indexPath.row == 3){
        [self gameover];
    }else{
            //            QDXOffLineController *offline = [[QDXOffLineController alloc] init];
            //            [self.navigationController pushViewController:offline animated:YES];
    }
}

-(void)gameover{
    NSString *url = [newHostUrl stringByAppendingString:gameoverUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    params[@"myline_id"] = _myline_id;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        if ([responseObject[@"Code"] intValue] == 0) {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }else{
            [MBProgressHUD showSuccess:responseObject[@"Msg"]];
            [self getTaskRefresh];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
