//
//  MineCardViewController.m
//  趣定向
//
//  Created by Air on 2017/4/12.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "MineCardViewController.h"
#import "CardModel.h"
#import "CardList.h"
#import "QDXStateView.h"
#import "MineCardTableViewCell.h"

#define TASKWEIGHT                         FitRealValue(560)
#define TASKHEIGHT                         FitRealValue(480)

@interface MineCardViewController ()<UITableViewDelegate,UITableViewDataSource,StateDelegate>
{
    NSInteger currNum;
    NSInteger page;
    NSInteger count;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic, strong) QDXStateView *noThingView;
@property (nonatomic, strong) UIView* BGView; //遮罩
@property (nonatomic, strong) UIView* deliverView; //底部View
@end

@implementation MineCardViewController

-(void)reloadData
{
    [self getMyCardisRemoveAll:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [self getMyCardisRemoveAll:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的卡包";
    
    self.view.backgroundColor = QDXBGColor;
    
    [self createTableView];
}

-(void)createTableView{
    _dataArr = [NSMutableArray arrayWithCapacity:0];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight- 64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = QDXBGColor;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    [self refreshView];
}

- (void)refreshView
{
    // 1.下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    //    [_tableView.mj_header beginRefreshing];
    
    // 2.上拉刷新(上拉加载更多数据)
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    // 忽略掉底部inset
    _tableView.mj_footer.ignoredScrollViewContentInsetBottom = 30;
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    currNum = 1;
    //刷新
    [self getMyCardisRemoveAll:YES];
    // 刷新表格
    [_tableView reloadData];
    // 拿到当前的下拉刷新控件，结束刷新状态
    [_tableView.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    currNum ++;
    if(currNum > page){
        // 刷新表格
        [_tableView reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        [_tableView.mj_footer endRefreshingWithNoMoreData];
        
    }else{
        [self getMyCardisRemoveAll:NO];
    }
}

-(void)getMyCardisRemoveAll:(BOOL)isRemove
{
    NSString *url = [newHostUrl stringByAppendingString:myCardUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        
        CardList *cardList = [[CardList alloc] initWithDic:responseObject];
        currNum = [cardList.curr integerValue];
        page = [cardList.allpage integerValue];
        count = [cardList.count integerValue];
        [_noThingView removeFromSuperview];

        if (count == 0) {
            [self createSadViewWithDetail: @"还没有线路哦~"];
        }else{
            if (isRemove) {
                [_dataArr removeAllObjects];
            }
            for (CardModel *cardModel in cardList.cardArray) {
                [_dataArr addObject:cardModel];
            }
        }
        [_tableView.mj_footer endRefreshing];
        [_tableView reloadData];
        
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
        _noThingView.stateDetail.text = @"还没有卡包哦~";
    }else{
        _noThingView.stateDetail.text = detail;
    }
    [_noThingView.stateButton setTitle:@"返回上一页" forState:UIControlStateNormal];
    [self.view addSubview:_noThingView];
}

-(void)changeState
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(410);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MineCardTableViewCell *cell = [MineCardTableViewCell MineCardCellWithTableView:tableView];
    cell.cardModel = _dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak __typeof(cell) weakSelf = cell;
    cell.qrCodeBtnBlock = ^(){
        __strong __typeof(cell) strongSelf = weakSelf;
        [self setupCreateViewWithURL:strongSelf.cardModel.mycard_qrcode];
    };
    
    return cell;
}

//二维码的frame
- (void)setupCreateViewWithURL:(NSString *)url
{
    self.BGView                 = [[UIView alloc] init];
    self.BGView.frame           = [[UIScreen mainScreen] bounds];
    self.BGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BGViewClick)];
    [self.BGView addGestureRecognizer:tapGesture];
    [self.view addSubview:self.BGView];
    float codeHeight = TASKHEIGHT;
    
    self.deliverView                 = [[UIView alloc] init];
    self.deliverView.frame           = CGRectMake(QdxWidth/2 - TASKWEIGHT/2,(QdxHeight-64 - codeHeight)/2,TASKWEIGHT,codeHeight);
    self.deliverView.backgroundColor = [UIColor whiteColor];
    self.deliverView.layer.borderWidth = 1;
    self.deliverView.layer.cornerRadius = 8;
    self.deliverView.layer.borderColor = [[UIColor clearColor]CGColor];
    [self.view addSubview:self.deliverView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,FitRealValue(36), TASKWEIGHT, 20)];
    title.text = @"请扫描以下二维码验券";
    title.textColor = QDXBlack;
    title.font = [UIFont systemFontOfSize:14];
    title.textAlignment = NSTextAlignmentCenter;
    [self.deliverView addSubview:title];
    
    UIImageView *createCode = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(110), title.frame.origin.y + 20 + FitRealValue(36), FitRealValue(340), FitRealValue(340))];
    [createCode setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"加载中-1"]];
    [self.deliverView addSubview:createCode];
}

-(void)BGViewClick{
    [self.BGView removeFromSuperview];
    [self.deliverView removeFromSuperview];
    
    [self getMyCardisRemoveAll:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
