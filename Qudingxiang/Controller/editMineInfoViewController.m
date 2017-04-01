//
//  editMineInfoViewController.m
//  趣定向
//
//  Created by Air on 2017/3/22.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "editMineInfoViewController.h"
#import "UITextField+IndexPath.h"
#import "TextFieldTableViewCell.h"
#import "Customer.h"

@interface editMineInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *arrayDataSouce;

@property (nonatomic , strong)NSArray *titleArray;

@property (nonatomic, strong) UIButton *completeBtn;
@end

@implementation editMineInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"编辑资料";
    
    [self.view addSubview:self.tableView];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 10)];
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    saveBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, buttonItem];
}

-(void)saveBtnClick{
    NSString *url = [newHostUrl stringByAppendingString:modifyUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    [self.arrayDataSouce enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *string = (NSString *)obj;
        if (string.length == 0) {

        }else{
            switch (idx) {
                case 0:
                    params[@"customer_cn"] = obj;
                    break;
                case 1:
                    params[@"customer_signature"] = obj;
                    break;
                default:
                    break;
            }
        }
    }];
    
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        int ret = [responseObject[@"Code"] intValue];
        if (ret==1) {
            [MBProgressHUD showSuccess:@"修改成功"];
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
            [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
            Customer *customer = [[Customer alloc] initWithDic:responseObject[@"Msg"]];
            [NSKeyedArchiver archiveRootObject:customer.customer_token toFile:XWLAccountFile];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stateRefresh" object:nil];
        }else{
            
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)textFieldDidChanged:(NSNotification *)noti{
    
    /// 数据源赋值
    UITextField *textField=noti.object;
    NSIndexPath *indexPath = textField.indexPath;
    
    [self.arrayDataSouce replaceObjectAtIndex:indexPath.row withObject:textField.text];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = QDXBGColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBord)];
        [_tableView addGestureRecognizer:gesture];
    }
    return _tableView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"点击结束了");
}

- (void)hiddenKeyBord{
    [self.view endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Id = @"HTextViewCell";
    TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Id];
    if (!cell) {
        cell = [[TextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Id];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.row == 0) {
        cell.textField.placeholder = @"请输入昵称";
    }else{
        cell.textField.placeholder = @"请输入个性签名";
    }
    [cell setTitleString:self.titleArray[indexPath.row] andDataString:self.arrayDataSouce[indexPath.row] andIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return FitRealValue(20);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(100);
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)arrayDataSouce{
    if (!_arrayDataSouce) {
        _arrayDataSouce = [NSMutableArray array];
        [_arrayDataSouce addObject:_peopleDict.customer_cn];
        [_arrayDataSouce addObject:_peopleDict.customer_signature];
    }
    return _arrayDataSouce;
}

- (NSArray *)titleArray{
    if (!_titleArray) {
        _titleArray = @[@"昵称：", @"签名："];
    }
    return _titleArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
