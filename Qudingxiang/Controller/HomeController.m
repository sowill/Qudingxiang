//
//  HomeController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/15.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "HomeController.h"
#import "LineController.h"

#import "QDXLineDetailViewController.h"

#import "ImagePickerController.h"
#import "QDXLoginViewController.h"
#import "QDXNavigationController.h"
#import "ImageScrollView.h"

#import "QDXActivityViewController.h"

#import "codeWebViewController.h"
#import "QDXHomeTableViewCell.h"
#import "QDXHomeCooperationCell.h"
#import "QDXHomeCollectionView.h"
#import "LocationChoiceViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "UIButton+ImageText.h"
#import "MoreCooperationViewController.h"
#import "QDXActivityPriceViewController.h"
#import "PlaceViewController.h"
#import "AreaList.h"
#import "Area.h"
#import "PartnerList.h"
#import "Partner.h"
#import "CityList.h"
#import "City.h"
#import "GoodsList.h"
#import "Goods.h"
#import "LineList.h"

@interface HomeController ()<UITableViewDataSource,UITableViewDelegate,QDXHomeTableViewCellDelegate,QDXCooperationCellDelegate,ChoseCityDelegate,CLLocationManagerDelegate>
{
    NSInteger currNum;
    NSInteger page;
    NSInteger code;
    UIButton *locationBtn;
}

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) ImageScrollView *imgScrollView;

@property (nonatomic,strong) UIButton *scanBtn;

@property (nonatomic,strong) NSMutableArray *dataArr;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSMutableArray *hotAreaArr;

@property (nonatomic, strong) NSMutableArray *partnerArr;

@property (nonatomic, strong) NSMutableArray *cityArr;

@property (nonatomic, strong) NSMutableArray *scrollArr;

@property (nonatomic, strong) NSString *cityId;

@end

@implementation HomeController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

