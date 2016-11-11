//
//  QDXPointSettingViewController.m
//  趣定向
//
//  Created by Air on 2016/11/7.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXPointSettingViewController.h"
#import "QDXPointModel.h"
#import "PointAnnotationView.h"

@interface QDXPointSettingViewController ()<MAMapViewDelegate>

{
    UIView *playView;
    UIView *setView;
    MAPointAnnotation *annotation_target;
//    MAGroundOverlay *groundOverlay;
    UILabel *localLabel;
    
    UILabel *lonLabel;
    UILabel *latLabel;
}
@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) UIScrollView *QDXScrollView;
@end

@implementation QDXPointSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.pointModel.point_name;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(commitClick)];
//    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:commit];
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    negativeSpacer.width = -10;
//    self.navigationItem.rightBarButtonItems = @[negativeSpacer, buttonItem];
    
    self.QDXScrollView =[[UIScrollView alloc] initWithFrame:self.view.frame];
    self.QDXScrollView.showsVerticalScrollIndicator = FALSE;
    self.QDXScrollView.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    [self.view addSubview:self.QDXScrollView];
    
    _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0,0 ,QdxWidth,QdxHeight)];
    _mapView.mapType = MAMapTypeStandard;
    _mapView.delegate = self;
    _mapView.showsScale = NO;
    _mapView.rotateCameraEnabled = NO;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    [self.QDXScrollView addSubview:_mapView];
    
    playView = [[UIView alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(24), QdxWidth - FitRealValue(24*2), FitRealValue(80))];
    playView.backgroundColor = [UIColor whiteColor];
    [self.QDXScrollView addSubview:playView];
    
    localLabel = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24),FitRealValue(26), QdxWidth - FitRealValue(24*2), FitRealValue(28))];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"已设置：经度%@  纬度%@",self.pointModel.LAT,self.pointModel.LON]];
    
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] range:NSMakeRange(0,6)];
    
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] range:NSMakeRange(7 + self.pointModel.LAT.length,3)];
    
    //设置自定义位置字符串大小
    //    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial"size:18]range:NSMakeRange(str.length-5,5)];
    //然后，我们创建个UILabel对象进行测试
    localLabel.attributedText=str;
    localLabel.font = [UIFont fontWithName:@"Arial"size:15];
    localLabel.textAlignment = NSTextAlignmentLeft;
    [playView addSubview:localLabel];
    
    setView = [[UIView alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(24 + 80 + 24), QdxWidth - FitRealValue(24 * 2), FitRealValue(240))];
    setView.backgroundColor = [UIColor whiteColor];
    [self.QDXScrollView addSubview:setView];
    
    UILabel *nowLabel = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24),FitRealValue(26), QdxWidth - FitRealValue(24 * 2), FitRealValue(28))];
    nowLabel.font = [UIFont fontWithName:@"Arial"size:18];
    nowLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    nowLabel.text = @"当前位置";
    nowLabel.textAlignment = NSTextAlignmentLeft;
    [setView addSubview:nowLabel];
    
    latLabel = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(26 + 28 + 26 + 26), QdxWidth - FitRealValue(24 * 2), FitRealValue(28))];
    latLabel.font = [UIFont fontWithName:@"Arial"size:18];
    latLabel.textAlignment = NSTextAlignmentLeft;
    [setView addSubview:latLabel];
    
    lonLabel = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(26 + 28 + 26 + 26 + 28 + 26 + 26), QdxWidth - FitRealValue(24 * 2), FitRealValue(28))];
    lonLabel.font = [UIFont fontWithName:@"Arial"size:18];
    lonLabel.textAlignment = NSTextAlignmentLeft;
    [setView addSubview:lonLabel];
    
    CLLocationCoordinate2D coor;
    annotation_target = [[MAPointAnnotation alloc]init];
    coor.latitude = [self.pointModel.LAT floatValue];
    coor.longitude = [self.pointModel.LON floatValue];
    
    annotation_target.coordinate = coor;
    annotation_target.title = self.pointModel.point_name;
    [self.mapView addAnnotation:annotation_target];
}

- (void)commitClick
{
    [self PointModify];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode  = MAUserTrackingModeFollow;
    [self.mapView.layer removeAllAnimations];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapView = nil;
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    
    if (updatingLocation)
    {
        NSMutableAttributedString *lon = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"纬度：%f",userLocation.location.coordinate.longitude]];
            
        [lon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] range:NSMakeRange(0,3)];
        lonLabel.attributedText = lon;
            
        NSMutableAttributedString *lat = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"经度：%f",userLocation.location.coordinate.latitude]];
        [lat addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] range:NSMakeRange(0,3)];
        latLabel.attributedText = lat;
        //        localLabel.text = [NSString stringWithFormat:@"%f   %f",userLocation.location.coordinate.latitude,userLocation.location.coordi
        
        [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
        
    }
}

// Override
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseID = @"annotationID";
        PointAnnotationView *annotationView = (PointAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseID];
        if (annotationView == nil)
        {
            annotationView = [[PointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseID];
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

-(void)PointModify
{
    
    NSString *lonStr = [lonLabel.text substringFromIndex:3];
    NSString *latStr = [latLabel.text substringFromIndex:3];
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"point_id"] = self.pointModel.point_id;
    params[@"LON"] = lonStr;
    params[@"LAT"] = latStr;
    NSString *url = [hostUrl stringByAppendingString:@"Home/Point/modify"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1) {
//            NSLog(@"%@",infoDict);
            [MBProgressHUD showSuccess:@"提交成功"];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [MBProgressHUD showError:@"提交失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showError:@"提交失败"];
    }];
}

@end
