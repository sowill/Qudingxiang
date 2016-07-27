//
//  ImagePickerController.m
//  趣定向
//
//  Created by Prince on 16/3/28.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "ImagePickerController.h"
#import "HomeController.h"
#import "LineController.h"
#import "QDXNavigationController.h"
#import <AVFoundation/AVFoundation.h>
@interface ImagePickerController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) UIView *viewPreview;
@property (strong, nonatomic) UIImageView *boxView;
@property (nonatomic, strong) NSString *result;
@property (strong, nonatomic) CALayer *scanLayer;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ImagePickerController
-(id)initWithBlock:(void(^)(NSString*,BOOL,NSString*))a{
    if (self=[super init]) {
        self.ScanResult=a;
    }
    
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_timer setFireDate:[NSDate distantFuture]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor colorWithRed:35/255 green:138/255 blue:215/255 alpha:1];
    _captureSession = nil;
    _isReading = NO;
    BOOL Custom= [UIImagePickerController
                  isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];//判断摄像头是否能用
    if (Custom) {
        [self startReading];//启动摄像头
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti1) name:@"noti1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti2) name:@"noti2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti3) name:@"noti3" object:nil];
}

-(void)noti3
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)noti1
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)noti2
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)createBack
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
    [self dismissViewControllerAnimated:YES completion:^{}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)startReading
{
    NSError *error;
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    //4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    
    //4.1.将输入流添加到会话
    [_captureSession addInput:input];
    
    //4.2.将媒体输出流添加到会话中
    [_captureSession addOutput:captureMetadataOutput];
    
    //5.创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //5.1.设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    CGRect cropRect = CGRectMake(80, 80, 280, 310);
    //CGRect cropRect = CGRectMake(75*QdxWidth/1080, 50*QdxHeight/1920, 280*QdxHeight/1920, 310*QdxWidth/1080);
    CGFloat p1 = QdxHeight/QdxWidth;
    CGFloat p2 = 1920./1080.;
    if(p1 < p2){
        CGFloat fixHeight = QdxWidth * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - QdxHeight)/2;
        captureMetadataOutput.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                          cropRect.origin.x/QdxWidth,
                                                          cropRect.size.height/fixHeight,
                                                          cropRect.size.width/QdxWidth);
    }else
    {
        CGFloat fixWidth = QdxHeight * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - QdxWidth)/2;
        captureMetadataOutput.rectOfInterest = CGRectMake(cropRect.origin.y/QdxHeight,
                                                          (cropRect.origin.x + fixPadding)/fixWidth,
                                                          cropRect.size.height/QdxHeight,
                                                          cropRect.size.width/fixWidth);
    }
    //5.2.设置输出媒体数据类型为QRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //8.设置图层的frame
    [_videoPreviewLayer setFrame:self.view.layer.bounds];
    
    //9.将图层添加到预览view的图层上
    [self.view.layer addSublayer:_videoPreviewLayer];
    
    //10.1.扫描框
    _boxView.layer.borderColor = [UIColor blackColor].CGColor;
    _boxView.layer.borderWidth = 1.0f;
    
    if (QdxHeight<500) {
        
        UIImage *image = [UIImage imageNamed:@"qrcode_scan_bg_Green_iphone"];
        _boxView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-64)];
        //        bgImageView.contentMode=UIViewContentModeTop;
        //        bgImageView.clipsToBounds=YES;
        
        _boxView.image = image;
        _boxView.userInteractionEnabled=YES;
    }else{
        UIImage *image= [UIImage imageNamed:@"qrcode_scan_bg_Green_iphone"];
        _boxView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-64)];
        //        bgImageView.contentMode=UIViewContentModeTop;
        //        bgImageView.clipsToBounds=YES;
        
        _boxView.image=image;
        _boxView.userInteractionEnabled=YES;
    }
    
    [self.view addSubview:_boxView];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, QdxHeight/2, QdxWidth, 40)];
    label.text = @"将取景框对准二维码，即可自动扫描。";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 2;
    label.font=[UIFont systemFontOfSize:12];
    label.backgroundColor = [UIColor clearColor];
    [_boxView addSubview:label];
    
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(QdxWidth*0.13, QdxHeight*0.09, QdxWidth*0.74, 1);
    _scanLayer.backgroundColor = [UIColor greenColor].CGColor;
    
    [_boxView.layer addSublayer:_scanLayer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    
    [_timer fire];
    
    _isReading = YES;
    //10.开始扫描
    [_captureSession startRunning];
    return YES;
}

- (void)moveScanLayer:(NSTimer *)timer
{
    CGRect frame = _scanLayer.frame;
    if  (_scanLayer.frame.origin.y>QdxHeight*0.46) {
        frame.origin.y = QdxHeight*0.09;
        _scanLayer.frame = frame;
    }else{
        
        frame.origin.y += 5;
        
        [UIView animateWithDuration:0.08 animations:^{
            _scanLayer.frame = frame;
        }];
    }
}


-(void)stopReading
{
    [_captureSession stopRunning];
    _captureSession = nil;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        _result = metadataObject.stringValue;
        NSLog(@"%@",_result);
        if([self.from intValue] == 0){
            self.ScanResult(metadataObject.stringValue,YES,@"0");
        }else if([self.from intValue] == 1){
            self.ScanResult(metadataObject.stringValue,YES,@"1");
        }
        
    }
    
    //[self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
    [self stopReading];
    _isReading = NO;
    if(_result){
        if([self.from intValue] == 0){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
                //[self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }
}



- (void)netWorking
{
    
    //创建请求管理对象
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"ticketinfo_name"] = _result;
    [mgr POST:[NSString stringWithFormat:@"%@%@",hostUrl,actUrl] parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dict = [[NSDictionary alloc] initWithDictionary:responseObject];
        NSDictionary *dictMsg = dict[@"Msg"];
        NSLog(@"%@",dictMsg);
        StartModel *model = [[StartModel alloc] init];
        [model setCode:dict[@"Code"] ];
        [model setMsg:dict[@"Msg"]];
        int temp = [model.Code intValue];
        if (!temp) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@",model.Msg] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1;
            [alert show];
            
            
            
        }else{
            [model setTicket_id:dictMsg[@"ticket_id"]];
            if([model.ticket_id longLongValue] <100000000000){
                [NSKeyedArchiver archiveRootObject:model.ticket_id toFile:QDXTicketFile];
                LineController *lineVC = [[LineController alloc] init];
                QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:lineVC];
                self.delegate = lineVC;
                [self.delegate PassTicket:model.ticket_id andClick:@"2"];
                [self presentViewController:nav animated:YES completion:^{
                    
                }];
            }else{
                HomeController *homeVC = [[HomeController alloc] init];
                UIViewController *target = nil;
                for(UIViewController *controller in self.navigationController.viewControllers){
                    if([controller isKindOfClass:[homeVC class]]){
                        target = controller;
                    }
                }
                if(target){
                    [self.navigationController popToViewController:target animated:YES];
                }
                
            }
            
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.4 *NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [self startReading];
        });
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
