//
//  QDXSlideCollectionViewCell.m
//  趣定向
//
//  Created by Air on 2016/11/25.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXSlideCollectionViewCell.h"
#import "QDXSlideTableViewCell.h"

#import "QDXIsConnect.h"
#import "HomeModel.h"
#import "QDXActTableViewCell.h"

@interface QDXSlideCollectionViewCell ()<UITableViewDelegate,UITableViewDataSource>
{
    int curr;
    int page;
    int count;
}

@property (nonatomic,strong) NSMutableArray *recentArray;

@property (nonatomic,strong) NSMutableArray *didArray;

@property (nonatomic,copy)TableViewCellClick tableViewCellClick;

@end

static NSString *QDXSlideTableCellIdentifier = @"QDXSlideTableCellIdentifier";

@implementation QDXSlideCollectionViewCell

- (NSMutableArray *)recentArray
{
    if (_recentArray == nil) {
        _recentArray = [NSMutableArray array];
    }
    return _recentArray;
}

- (NSMutableArray *)didArray
{
    if (_didArray == nil) {
        _didArray = [NSMutableArray array];
    }
    return _didArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

// 初始化上下滑动tableView
- (UITableView *)tableView{
    if (!_tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.backgroundColor = QDXBGColor;
        //    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self setupRefreshView];
        
        [self registHelperCell];
    }
    return _tableView;
}

/**
 *  集成刷新控件
 */
- (void)setupRefreshView
{
    // 1.下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
    
    // 2.上拉刷新(上拉加载更多数据)
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
    // 忽略掉底部inset
//    self.tableView.mj_footer.ignoredScrollViewContentInsetBottom = 30;
    
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    curr = 1;
    [self cellDataWith:@"1" andWithType: _type];
    
    // 刷新表格
    [self.tableView reloadData];
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    curr++;
    if(curr > page ){
        // 刷新表格
        [self.tableView reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self cellDataWith:@"1" andWithType: _type];
    }
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
            
            switch (self.flag) {
                case 0:
                    _recentArray = [[NSMutableArray alloc] init];
                    for(NSDictionary *dict in dataDict){
                        HomeModel *model = [[HomeModel alloc] init];
                        [model setValuesForKeysWithDictionary:dict];
                        [_recentArray addObject:model];
                    }
                    break;
                    
                case 1:
                    _didArray = [[NSMutableArray alloc] init];
                    for(NSDictionary *dict in dataDict){
                        HomeModel *model = [[HomeModel alloc] init];
                        [model setValuesForKeysWithDictionary:dict];
                        [_didArray addObject:model];
                    }
                    break;
                    
                default:
                    break;
            }
            
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

// 注册cell
- (void)registHelperCell{
    [self.tableView registerClass:[QDXSlideTableViewCell class] forCellReuseIdentifier:QDXSlideTableCellIdentifier];
}

// 设置子视图
- (void)setup{
    // 添加子视图
    [self.contentView addSubview:self.tableView];
}

#pragma mark - tableView的代理方法 -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (self.flag) {
        case 0:
            if (self.recentArray.count == 0) {
                return self.homeModelArray.count;
            }else{
                return self.recentArray.count;
            }
            break;
            
        case 1:
            if (self.recentArray.count == 0) {
                return self.homeModelArray.count;
            }else{
                return self.didArray.count;
            }
            break;

        default:
            return self.homeModelArray.count;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 1.创建cell
    QDXActTableViewCell *cell = [QDXActTableViewCell qdxActCellWithTableView:_tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    // 2.给cell传递模型数据
    
    switch (self.flag) {
        case 0:
            if (self.recentArray.count == 0) {
                cell.homeModel = self.homeModelArray[indexPath.row];
            }else{
                cell.homeModel = self.recentArray[indexPath.row];
            }
            break;
            
        case 1:
            if (self.recentArray.count == 0) {
                cell.homeModel = self.homeModelArray[indexPath.row];
            }else{
                cell.homeModel = self.didArray[indexPath.row];
            }
            break;
            
        default:
            cell.homeModel = self.homeModelArray[indexPath.row];
            break;
    }
    
    return cell;
}

#pragma mark - 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(556 + 20);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.tableViewCellClick) {
        switch (self.flag) {
            case 0:
                self.tableViewCellClick(self.recentArray[indexPath.row]);
                break;
                
            case 1:
                self.tableViewCellClick(self.didArray[indexPath.row]);
                break;
                
            default:
                self.tableViewCellClick(self.homeModelArray[indexPath.row]);
                break;
        }
        
    }
}

- (void)coustomTableViewCellClick:(TableViewCellClick)tableViewCellClick
{
    self.tableViewCellClick = tableViewCellClick;
}

@end
