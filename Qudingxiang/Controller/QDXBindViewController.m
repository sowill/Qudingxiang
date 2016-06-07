//
//  QDXBindViewController.m
//  趣定向
//
//  Created by Air on 15/12/29.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "QDXBindViewController.h"
#import "TabbarController.h"
#import "QDXIsConnect.h"
#import "QDXCreateCodeViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>

@interface QDXBindViewController ()<UITextFieldDelegate>
{
    UITextField *customerNameText;
    NSString *qqOpenid;
    NSString *wxOpenid;
    TencentOAuth *tencentOAuth;
    NSArray *permissions;
//    NSString *wxCode;
//    NSString* wxAccessToken;
//    NSString* wxOpenID;
    UITextField *passwordText;
    UIButton *showPW;
    UIButton *showTel;
}
@end

@implementation QDXBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupBind];
    
    self.navigationItem.title = @"绑定手机";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIControlStateNormal target:self action:@selector(registerClick)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:customerNameText];
    
    tencentOAuth=[[TencentOAuth alloc]initWithAppId:@"1104830915" andDelegate:self];
    
    permissions= [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo", @"add_t", nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)textChange
{
    showTel.hidden = NO;
}

-(void)registerClick
{
    QDXCreateCodeViewController *viewController = [[QDXCreateCodeViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark 实现传值协议方法
-(void)passTrendValues:(NSString *)values andWXValue:(NSString *)WXValues{
    qqOpenid = values;
    wxOpenid = WXValues;
}

-(void)QQandWXLogin
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"qid"] = qqOpenid;
    params[@"wxid"] = wxOpenid;
    NSString *url = [hostUrl stringByAppendingString:@"Home/Customer/qvlogin"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        QDXIsConnect *isConnect = [QDXIsConnect mj_objectWithKeyValues:dict];
        int ret = [isConnect.Code intValue];
        if (ret==1) {
            [MBProgressHUD showSuccess:@"登录成功"];
            //存储Token信息
            [NSKeyedArchiver archiveRootObject:isConnect.Msg[@"token"] toFile:XWLAccountFile];
            //切换窗口根控制器
            [UIApplication sharedApplication].keyWindow.rootViewController = [[TabbarController alloc] init];
        }
        else{
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showError:@"登录失败"];
    }];
}


-(void)setupBind
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    
    //4 添加一个用户名称输入框
    customerNameText = [[UITextField alloc]init];
    CGFloat customerNameTextCenterX = QdxWidth * 0.5;
    CGFloat customerNameTextCenterY = 10 + 40/2;
    customerNameText.center = CGPointMake(customerNameTextCenterX, customerNameTextCenterY);
    customerNameText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    customerNameText.borderStyle = UITextBorderStyleNone;
    customerNameText.placeholder = @"请输入手机号";
    customerNameText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    customerNameText.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    customerNameText.clearButtonMode = UITextFieldViewModeNever;
    customerNameText.keyboardType = UIKeyboardTypeDefault;
    customerNameText.backgroundColor = [UIColor whiteColor];
    customerNameText.tag = 1;
    customerNameText.delegate = self;
    [self.view addSubview:customerNameText];
    UIView *customerNameLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, customerNameTextCenterY - 40/2, 20/2, 40)];
    customerNameLeftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:customerNameLeftView];
    UIView *customerNameRightView = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth - 20/2, customerNameTextCenterY - 40/2, 20/2, 40)];
    customerNameRightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:customerNameRightView];
    UIView *customerNameTextView = [[UIView alloc] initWithFrame:CGRectMake(0, customerNameTextCenterY+20, QdxWidth, 1)];
    customerNameTextView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [self.view addSubview:customerNameTextView];
    showTel = [[UIButton alloc] initWithFrame:CGRectMake((QdxWidth-10-19), customerNameTextCenterY - 19/2, 19, 19)];
    [showTel setBackgroundImage:[UIImage imageNamed:@"sign_delete"] forState:UIControlStateNormal];
    [showTel addTarget:self action:@selector(deletetel) forControlEvents:UIControlEventTouchUpInside];
    showTel.hidden = YES;
    [self.view addSubview:showTel];
    
    passwordText = [[UITextField alloc] init];
    CGFloat passwordTextCenterX = QdxWidth * 0.5;
    CGFloat passwordTextCenterY = customerNameTextCenterY + 20 + 20 + 1;
    passwordText.center = CGPointMake(passwordTextCenterX, passwordTextCenterY);
    passwordText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    passwordText.borderStyle = UITextBorderStyleNone;
    passwordText.placeholder = @"请输入密码";
    passwordText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    passwordText.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    passwordText.clearButtonMode = UITextFieldViewModeNever;
    passwordText.secureTextEntry = YES;
    passwordText.backgroundColor = [UIColor whiteColor];
    passwordText.keyboardType = UIKeyboardTypeDefault;
    passwordText.tag = 1;
    passwordText.delegate = self;
    [self.view addSubview:passwordText];
    UIView *passwordLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, passwordTextCenterY - 40/2, 20/2, 40)];
    passwordLeftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:passwordLeftView];
    UIView *passwordRightView = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth - 20/2, passwordTextCenterY - 40/2, 20/2, 40)];
    passwordRightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:passwordRightView];
    UIView *passwordTextView = [[UIView alloc] initWithFrame:CGRectMake(0, passwordTextCenterY+20, QdxWidth, 1)];
    passwordTextView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [self.view addSubview:passwordTextView];
    showPW = [[UIButton alloc] initWithFrame:CGRectMake((QdxWidth-10-20), passwordTextCenterY - 12/2, 20, 12)];
    [showPW setBackgroundImage:[UIImage imageNamed:@"sign_hide"] forState:UIControlStateNormal];
    [showPW addTarget:self action:@selector(hide_show:) forControlEvents:UIControlEventTouchUpInside];
    showPW.selected = NO;
    [self.view addSubview:showPW];
    
    //6 添加提交按钮
    UIButton *commitBtn = [[UIButton alloc] init];
    [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    CGFloat commitBtnCenterX = QdxWidth * 0.5;
    CGFloat commitBtnCenterY = passwordTextCenterY + 20 + 1 + 35/2 + 25;
    commitBtn.center = CGPointMake(commitBtnCenterX, commitBtnCenterY);
    commitBtn.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    [commitBtn setBackgroundImage:[[UIImage imageNamed:@"sign_button"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [commitBtn addTarget:self action:@selector(commitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commitBtn];
}

-(void)hide_show:(UIButton *)show
{
    showPW.selected = !showPW.isSelected;
    if (showPW.isSelected) {
        passwordText.secureTextEntry = NO;
    }else{
        passwordText.secureTextEntry = YES;
    }
}

-(void)deletetel
{
    customerNameText.text = nil;
    showTel.hidden = YES;
}

-(void)commitBtnClick
{
    [self.view endEditing:YES];
    
    NSString *customername = customerNameText.text;
    NSString *password = passwordText.text;

    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"qid"] = qqOpenid;
    params[@"wxid"] = wxOpenid;
    params[@"code"] = [NSString stringWithFormat:@"%@", customername];
    params[@"password"] = [NSString stringWithFormat:@"%@",password];
    NSString *url = [hostUrl stringByAppendingString:@"Home/Customer/bind"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        QDXIsConnect *isConnect = [QDXIsConnect mj_objectWithKeyValues:dict];
        int ret = [isConnect.Code intValue];
        if (ret==1) {
            [MBProgressHUD showSuccess:@"绑定成功"];
            [self QQandWXLogin];
        }
        else{
            [MBProgressHUD showError:@"绑定失败"];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    CGFloat offset = QdxHeight - (textField.frame.origin.y + textField.frame.size.height +216 + 120);
    if (offset <= 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = offset;
            self.view.frame = frame;
        }];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 64;
        self.view.frame = frame;
    }];
    return YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 64;
        self.view.frame = frame;
    }];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
