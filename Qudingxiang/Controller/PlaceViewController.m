//
//  PlaceViewController.m
//  趣定向
//
//  Created by Air on 2017/3/9.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "PlaceViewController.h"
#import "HomeModel.h"
#import "PlaceCollectionViewCell.h"
#import "QDXActivityPriceViewController.h"
#import "LocationChoiceViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "UIButton+ImageText.h"

@interface PlaceViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,ChoseCityDelegate,CLLocationManagerDelegate>
{
    UIButton *locationBtn;
}
@property (nonatomic, strong) NSMutableArray *actArray;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) CLLocationManager* locationManager;

@end

static NSString *placeReuseID = @"placeReuseID";

@implementation PlaceViewController

- (NSMutableArray *)actArray
{
    if (_actArray == nil) {
        _actArray = [NSMutableArray array];
    }
    return _actArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = _navTitle;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self findMe];
    
    locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [locationBtn setTitle:@"地点" forState:UIControlStateNormal];
    locationBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [locationBtn setImage:[UIImage imageNamed:@"下拉icon"] forState:UIControlStateNormal];
    [locationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [locationBtn setImagePosition:1 spacing:0];
    [locationBtn addTarget:self action:@selector(locationClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:locationBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, buttonItem];
    
    [self cellDataWith:@"1" andWithType:_type];
}

- (void)findMe
{
    /** 由于IOS8中定位的授权机制改变 需要进行手动授权
     * 获取授权认证，两个方法：
     * [self.locationManager requestWhenInUseAuthorization];
     * [self.locationManager requestAlwaysAuthorization];
     */
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        NSLog(@"requestAlwaysAuthorization");
        [self.locationManager requestAlwaysAuthorization];
    }
    
    //开始定位，不断调用其代理方法
    [self.locationManager startUpdatingLocation];
    //    NSLog(@"start gps");
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // 1.获取用户位置的对象
    CLLocation *location = [locations lastObject];
    //    CLLocationCoordinate2D coordinate = location.coordinate;
    //    NSLog(@"纬度:%f 经度:%f", coordinate.latitude, coordinate.longitude);
    //
    //    NSLog(@"-------根据经纬度反查地理位置--%f--%f",coordinate.latitude,coordinate.longitude);
    
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
    [clGeoCoder reverseGeocodeLocation:location completionHandler: ^(NSArray *placemarks,NSError *error) {
        
        //        NSLog(@"--array--%d---error--%@",(int)placemarks.count,error);
        
        if (placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *city = placemark.administrativeArea;
            [locationBtn setTitle:[city substringToIndex:2] forState:UIControlStateNormal];
            //            NSLog(@"%@",placemark.addressDictionary[@"Name"]);
        }
    }];
    
    // 2.停止定位
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}

-(void)choseCityPassValue:(NSString *)city
{
    [locationBtn setTitle:city forState:UIControlStateNormal];
}

-(void)locationClick
{
    LocationChoiceViewController *cityVC=[[LocationChoiceViewController alloc]init];
    cityVC.delegate = self;
    cityVC.location = locationBtn.titleLabel.text;
    [self.navigationController pushViewController:cityVC animated:YES];
}


-(void)cellDataWith:(NSString *)cur andWithType:(NSString *)type
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"areatype_id"] = @"1";
    params[@"curr"] = cur;
    params[@"type"] =type;
    NSString *url = [hostUrl stringByAppendingString:goodsUrl];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1) {
            NSDictionary *dataDict = infoDict[@"Msg"][@"data"];
            _actArray = [[NSMutableArray alloc] init];
            for(NSDictionary *dict in dataDict){
                HomeModel *model = [[HomeModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [_actArray addObject:model];
            }
            
            [self createCollectionView];
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)createCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(FitRealValue(346), FitRealValue(460 + 20));
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = FitRealValue(9);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(FitRealValue(20), 0, QdxWidth - FitRealValue(40), QdxHeight - 64 - FitRealValue(20)) collectionViewLayout:layout];
    self.collectionView.backgroundColor = QDXBGColor;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerClass:[PlaceCollectionViewCell class] forCellWithReuseIdentifier:placeReuseID];
    [self.view addSubview:self.collectionView];
}

#pragma mark --------------------------------------------------
#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.actArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:placeReuseID forIndexPath:indexPath];
    cell.homeModel = self.actArray[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QDXActivityPriceViewController *actWithPriceVC = [[QDXActivityPriceViewController alloc] init];
    actWithPriceVC.hidesBottomBarWhenPushed = YES;
    actWithPriceVC.type = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self.navigationController pushViewController:actWithPriceVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
