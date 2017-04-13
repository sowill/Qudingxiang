//
//  LineController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/18.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "LineController.h"
#import "LineCell.h"
#import "LineList.h"
#import "Line.h"

@interface LineController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArr;
    UIImageView *_imageView;
    UIButton *_button;
    NSInteger _state;

    NSInteger *_row;
}
@property(nonatomic,strong)NSMutableArray * dataA;
@end

@implementation LineController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = @"路线选择";
    [self btnData];
    [self createTableView];
}

-(void)reloadData
{
    [self btnData];
}

- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight  - 64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
}


- (void)viewDidLayoutSubviews
{
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)btnData
{
    _dataArr = [NSMutableArray arrayWithCapacity:0];
    for (Line *line in _lineList.lineArray) {
        [_dataArr addObject:line];
    }
    [_tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LineCell *cell = [LineCell baseCellWithTableView:_tableView];
    cell.line = _dataArr[indexPath.row];
    cell.select = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    __weak __typeof(cell) weakSelf = cell;
    cell.quickClick = ^(){
        __strong __typeof(cell) strongSelf = weakSelf;
        strongSelf.select = 1;
        UIAlertController *aalert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要选择本条线路吗?" preferredStyle:UIAlertControllerStyleAlert];
        [aalert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
            strongSelf.select = 0;
        }]];
        [aalert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
            
            strongSelf.select = 1;
            
            NSString *url = [newHostUrl stringByAppendingString:selectMylineUrl];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"customer_token"] = save;
            params[@"line_id"] = strongSelf.line.line_id;
            params[@"ticketinfo_cn"] = _ticketID;
            [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
                int ret = [responseObject[@"Code"] intValue];
                if (ret == 1) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        if (self.LineClickBlock) {
                            self.LineClickBlock();
                        }
                    }];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@",responseObject[@"Msg"]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    [_tableView reloadData];
                }
            } failure:^(NSError *error) {
                
            }];
            
        }]];
        
        [self presentViewController:aalert animated:YES completion:nil];
        
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(130 + 20);
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