-(void)reloadData
{
    [self loadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [_imgScrollView stopTimer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"趣定向";
    
    _scanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 18)];
    [_scanBtn setBackgroundImage:[UIImage imageNamed:@"index_sweep"] forState:UIControlStateNormal];
    [_scanBtn addTarget:self action:@selector(scanClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_scanBtn];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self findMe];
    
    locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [locationBtn setTitle:@"上海" forState:UIControlStateNormal];
    locationBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [locationBtn setImage:[UIImage imageNamed:@"下拉icon"] forState:UIControlStateNormal];
    [locationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [locationBtn setImagePosition:1 spacing:0];
    [locationBtn addTarget:self action:@selector(locationClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:locationBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateRefresh) name:@"stateRefresh" object:nil];
    
    [self createTableView];
    [self createHeaderView];
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

-(void)choseCityPassValue:(City *)city
{
    [locationBtn setTitle:city.city_cn forState:UIControlStateNormal];
    
    for (City *city in _cityArr) {
        //这个默认城市名是两个字符串
        if ([[city.city_cn substringToIndex:2] isEqualToString:locationBtn.titleLabel.text]) {
            _cityId = city.city_id;
        }
    }
}

-(void)locationClick
{
    LocationChoiceViewController *cityVC=[[LocationChoiceViewController alloc]init];
    cityVC.hidesBottomBarWhenPushed = YES;
    cityVC.delegate = self;
    cityVC.items = _cityArr;
    cityVC.location = locationBtn.titleLabel.text;
    [self.navigationController pushViewController:cityVC animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stateRefresh" object:nil];
}

- (void)stateRefresh
{
    [self loadData];
}

- (void)getCity
{
    _cityArr = [NSMutableArray arrayWithCapacity:0];
    NSString *url = [newHostUrl stringByAppendingString:getCityUrl];
    [PPNetworkHelper POST:url parameters:nil success:^(id responseObject) {
        
        CityList *cityList = [[CityList alloc] initWithDic:responseObject];
        
        for (City *city in cityList.cityArray) {
            //这个默认城市名是两个字符串
            if ([[city.city_cn substringToIndex:2] isEqualToString:locationBtn.titleLabel.text]) {
                _cityId = city.city_id;
            }
            [_cityArr addObject:city];
        }
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)getPartner
{
    _partnerArr = [NSMutableArray arrayWithCapacity:0];
    NSString *url = [newHostUrl stringByAppendingString:getPartnerUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        
        PartnerList *partnerList = [[PartnerList alloc] initWithDic:responseObject];
        
        for (Partner *partner in partnerList.PartnerArray) {
            [_partnerArr addObject:partner];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)getHotArea
{
    _hotAreaArr = [NSMutableArray arrayWithCapacity:0];
    NSString *url = [newHostUrl stringByAppendingString:getHotAreaUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        
        AreaList *areaList = [[AreaList alloc] initWithDic:responseObject];
        
        for (Area *area in areaList.areaArray) {
            [_hotAreaArr addObject:area];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)loadData
{
    [self topViewData];
    [self getHotArea];
    [self getPartner];
    [self getCity];
}

- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight- 64 - 10 - 25) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.automaticallyAdjustsScrollViewInsets = false;
    [self.view addSubview:_tableView];
    
    [self refreshView];
}

- (void)createHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth,FitRealValue(445 + 180))];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    //创建
    _imgScrollView = [[ImageScrollView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(445))];
    [view addSubview:_imgScrollView];
    
    UIImageView *mask = [[UIImageView alloc] initWithFrame:CGRectMake(0, FitRealValue(445)-QdxWidth*0.1, QdxWidth, QdxWidth*0.1)];
    mask.image = [UIImage imageNamed:@"index_mask"];
    [_imgScrollView addSubview:mask];
    
    NSArray *titleArr = @[@"场地",@"赛事",@"活动"];
    NSArray *imageArr = @[@"场地icon",@"赛事icon",@"活动icon",];
    CGFloat scrollViewMaxY = CGRectGetMaxY(_imgScrollView.frame);
    for(int i=0; i<3; i++){
        UIButton *btn = [ToolView createButtonWithFrame:CGRectMake(FitRealValue((226 + 18) * i) + FitRealValue(20), scrollViewMaxY+FitRealValue(20), FitRealValue(226), FitRealValue(140)) title:titleArr[i] backGroundImage:imageArr[i] Target:self action:@selector(btnClick:) superView:view];
        btn.titleLabel.textColor = [UIColor whiteColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        [btn setImagePosition:2 spacing:0];
        btn.layer.cornerRadius = 3;
        btn.tag = 1+i;
        switch (i) {
            case 0:
                btn.backgroundColor = QDXGreen;
                break;
            case 1:
                btn.backgroundColor = QDXOrange;
                break;
            case 2:
                btn.backgroundColor = QDXBlue;
                break;
            default:
                break;
        }
    }
    _tableView.tableHeaderView = view;
}

- (void)refreshView
{
    __weak __typeof(self) weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    currNum = 1;
    [self loadData];
    [_tableView.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    currNum ++;
    if(currNum > page){
        [_tableView reloadData];
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self loadData];
    }
}

- (void)topViewData
{
    _scrollArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *modelArr  = [NSMutableArray arrayWithCapacity:0];
    NSString *url = [newHostUrl stringByAppendingString:getMatchUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        GoodsList *goodsList = [[GoodsList alloc] initWithDic:responseObject];
        for (Goods *goods in goodsList.goodsArray) {
            [_scrollArr addObject:[NSString stringWithFormat:@"%@%@",newHostUrl,goods.goods_url]];
            [modelArr addObject:goods];
        }
        
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
        for(int i = 0;i < _scrollArr.count;i++){
            if (_scrollArr.count < 4) {
                [arr addObject:_scrollArr[i]];
            }
        }
        //添加数据
        _imgScrollView.pics = arr;
        //点击事件
        [_imgScrollView returnIndex:^(NSInteger index) {
            QDXLineDetailViewController *detailLine = [[QDXLineDetailViewController alloc] init];
            detailLine.goods = [modelArr objectAtIndex:index];
            detailLine.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailLine animated:YES];
        }];
        //刷新（必需的步骤）
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_imgScrollView reloadView];
        });

    } failure:^(NSError *error) {
        
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return FitRealValue(94) + 10;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(void)collectionViewDidSelectedItemIndexPath:(NSIndexPath *)indexPath collcetionView:(UICollectionView *)collectionView forCell:(QDXHomeTableViewCell *)cell
{
    if ( [cell.reuseIdentifier isEqualToString:@"QDXCollectionViewResuseID"]) {
        QDXActivityPriceViewController *actWithPriceVC = [[QDXActivityPriceViewController alloc] init];
        actWithPriceVC.hidesBottomBarWhenPushed = YES;
        actWithPriceVC.type = [NSString stringWithFormat:@"%d",(int)indexPath.row];
        actWithPriceVC.area = _hotAreaArr[indexPath.row];
        [self.navigationController pushViewController:actWithPriceVC animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0) {
        QDXHomeTableViewCell *cell = [QDXHomeTableViewCell qdxHomeCellWithTableView:_tableView];
        cell.areaArr = _hotAreaArr;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        return cell;
    }else{
        QDXHomeCooperationCell *cell = [QDXHomeCooperationCell qdxCooperationWithTableView:_tableView];
        cell.items =_partnerArr;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0 || section == 1) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, QdxWidth, FitRealValue(20));
        view.backgroundColor = QDXBGColor;
        UIView *view1 = [[UIView alloc] init];
        view1.frame = CGRectMake(0, 10, QdxWidth, FitRealValue(94));
        view1.backgroundColor = [UIColor whiteColor];
        [view addSubview:view1];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((QdxWidth -200)/2, FitRealValue(30), 200, FitRealValue(36))];
        if (section == 0) {
            titleLabel.text = @"最新上线";
        }else{
            titleLabel.text = @"合作单位";
            
            UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(20 + 100), FitRealValue(28), FitRealValue(110), 20)];
            [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
            moreBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [moreBtn setImage:[UIImage imageNamed:@"更多icon"] forState:UIControlStateNormal];
            [moreBtn setTitleColor:QDXGray forState:UIControlStateNormal];
            [moreBtn addTarget:self action:@selector(moreBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [moreBtn setImagePosition:1 spacing:0];
            [view1 addSubview:moreBtn];
        }
        titleLabel.textColor = QDXBlack;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:17];
        [view1 addSubview:titleLabel];
        
        UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, FitRealValue(94) + 10, QdxWidth, FitRealValue(1))];
        viewLine.backgroundColor = QDXLineColor;
        [view addSubview:viewLine];
        return view;
    }
    return nil;
}

