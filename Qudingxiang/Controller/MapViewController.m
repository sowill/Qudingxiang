//
//  MapViewController.m
//  趣定向
//
//  Created by Air on 2017/3/27.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "MapViewController.h"
#import "PointmapModel.h"
#import "TaskLocationModel.h"
#import "PointAnnotationView.h"
#import "mapToGamePop.h"
#import "LrdOutputView.h"

@interface MapViewController ()<MAMapViewDelegate,UINavigationControllerDelegate,LrdOutputViewDelegate>

@property (nonatomic, strong) TaskLocationModel* taskLocation;

@property (nonatomic, strong) MAGroundOverlay *groundOverlay;

@property (nonatomic, strong) MAPointAnnotation *annotation_target;

@property (nonatomic, strong) MAMapView* mapView;

@property (nonatomic, strong) UIButton *dismissButton;

@property (nonatomic, strong) UIButton *locationButton;

@property (nonatomic, strong) UIButton *changeMapButton;

@property (nonatomic, strong) LrdOutputView *outputView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.mapView];
    
    
    self.dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(FitRealValue(70), QdxHeight - FitRealValue(60)  - 64, FitRealValue(120), FitRealValue(120))];
    [self.dismissButton setImage:[ToolView OriginImage:[UIImage imageNamed:@"关闭"] scaleToSize:CGSizeMake(FitRealValue(120), FitRealValue(120))] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.dismissButton];
    
    self.locationButton = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(70 + 120), QdxHeight - FitRealValue(60) - 64, FitRealValue(120), FitRealValue(120))];
    [self.locationButton setImage:[ToolView OriginImage:[UIImage imageNamed:@"锁定目标"] scaleToSize:CGSizeMake(FitRealValue(120), FitRealValue(120))] forState:UIControlStateNormal];
    [self.locationButton addTarget:self action:@selector(locationButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.locationButton];
    
    self.changeMapButton = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(70 + 120), QdxHeight - FitRealValue(60 + 120 + 40) - 64, FitRealValue(120), FitRealValue(120))];
    [self.changeMapButton setImage:[ToolView OriginImage:[UIImage imageNamed:@"地图-常规"] scaleToSize:CGSizeMake(FitRealValue(120), FitRealValue(120))] forState:UIControlStateNormal];
    [self.changeMapButton setImage:[ToolView OriginImage:[UIImage imageNamed:@"地图-点击"] scaleToSize:CGSizeMake(FitRealValue(120), FitRealValue(120))] forState:UIControlStateSelected];
    [self.changeMapButton addTarget:self action:@selector(changeMapButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.changeMapButton];
}

-(void)changeMapButtonClick:(UIButton *)btn{
    self.changeMapButton.selected = !btn.isSelected;

    LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"卫星地图" imageName:@"卫星地图"];
    LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"平面地图" imageName:@"平面地图"];
    CGFloat x = btn.frame.origin.x - FitRealValue(200 - 120)/2;
    CGFloat y = btn.frame.origin.y - 10;
    _outputView = [[LrdOutputView alloc] initWithDataArray:@[one, two] origin:CGPointMake(x, y) width:FitRealValue(200) height:FitRealValue(340/2) direction:kLrdOutputViewDirectionTop];
    
    _outputView.delegate = self;
    
    __weak __typeof(self) weakSelf = self;
    _outputView.dismissOperation = ^(){
        __strong __typeof(self) strongSelf = weakSelf;
        //设置成nil，以防内存泄露
        strongSelf.changeMapButton.selected = NO;
        _outputView = nil;
    };
    [_outputView pop];
}

- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row == 0) {
        self.mapView.mapType = MAMapTypeSatellite;

    }else{
        self.mapView.mapType = MAMapTypeStandard;

    }
}

-(void)locationButtonClick{
    MACoordinateSpan span = MACoordinateSpanMake(0.008, 0.008);
    MACoordinateRegion region = MACoordinateRegionMake(_mapView.userLocation.location.coordinate, span);
    [_mapView setRegion:region animated:YES];
}

- (void)dismissButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    self.navigationController.delegate=self;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getTaskLocation];
}

//将计时器 地图内存释放
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode  = MAUserTrackingModeFollow;
    [self.mapView.layer removeAllAnimations];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapView = nil;
}

- (void)dealloc {
    if (self.mapView) {
        self.mapView.delegate = nil;
        self.mapView = nil;
    }
}

-(void)setupPointandMap{
    if ([_taskLocation.line_mapon intValue] == 1) {
        MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake([_taskLocation.line_botlat floatValue], [_taskLocation.line_botlon floatValue]), CLLocationCoordinate2DMake([_taskLocation.line_toplat floatValue], [_taskLocation.line_toplon floatValue]));
        NSString *map_url = [newHostUrl stringByAppendingString:_taskLocation.line_map];
        UIImage *map_image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:map_url]]];
        _groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[ToolView imageByApplyingAlpha:1.0 image:map_image]];
        [_mapView addOverlay:_groundOverlay];
        [_mapView setVisibleMapRect:_groundOverlay.boundingMapRect animated:YES];
    }else{
        MACoordinateSpan span = MACoordinateSpanMake(0.008, 0.008);
        MACoordinateRegion region = MACoordinateRegionMake(_mapView.userLocation.location.coordinate, span);
        [_mapView setRegion:region animated:YES];
    }
    CLLocationCoordinate2D coor;
    for (PointmapModel *pointmapModel in _taskLocation.pointmapArray) {
        _annotation_target = [[MAPointAnnotation alloc] init];
        coor.latitude = [pointmapModel.point_lat floatValue];
        coor.longitude = [pointmapModel.point_lon floatValue];
        _annotation_target.coordinate = coor;
        _annotation_target.title = pointmapModel.pointmap_cn;
        [_mapView addAnnotation:_annotation_target];
    }
}

-(void)getTaskLocation{
    NSString *url = [newHostUrl stringByAppendingString:taskLocationUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"myline_id"] = _myline_id;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        TaskLocationModel *taskLocationModel = [[TaskLocationModel alloc] initWithDic:responseObject];
        _taskLocation = taskLocationModel;

        [self setupPointandMap];
    } failure:^(NSError *error) {
        
    }];
}

//懒加载地图
- (MAMapView *)mapView{
    if(!_mapView) {
        self.mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0,0 ,QdxWidth,QdxHeight)];
        self.mapView.mapType = MAMapTypeStandard;
        self.mapView.showsScale = NO;
        self.mapView.rotateCameraEnabled = NO;
    }
    return _mapView;
}

//地图覆盖物
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    if ([overlay isKindOfClass:[MAGroundOverlay class]])
    {
        MAGroundOverlayRenderer *groundOverlayRenderer = [[MAGroundOverlayRenderer alloc] initWithGroundOverlay:overlay];
        
        return groundOverlayRenderer;
    }
    return nil;
}

// Override
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation{
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

//用来自定义转场动画
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPop) {
        mapToGamePop *pingInvert = [mapToGamePop new];
        return pingInvert;
    }else{
        return nil;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
