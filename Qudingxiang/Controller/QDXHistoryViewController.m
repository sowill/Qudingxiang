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

#define TASKWEIGHT                         QdxWidth * 0.875
#define TASKHEIGHT                         QdxHeight * 0.73
#define SHOWTASKHEIGHT                     TASKHEIGHT * 0.1

@interface QDXHistoryViewController () <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) NSMutableArray *historyArr;

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) UIButton *showOK_button;

@property (nonatomic, strong) UIButton *showTitle_button;

@property (nonatomic, strong) UIView* deliverView;

@property (nonatomic, strong) UIView* BGView;

@property (nonatomic, retain) WKWebView* webView;

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

-(void)showMsg_buttonClickWith:(NSString *)url{
    self.BGView = [[UIView alloc] init];
    self.BGView.frame = [[UIScreen mainScreen] bounds];
    [self.view addSubview:self.BGView];
    
    self.deliverView = [[UIView alloc] init];
    self.deliverView.frame = CGRectMake(QdxWidth* 0.08,0,TASKWEIGHT/2,TASKHEIGHT/2);
    [self.view addSubview:self.deliverView];
    
    self.BGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.deliverView.frame = CGRectMake(QdxWidth/2 - TASKWEIGHT/2,(QdxHeight+64 - TASKHEIGHT)/2,TASKWEIGHT,TASKHEIGHT);
    self.deliverView.backgroundColor = [UIColor clearColor];
    self.deliverView.layer.borderWidth = 1;
    self.deliverView.layer.cornerRadius = 12;
    self.deliverView.layer.borderColor = [[UIColor clearColor]CGColor];
    
    _showOK_button = [[UIButton alloc] initWithFrame:CGRectMake(0, TASKHEIGHT - SHOWTASKHEIGHT,TASKWEIGHT, SHOWTASKHEIGHT)];
    [_showOK_button addTarget:self action:@selector(showOK_buttonClick) forControlEvents:UIControlEventTouchUpInside];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    [_showOK_button setBackgroundImage:[[UIImage imageNamed:@"任务卡－按钮"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [_showOK_button setTitle:@"好的" forState:UIControlStateNormal];
    [_showOK_button setTitleColor:[UIColor colorWithRed:0.000 green:0.600 blue:0.992 alpha:1.000] forState:UIControlStateNormal];
    [self.deliverView addSubview:_showOK_button];
    
    _showTitle_button = [[UIButton alloc] initWithFrame:CGRectMake(0,0,TASKWEIGHT, SHOWTASKHEIGHT)];
    _showTitle_button.userInteractionEnabled = NO;
    [_showTitle_button setBackgroundImage:[[UIImage imageNamed:@"任务卡－按钮上面"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [_showTitle_button setTitle:@"任务" forState:UIControlStateNormal];
    [_showTitle_button setTitleColor:[UIColor colorWithWhite:0.067 alpha:1.000] forState:UIControlStateNormal];
    _showTitle_button.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.deliverView addSubview:_showTitle_button];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.mediaPlaybackRequiresUserAction = NO;
    config.allowsInlineMediaPlayback = YES;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,SHOWTASKHEIGHT, TASKWEIGHT, TASKHEIGHT - 2 * SHOWTASKHEIGHT) configuration:config];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    WKUserContentController *userCC = config.userContentController;
    //JS调用OC 添加处理脚本
    [userCC addScriptMessageHandler:self name:@"Success"];
    
    [self.deliverView addSubview:self.webView];
}

-(void)showOK_buttonClick{
    [self.BGView removeFromSuperview];
    [self.deliverView removeFromSuperview];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QDXHistoryTableViewCell *cell = [QDXHistoryTableViewCell cellWithTableView:tableView];
    cell.HistoryInfo = _historyArr[_historyArr.count-1 - indexPath.row];
    
    cell.historyBtnBlock = ^(){
        NSString *url = [newHostUrl stringByAppendingString:[pointhistoryUrl stringByAppendingString:[NSString stringWithFormat:@"/pointmap_id/%@",cell.HistoryInfo.pointmap_id]]];
        [self showMsg_buttonClickWith:url];
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
