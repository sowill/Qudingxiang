//
//  QDXOffLineController.m
//  趣定向
//
//  Created by Air on 16/3/24.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXOffLineController.h"
#import "QRCodeGenerator.h"
#import "HomeController.h"
#import "QDXTeamsViewController.h"
#import "ImagePickerController.h"
#import <QuartzCore/QuartzCore.h>
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "QDXGameModel.h"
#import "QDXTeamsModel.h"
#import "LineModel.h"
#import "QDXHIstoryModel.h"
#import "QDXPointModel.h"
#import "QDXAreaModel.h"
#import "QDXQuestionModel.h"
#import "point_questionModel.h"
#import "line_pointModel.h"
#import "QDXOfflineDB.h"
#import "LrdOutputView.h"
#import "CYAlertController.h"
#import "QDXHistoryViewController.h"

@interface QDXOffLineController () <LrdOutputViewDelegate>
{
    //场地
    NSString *place;
    //四种游戏状态
    int mstate;
    
    //搜索到的mac值
    NSString *macStr;
    //信号强度
    NSString *rssi;
    //要求获取的mac值不带冒号用来比较
    NSArray *mac_Label;
    NSString *rmoveMacStr;
    NSString *qkey;
    NSString *question;
    NSString *qa;
    NSString *qb;
    NSString *qc;
    NSString *qd;
    //判断是否是终点
    NSString *isFinish;

    //回答
    NSString *answer;
    
    NSString *oldMyLineid;
    NSString *pointmap_id;
    BOOL lock;
    
    int errorCount;
    int secondsCountDown;
    
    UIButton *download;
    UIButton *start;
    
    UIImageView *map;
    NSString *sdateStr;
    UILabel *useTime;
    NSTimer *countDownTimer;
    UILabel *point_name;
}

/**
 *  创建数据库模型
 */
@property (nonatomic, strong) QDXOfflineDB *offlineDB;
@property (nonatomic, strong) CBCentralManager *MyCentralManager;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) LrdOutputView *outputView;
@property (nonatomic, strong) NSMutableArray *temp_Point;
@end

@implementation QDXOffLineController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.offlineDB = [QDXOfflineDB shareDataBase];
//    [_offlineDB closeOfflineDB];
    
    [self setupFrame];
}

-(void)compareQuestion
{
    lock = NO;
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    if([qkey length] == 0){
        QDXHIstoryModel *history_insert = [[QDXHIstoryModel alloc] initWithEdate:@"1" Myline_id:mylineid Point_id:pointmap_id Score:locationString];
        [_offlineDB insertHistory:history_insert];
        [self selectMethod];
    }else{
        if ([answer length] == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 3.0s后执行block里面的代码
                [self selectQuestion];
                [self setupTaskView];
            });
        }else{
            if([answer isEqualToString:qkey]){
                QDXHIstoryModel *history_insert = [[QDXHIstoryModel alloc] initWithEdate:@"1" Myline_id:mylineid Point_id:pointmap_id Score:locationString];
                [_offlineDB insertHistory:history_insert];
                [self selectMethod];
            }else{
                answer = nil;
                [self compareQuestion];
            }
        }
    }
}