-(void)moreBtnClick
{
    MoreCooperationViewController *moreCooperationVC = [[MoreCooperationViewController alloc] init];
    moreCooperationVC.partnerArr = _partnerArr;
    moreCooperationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:moreCooperationVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0) {
        return FitRealValue(270);
    }else {
        return FitRealValue(240);
    }
}

- (void)btnClick:(UIButton *)btn
{
    NSString *type = [NSString stringWithFormat:@"%d",(int)btn.tag];

    if ((int)btn.tag == 1) {
        PlaceViewController *placeVC = [[PlaceViewController alloc] init];
        placeVC.type = type;
        placeVC.hidesBottomBarWhenPushed = YES;
        placeVC.navTitle = btn.titleLabel.text;
        placeVC.cityArr = _cityArr;
        placeVC.cityId = _cityId;
        placeVC.cityCn = locationBtn.titleLabel.text;
        [self.navigationController pushViewController:placeVC animated:YES];
    }else{
        QDXActivityViewController *qdxActVC = [[QDXActivityViewController alloc] init];
        qdxActVC.type = type;
        qdxActVC.cityId = _cityId;
        qdxActVC.hidesBottomBarWhenPushed = YES;
        qdxActVC.navTitle = btn.titleLabel.text;
        [self.navigationController pushViewController:qdxActVC animated:YES];
    }
}

- (void)scanClick
{
    if ([save length] != 0) {
        ImagePickerController *imageVC = [[ImagePickerController alloc] initWithBlock:^(NSString *result, BOOL flag, NSString *from) {
            imageVC.from = from;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([result containsString:@"http"]) {
                    codeWebViewController *webVC = [[codeWebViewController alloc] init];
                    if ([result containsString:@"?"]) {
                        NSString *addtoken = [@"&customer_token=" stringByAppendingString:save];
                        NSString *url = [result stringByAppendingString:addtoken];
                        webVC.url = url;
                    }else{
                        NSString *addtoken = [@"?customer_token=" stringByAppendingString:save];
                        NSString *url = [result stringByAppendingString:addtoken];
                        webVC.url = url;
                    }
                    webVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:webVC animated:YES];
                }else{
                    [self netWorkingwith:result];
                }
            });
            
        }];
        imageVC.hidesBottomBarWhenPushed =YES;
        [self.navigationController pushViewController:imageVC animated:YES];
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"登陆后才可使用此功能" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"立即登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        
            QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
            QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
            regi.hidesBottomBarWhenPushed = YES;
            [self presentViewController:navController animated:YES completion:^{
        
            }];
        
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"暂不登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)netWorkingwith:(NSString *)result
{
    NSString *url = [newHostUrl stringByAppendingString:getLineListUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    params[@"ticketinfo_cn"] = result;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {

        if ([responseObject[@"Code"] intValue] == 0) {
            UIAlertController *aalert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"%@",responseObject[@"Msg"]] preferredStyle:UIAlertControllerStyleAlert];
            [aalert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
            }]];
            [self presentViewController:aalert animated:YES completion:nil];
        }else{
            LineList *lineList = [[LineList alloc] initWithDic:responseObject];
            LineController *lineVC = [[LineController alloc] init];
            QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:lineVC];
            lineVC.lineList = lineList;
            lineVC.ticketID = result;
            [self presentViewController:nav animated:YES completion:^{
                
            }];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
