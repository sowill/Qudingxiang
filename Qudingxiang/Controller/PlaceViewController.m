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

#import "QDXStateView.h"
#import "UIButton+ImageText.h"
#import "City.h"
#import "AreaList.h"
#import "Area.h"

@interface PlaceViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,ChoseCityDelegate,CLLocationManagerDelegate,StateDelegate>
{
    UIButton *locationBtn;
    int curr;
    int page;
    int count;
}
@property (nonatomic, strong) NSMutableArray *actArray;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) CLLocationManager* locationManager;

@property (nonatomic, strong) QDXStateView *noThingView;

@end

static NSString *placeReuseID = @"placeReuseID";

@implementation PlaceViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    curr = 1;
    [self getAreaisRemoveAll:YES];
}

-(void)reloadData{
    [self getAreaisRemoveAll:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = _navTitle;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [locationBtn setTitle:_cityCn forState:UIControlStateNormal];
    locationBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [locationBtn setImage:[UIImage imageNamed:@"下拉icon"] forState:UIControlStateNormal];
    [locationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [locationBtn setImagePosition:1 spacing:0];
    [locationBtn addTarget:self action:@selector(locationClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:locationBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, buttonItem];
    
    [self createCollectionView];
}

-(void)getAreaisRemoveAll:(BOOL)isRemoveAll
{
    NSString *url = [newHostUrl stringByAppendingString:getAreaUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"city_id"] = _cityId;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        AreaList *areaList = [[AreaList alloc] initWithDic:responseObject];
        curr = [areaList.curr intValue];
        count = [areaList.count intValue];
        page = [areaList.allpage intValue];
        
        [_noThingView removeFromSuperview];
        if (count == 0) {
            [self createSadViewWithDetail: @"该城市目前还没有场地哦~"];
        }else{
            if (isRemoveAll) {
                [_actArray removeAllObjects];
            }
            for (Area *area in areaList.areaArray) {
                [_actArray addObject:area];
            }
        }
        [self.collectionView.mj_footer endRefreshing];
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)createSadViewWithDetail :(NSString *)detail
{
    _noThingView = [[QDXStateView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - 49)];
    _noThingView.tag = 2;
    _noThingView.delegate = self;
    _noThingView.stateImg.image = [UIImage imageNamed:@"order_nothing"];
    if ([detail length] == 0) {
        _noThingView.stateDetail.text = @"该城市目前还没有场地哦~";
    }else{
        _noThingView.stateDetail.text = detail;
    }
    [_noThingView.stateButton setTitle:@"切换城市" forState:UIControlStateNormal];
    [self.view addSubview:_noThingView];
}

-(void)changeState
{
    [self locationClick];
}

-(void)choseCityPassValue:(City *)city
{
    [locationBtn setTitle:city.city_cn forState:UIControlStateNormal];
    _cityId = city.city_id;
    [self getAreaisRemoveAll:NO];
}

-(void)locationClick
{
    LocationChoiceViewController *cityVC=[[LocationChoiceViewController alloc]init];
    cityVC.delegate = self;
    cityVC.items = self.cityArr;
    cityVC.location = locationBtn.titleLabel.text;
    [self.navigationController pushViewController:cityVC animated:YES];
}

-(void)createCollectionView
{
    _actArray = [NSMutableArray arrayWithCapacity:0];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(FitRealValue(346), FitRealValue(460 + 20));
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = FitRealValue(9);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(FitRealValue(20), 0, QdxWidth - FitRealValue(40), QdxHeight - 64) collectionViewLayout:layout];
    self.collectionView.backgroundColor = QDXBGColor;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self setupRefreshView];
    
    [self.collectionView registerClass:[PlaceCollectionViewCell class] forCellWithReuseIdentifier:placeReuseID];
    [self.view addSubview:self.collectionView];
}

/**
 *  集成刷新控件
 */
- (void)setupRefreshView
{
    // 1.下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    //    [self.tableView.mj_header beginRefreshing];
    
    // 2.上拉刷新(上拉加载更多数据)
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    // 忽略掉底部inset
    //    self.tableView.mj_footer.ignoredScrollViewContentInsetBottom = 30;
    
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    curr = 1;
    [self getAreaisRemoveAll:YES];
    
    // 刷新表格
    [self.collectionView reloadData];
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.collectionView.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    curr++;
    if(curr > page ){
        // 刷新表格
        [self.collectionView reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        
        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self getAreaisRemoveAll:NO];
    }
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
    cell.area = self.actArray[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QDXActivityPriceViewController *actWithPriceVC = [[QDXActivityPriceViewController alloc] init];
    actWithPriceVC.hidesBottomBarWhenPushed = YES;
    actWithPriceVC.type = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    actWithPriceVC.area = self.actArray[indexPath.row];
    [self.navigationController pushViewController:actWithPriceVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