-(void)setupTaskView
{
    lock = YES;
//    NSLog(@"%@",qkey);
    CYAlertController *alert = [CYAlertController offlineAlertWithTitle:@"问题" message:question];
    alert.alertViewCornerRadius = 10;
    CYAlertAction *cancelAction_A = [CYAlertAction actionWithTitle:[@"A. " stringByAppendingString:qa] style:CYAlertActionStyleCancel handler:^{
        answer = @"A";
        [self compareQuestion];}];
    CYAlertAction *cancelAction_B = [CYAlertAction actionWithTitle:[@"B. " stringByAppendingString:qb] style:CYAlertActionStyleCancel handler:^{
        answer = @"B";
        [self compareQuestion];}];
    CYAlertAction *cancelAction_C = [CYAlertAction actionWithTitle:[@"C. " stringByAppendingString:qc] style:CYAlertActionStyleCancel handler:^{
        answer = @"C";
        [self compareQuestion];}];
    CYAlertAction *cancelAction_D = [CYAlertAction actionWithTitle:[@"D. " stringByAppendingString:qd] style:CYAlertActionStyleCancel handler:^{
        answer = @"D";
        [self compareQuestion]; }];
    [alert addActions:@[cancelAction_A, cancelAction_B, cancelAction_C ,cancelAction_D]];
    alert.presentStyle = CYAlertPresentStyleBounce;
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)selectQuestion
{
    NSArray *questionArray = [_offlineDB selectQuestionWithQid:pointmap_id];
    for (int i=0; i<questionArray.count; i++) {
        QDXQuestionModel *questions =[questionArray objectAtIndex:i];
        qkey = questions.qkey;
        
        question = questions.question_name;
        qa = questions.qa;
        qb = questions.qb;
        qc = questions.qc;
        qd = questions.qd;
    }
}

-(void)selectMethod
{
    self.MyCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    //再次校验重复数据
    [_offlineDB deleteTheSame];
    
    QDXGameModel *myline = [_offlineDB selectMylineWithMLid:mylineid];

    NSArray *historyArray = [_offlineDB selectHistoryWithMLid:mylineid];
    
    NSArray *linepointArray = [_offlineDB selectPointWithLid:myline.line_id];
    
    line_pointModel *line_point =[linepointArray objectAtIndex:historyArray.count];
    
    if ([line_point.linetype_id intValue] == 2) {
        //自由
        NSMutableArray *tArray = [NSMutableArray array];
        for (int i=0; i<linepointArray.count; i++) {
            line_pointModel *line_points =[linepointArray objectAtIndex:i];
            [tArray addObject:line_points.point_id];
            for (int i=0; i<historyArray.count; i++) {
                QDXHIstoryModel *historys =[historyArray objectAtIndex:i];
                [tArray removeObject:historys.point_id];
            }
        }
        self.temp_Point = [NSMutableArray array];
        NSMutableArray *labelArray = [NSMutableArray array];
        NSArray *pointArray = [_offlineDB selectAllPointWithPid:tArray];
        for (int i=0; i<pointArray.count; i++) {
            QDXPointModel *points =[pointArray objectAtIndex:i];
            [self.temp_Point addObject:points.point_name];
            rssi = points.rssi;
            NSString *macLabel =points.label;
            NSArray *array3 = [macLabel componentsSeparatedByString:@":"];
            NSString *string3 = [array3 componentsJoinedByString:@""];
            [labelArray addObject:string3];
        }
        mac_Label = labelArray;
//        NSLog(@"%@",mac_Label);
        point_name.text = @"神秘点标";
    }else{
        //依次
        QDXPointModel *point = [_offlineDB selectPointWithPid:line_point.point_id];
        
        rssi = point.rssi;
        isFinish = line_point.pindex;
        NSString *macLabel =point.label;
        NSArray *array3 = [macLabel componentsSeparatedByString:@":"];
        NSString *string3 = [array3 componentsJoinedByString:@""];
        mac_Label = [string3 componentsSeparatedByString:@","];
//        NSLog(@"%@",mac_Label);
        point_name.text = point.point_name;
        pointmap_id =line_point.pointmap_id;
    }
    
    myline = [[QDXGameModel alloc] initWithL_id:myline.line_id ML_id:myline.myline_id MS_id:[NSString stringWithFormat:@"%d",mstate] Sdate:myline.sdate Score:myline.score Isleader:myline.isLeader P_mid:line_point.pointmap_id];
    [_offlineDB modifyMyline:myline];
    
    sdateStr = myline.sdate;
    [self intervalSinceNow];
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    mstate = [myline.mstatus_id intValue];
    
    
    [self selectQuestion];
    
    if (mstate == 0) {
        self.navigationItem.title = @"准备活动";
    }else if (mstate == 2){

    }else if (mstate == 3){
        lock = YES;
        NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        documentDir= [documentDir stringByAppendingPathComponent:@"QDXMyLine.data"];
        [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
        self.navigationItem.title = @"活动结束";
    }else{
        lock = YES;
        NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        documentDir= [documentDir stringByAppendingPathComponent:@"QDXMyLine.data"];
        [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
        self.navigationItem.title = @"强制结束";
    }
    
    UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 4)];
    [more addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [more setImage:[UIImage imageNamed:@"更多－下拉"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:more];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:more];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, buttonItem];
}

