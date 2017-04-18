//
//  QDXHistoryViewController.m
//  趣定向
//
//  Created by Air on 16/5/4.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXHistoryViewController.h"
#import "QDXHistoryTableViewCell.h"
#import "CustomAnimateTransitionPop.h"
#import "HistoryList.h"
#import "HistoryModel.h"
#import <WebKit/WebKit.h>

#import "QDXHIstoryModel.h"
#import "QDXGameModel.h"
#import "QDXPointModel.h"

#import "QDXPopView.h"

@interface QDXHistoryViewController () <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *historyArr;

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, retain) WKWebView* webView;

@property (nonatomic, strong) QDXPopView *popView;

@end

@implementation QDXHistoryViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"定向足迹";
    [self createTableView];
    [self getHistory];
}

-(void)getHistory{
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
        [_tableview reloadData];
    } failure:^(NSError *error) {
        
    }];

}

-(void)createTableView
{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,10 + 64, QdxWidth, QdxHeight-64-10) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.rowHeight = 73;
    self.tableview.backgroundColor = QDXBGColor;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableview];
}

-(void)showOK_buttonClick{
    [self.popView dismiss];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyArr.count;
}

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
        self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(FitRealValue(20),FitRealValue(220), FitRealValue(710), FitRealValue(1074) - FitRealValue(2 * 90)) configuration:config];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        
        [self.popView addSubview:self.webView];
        
        [self.popView show];
        
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 40)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, QdxWidth *  0.7 , 20)];
    header.text = @"定向足迹";
    header.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
    header.font = [UIFont fontWithName:@"Arial" size:15];
    [headerView addSubview:header];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40 -1, QdxWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [headerView addSubview:lineView];
    return headerView;
}

#pragma mark - 视图将要显示
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.delegate=self;
}

//用来自定义转场动画
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPop) {
        CustomAnimateTransitionPop *pingInvert = [CustomAnimateTransitionPop new];
        return pingInvert;
    }else{
        return nil;
    }
}

- (void)dealloc{
//    NSLog(@"%s",__func__);
}

@end