-(void)moreClick:(UIButton *)btn
{
    LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"扫一扫" imageName:@"下拉－扫一扫"];
    LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"退赛" imageName:@"下拉－退赛"];
    LrdCellModel *three = [[LrdCellModel alloc] initWithTitle:@"帮助" imageName:@"下拉－帮助"];
    self.dataArr = @[one, two, three];
    
    
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
        
    }else{
        
    }
}

-(void)setuploadPoint
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"myline_id"] = mylineid;
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Myline/loadPoint"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1) {
            NSArray *line_pointArray = [line_pointModel mj_objectArrayWithKeyValuesArray:infoDict[@"Msg"]];
            for (line_pointModel *line_point in line_pointArray) {
                QDXPointModel *points = [[QDXPointModel alloc] initWithP_id:line_point.point.point_id A_id:line_point.point.area_id LAT:line_point.point.LAT LON:line_point.point.LON Label:line_point.point.label P_name:line_point.point.point_name Rssi:line_point.point.rssi];
                line_pointModel *l_question = [[line_pointModel alloc] initWithL_id:line_point.line_id P_id:line_point.point_id P_mapid:line_point.pointmap_id P_mapdes:line_point.pointmap_des P_index:line_point.pindex l_typeid:line_point.line.linetype_id];
                [_offlineDB insertLineAndPoint:l_question];
                [_offlineDB insertPoint:points];
            }
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)setuploadQuestion
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"myline_id"] = mylineid;
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Myline/loadQuestion"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1) {
            NSArray *point_questionArray = [point_questionModel mj_objectArrayWithKeyValuesArray:infoDict[@"Msg"]];
            for (point_questionModel *point_question in point_questionArray) {
                QDXQuestionModel *questions = [[QDXQuestionModel alloc] initWithQName:point_question.question.question_name Qa:point_question.question.qa Qb:point_question.question.qb Qc:point_question.question.qc Qd:point_question.question.qd Qkey:point_question.question.qkey Qid:point_question.question.question_id];
                point_questionModel *p_question = [[point_questionModel alloc] initWithQ_id:point_question.question_id P_mapid:point_question.pointmap_id];
                [_offlineDB insertPointAndQuestion:p_question];
                [_offlineDB insertQuestion:questions];
            }
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)setupgetMylineInfo
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"myline_id"] = mylineid;
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Myline/getMyline"];
    
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret==1) {
            QDXGameModel *game = [QDXGameModel mj_objectWithKeyValues:infoDict[@"Msg"]];
            for (QDXHIstoryModel *history in game.history) {
                QDXHIstoryModel *historys = [[QDXHIstoryModel alloc] initWithEdate:history.edate Myline_id:history.myline_id Point_id:history.point_id Score:history.point_id];
                [_offlineDB insertHistory:historys];
            }
            
            QDXGameModel *myline = [[QDXGameModel alloc] initWithL_id:game.line_id ML_id:game.myline_id MS_id:game.mstatus_id Sdate:game.sdate Score:game.score Isleader:game.isLeader P_mid:game.pointmap_id];
            [_offlineDB insertMyLine:myline];
            
            place= game.line.line_sub;
            
            NSString *map_url = [hostUrl stringByAppendingString:game.point.area.map];
            UIImage *map_image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:map_url]]];
            
            NSData *data;
            
            if (UIImagePNGRepresentation(map_image) == nil) {
                
                data = UIImageJPEGRepresentation(map_image, 1);
                
            } else {
                
                data = UIImagePNGRepresentation(map_image);
                
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"image"];
            [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            [fileManager createFileAtPath:[NSString stringWithFormat:@"%@/map_%@.png",filePath,mylineid] contents:data attributes:nil];
            
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
    int b = abs([RSSI.description intValue]);
    CGFloat ci = (b - abs([rssi intValue])) / (10 * 4.);
    if (pow(10,ci) < 1 )
    {
        NSMutableArray *macArr = [[NSMutableArray alloc] init];
        [macArr addObjectsFromArray:advertisementData[@"kCBAdvDataServiceUUIDs"]];
        NSString *string1 = [macArr componentsJoinedByString:@""];
        NSArray *array1 = [string1 componentsSeparatedByString:@"Unknown (<"];
        NSString *string2 = [array1 componentsJoinedByString:@""];
        NSArray *array2 = [string2 componentsSeparatedByString:@">)"];
        NSString *string3 = [array2 componentsJoinedByString:@""];
        
        if (string3.length > 8) {
            if (lock == NO) {
                macStr = [string3 substringFromIndex:8];
                macStr = [macStr substringToIndex:12];
                for (NSString * str in mac_Label) {
                    if ([macStr isEqualToString:str] && ![macStr isEqualToString:rmoveMacStr])
                    {
                        lock = YES;
//                        NSLog(@"macStr: %@ 距离:%.1fm",macStr,pow(10,ci));
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        if(mstate == 1)
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确定开始本次活动？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                            alert.tag =2;
                            [alert show];
                        }else{
                            rmoveMacStr = macStr;
                            errorCount = 0;
                            [self compareQuestion];
                        }
                        
                    }
                    
                }
                
            }
        }
    }
    [self.MyCentralManager scanForPeripheralsWithServices:nil  options:nil];
}

//设置Frame
-(void)setupFrame
{
    self.navigationItem.title = @"离线下载";
    
    download = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 100, 50)];
    [download setTitle:@"下载" forState:UIControlStateNormal];
    [download addTarget:self action:@selector(dowloadDetails) forControlEvents:UIControlEventTouchUpInside];
    download.backgroundColor = [UIColor blackColor];
    download.titleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:download];
    
    start = [[UIButton alloc] initWithFrame:CGRectMake(10, 300, 100, 50)];
    [start setTitle:@"开始" forState:UIControlStateNormal];
    [start addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    start.backgroundColor = [UIColor blackColor];
    start.titleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:start];
}

-(void)startGame
{
    [download removeFromSuperview];
    [start removeFromSuperview];
    
    map = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight/3)];
    map.userInteractionEnabled = YES;
    NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/image/map_%@.png",NSHomeDirectory(),mylineid];
    UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:aPath3];
    map.image = imgFromUrl3;
    [self.view addSubview:map];
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [map addGestureRecognizer:tap];
    
    useTime = [[UILabel alloc] init];
    CGFloat useTimeCenterX = QdxWidth * 0.5;
    CGFloat useTimeCenterY = QdxHeight/3 + 40 + 25/2;
    useTime.center = CGPointMake(useTimeCenterX, useTimeCenterY);
    useTime.bounds = CGRectMake(0, 0, QdxWidth, 25);
    useTime.textAlignment = NSTextAlignmentCenter;
    useTime.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
    useTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
    [self.view addSubview:useTime];
    
    UILabel *currentTime = [[UILabel alloc] init];
    CGFloat currentTimeCenterX = useTimeCenterX;
    CGFloat currentTimeCenterY = useTimeCenterY + 25/2 + 10 + 15/2;
    currentTime.center = CGPointMake(currentTimeCenterX, currentTimeCenterY);
    currentTime.bounds = CGRectMake(0, 0, QdxWidth/2, 15);
    currentTime.textAlignment = NSTextAlignmentCenter;
    currentTime.text = @"当前成绩";
    currentTime.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    currentTime.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:currentTime];
    
    point_name = [[UILabel alloc] init];
    CGFloat point_nameCenterX = currentTimeCenterX;
    CGFloat point_nameCenterY = currentTimeCenterY + 15/2 + 30 + 20/2;
    point_name.center = CGPointMake(point_nameCenterX, point_nameCenterY);
    point_name.bounds = CGRectMake(0, 0, 100, 20);
    point_name.textAlignment = NSTextAlignmentCenter;
    point_name.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
    point_name.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    [self.view addSubview:point_name];
    
    UILabel *point = [[UILabel alloc] init];
    CGFloat pointCenterX = point_nameCenterX;
    CGFloat pointCenterY = point_nameCenterY + 20/2 + 10 + 15/2;
    point.center = CGPointMake(pointCenterX, pointCenterY);
    point.bounds = CGRectMake(0, 0, QdxWidth/2, 15);
    point.textAlignment = NSTextAlignmentCenter;
    point.text = @"目标点标";
    point.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    point.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:point];
    
    UIButton *history = [[UIButton alloc] initWithFrame:CGRectMake(10, QdxHeight - 120, 100, 50)];
    [history setTitle:@"历史" forState:UIControlStateNormal];
    [history addTarget:self action:@selector(history_click) forControlEvents:UIControlEventTouchUpInside];
    history.backgroundColor = [UIColor blackColor];
    history.titleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:history];
    
    UIButton *details = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - 10 - 100, QdxHeight - 120, 100, 50)];
    [details setTitle:@"详情" forState:UIControlStateNormal];
    [details addTarget:self action:@selector(details_click) forControlEvents:UIControlEventTouchUpInside];
    details.backgroundColor = [UIColor blackColor];
    details.titleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:details];
    
    [self selectMethod];
}

- (void)history_click
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    QDXHistoryViewController *viewController = [[QDXHistoryViewController alloc] init];
    QDXGameModel *myline = [_offlineDB selectMylineWithMLid:mylineid];
    viewController.Game = myline;
//    NSLog(@"count  %ld",(long)myline.history.count);
    [self.navigationController pushViewController:viewController animated:YES];

}

- (void)details_click
{
    for (NSString *point in self.temp_Point) {
//        NSLog(@"%@",point);
    }
}

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
    useTime.text =[NSString stringWithFormat:@"%@",[ToolView scoreTransfer:[NSString stringWithFormat:@"%d",secondsCountDown]] ];
    
   
}

-(void)dowloadDetails
{
    [self setupgetMylineInfo];
    [self setuploadPoint];
    [self setuploadQuestion];
    [_offlineDB deleteTheSame];
    [MBProgressHUD showSuccess:@"下载完成"];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [countDownTimer setFireDate:[NSDate distantFuture]];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0 && alertView.tag == 2){
        rmoveMacStr = macStr;
        errorCount = 0;
        mstate = 2;
        [self compareQuestion];
    }else if (buttonIndex ==1 && alertView.tag == 2){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 2.0s后执行block里面的代码
            lock = NO;
        });
    }
}

-(void)codeClick
{
    ImagePickerController *gameVC = [[ImagePickerController alloc] initWithBlock:^(NSString *result, BOOL flag,NSString *from) {
        gameVC.from = from;
        macStr = result;
        if (lock == NO) {
            
            for (NSString * str in mac_Label) {
                if ([macStr isEqualToString:str])
                {
                    lock = YES;
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    if(mstate == 0)
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确定开始本次活动？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                        alert.tag =2;
                        [alert show];
                    }else{
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_sync(queue, ^{
                            errorCount = 0;
                            [self compareQuestion];
                        });
                        
                    }
                        
                    });
                }
            }
            
        }
    }];
    [self.navigationController pushViewController:gameVC animated:YES];
}

- (void)bigButtonTapped:(id)sender
{
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = map.image;
    imageInfo.referenceRect = map.frame;
    imageInfo.referenceView = map.superview;
    imageInfo.referenceContentMode = map.contentMode;
    imageInfo.referenceCornerRadius = map.layer.cornerRadius;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

@end
