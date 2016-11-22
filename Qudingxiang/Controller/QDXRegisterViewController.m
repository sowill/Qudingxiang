//
//  QDXRegisterViewController.m
//  Qudingxiang
//
//  Created by Air on 15/9/16.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXRegisterViewController.h"
//#import "TabbarController.h"
#import "QDXIsConnect.h"
#import "CheckDataTool.h"
#import "QDXLoginViewController.h"

@interface QDXRegisterViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    UITextField *telText;
    UITextField *pwdText;
    UITextField *pwdsureText;
    UITextField *customerNameText;
    UIButton *showPW;
    UIButton *showPWSure;
    UIButton *showCustom;
}
@end

@implementation QDXRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupRegisterView];
    self.navigationItem.title = @"注册";
    [self.view reloadInputViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:customerNameText];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)textChange
{
    showCustom.hidden = NO;
}

-(void)setupRegisterView
{
    self.view.backgroundColor = QDXBGColor;
    
    [self createButtonBack];
    
    //4 添加一个用户名称输入框
    customerNameText = [[UITextField alloc]init];
    CGFloat customerNameTextCenterX = QdxWidth * 0.5;
    CGFloat customerNameTextCenterY = 10 + 40/2;
    customerNameText.center = CGPointMake(customerNameTextCenterX, customerNameTextCenterY);
    customerNameText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    customerNameText.borderStyle = UITextBorderStyleNone;
    customerNameText.placeholder = @"请输入昵称";
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
    showCustom = [[UIButton alloc] initWithFrame:CGRectMake((QdxWidth-10-19), customerNameTextCenterY - 19/2, 19, 19)];
    [showCustom setBackgroundImage:[UIImage imageNamed:@"sign_delete"] forState:UIControlStateNormal];
    [showCustom addTarget:self action:@selector(deletetel_two) forControlEvents:UIControlEventTouchUpInside];
    showCustom.hidden = YES;
    [self.view addSubview:showCustom];
    
//    //2 添加一个手机号码输入框
//    telText = [[UITextField alloc]init];
//    CGFloat telTextCenterX = QdxWidth * 0.5;
//    CGFloat telTextCenterY = 10 + 40/2;
//    telText.center = CGPointMake(telTextCenterX, telTextCenterY);
//    telText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
//    telText.borderStyle = UITextBorderStyleNone;
//    telText.placeholder = @"请输入手机号码";
//    telText.font = [UIFont fontWithName:@"Arial" size:16.0f];
//    telText.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
//    telText.clearButtonMode = UITextFieldViewModeNever;
//    telText.keyboardType = UIKeyboardTypeNumberPad;
//    telText.backgroundColor = [UIColor whiteColor];
//    telText.tag = 1;
//    telText.delegate = self;
//    [self.view addSubview:telText];
//    UIView *telLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, telTextCenterY - 40/2, 20/2, 40)];
//    telLeftView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:telLeftView];
//    UIView *telRightView = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth - 20/2, telTextCenterY - 40/2, 20/2, 40)];
//    telRightView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:telRightView];
//    UIView *telTextView = [[UIView alloc] initWithFrame:CGRectMake(0, telTextCenterY+25, QdxWidth, 1)];
//    telTextView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
//    [self.view addSubview:telTextView];
    
    //4 添加一个密码输入框
    pwdText = [[UITextField alloc]init];
    CGFloat pwdTextCenterX = QdxWidth * 0.5;
    CGFloat pwdTextCenterY = customerNameTextCenterY + 20 + 20 + 1;
    pwdText.center = CGPointMake(pwdTextCenterX, pwdTextCenterY);
    pwdText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    pwdText.borderStyle = UITextBorderStyleNone;
    pwdText.placeholder = @"请输入密码";
    pwdText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    pwdText.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    pwdText.clearButtonMode = UITextFieldViewModeNever;
    pwdText.keyboardType = UIKeyboardTypeDefault;
    pwdText.secureTextEntry = YES;
    pwdText.backgroundColor = [UIColor whiteColor];
    pwdText.tag = 2;
    pwdText.delegate = self;
    [self.view addSubview:pwdText];
    UIView *pwdLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, pwdTextCenterY - 40/2, 20/2, 40)];
    pwdLeftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdLeftView];
    UIView *pwdRightView = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth - 20/2, pwdTextCenterY - 40/2, 20/2, 40)];
    pwdRightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdRightView];
    UIView *pwdTextView = [[UIView alloc] initWithFrame:CGRectMake(0, pwdTextCenterY+20, QdxWidth, 1)];
    pwdTextView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [self.view addSubview:pwdTextView];
    showPW = [[UIButton alloc] initWithFrame:CGRectMake((QdxWidth-10-20), pwdTextCenterY - 12/2, 20, 12)];
    [showPW setBackgroundImage:[UIImage imageNamed:@"sign_hide"] forState:UIControlStateNormal];
    [showPW addTarget:self action:@selector(hide_show:) forControlEvents:UIControlEventTouchUpInside];
    showPW.selected = NO;
    [self.view addSubview:showPW];

    //4 添加一个确认密码输入框
    pwdsureText = [[UITextField alloc]init];
    CGFloat pwdsureTextCenterX = pwdTextCenterX;
    CGFloat pwdsureTextCenterY = pwdTextCenterY + 20 + 20 + 1;
    pwdsureText.center = CGPointMake(pwdsureTextCenterX, pwdsureTextCenterY);
    pwdsureText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    pwdsureText.borderStyle = UITextBorderStyleNone;
    pwdsureText.placeholder = @"请确认密码";
    pwdsureText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    pwdsureText.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    pwdsureText.clearButtonMode = UITextFieldViewModeNever;
    pwdsureText.keyboardType = UIKeyboardTypeDefault;
    pwdsureText.secureTextEntry = YES;
    pwdsureText.backgroundColor = [UIColor whiteColor];
    pwdsureText.tag = 3;
    pwdsureText.delegate = self;
    [self.view addSubview: pwdsureText];
    UIView *pwdsureLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, pwdsureTextCenterY - 40/2, 20/2, 40)];
    pwdsureLeftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdsureLeftView];
    UIView *pwdsureRightView = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth - 20/2, pwdsureTextCenterY - 40/2, 20/2, 40)];
    pwdsureRightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdsureRightView];
    UIView *pwdsureTextView = [[UIView alloc] initWithFrame:CGRectMake(0, pwdsureTextCenterY+20, QdxWidth, 1)];
    pwdsureTextView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [self.view addSubview:pwdsureTextView];
    showPWSure = [[UIButton alloc] initWithFrame:CGRectMake((QdxWidth-10-20), pwdsureTextCenterY - 12/2, 20, 12)];
    [showPWSure setBackgroundImage:[UIImage imageNamed:@"sign_hide"] forState:UIControlStateNormal];
    [showPWSure addTarget:self action:@selector(hide_show_two:) forControlEvents:UIControlEventTouchUpInside];
    showPWSure.selected = NO;
    [self.view addSubview:showPWSure];
    
    //6 添加提交按钮
    UIButton *commitBtn = [[UIButton alloc] init];
    [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    CGFloat commitBtnCenterX = QdxWidth * 0.5;
    CGFloat commitBtnCenterY = pwdsureTextCenterY + 20 + 1 + 35/2 + 25;
    commitBtn.center = CGPointMake(commitBtnCenterX, commitBtnCenterY);
    commitBtn.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    [commitBtn setBackgroundImage:[[UIImage imageNamed:@"sign_button"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [commitBtn addTarget:self action:@selector(commitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commitBtn];
}

// 返回按钮
-(void)createButtonBack
{
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonBack.frame = CGRectMake(0, 0, 20, 18);
    [buttonBack addTarget:self action:@selector(buttonBackSetting) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setTitle:nil forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"sign_return"] forState:UIControlStateNormal];
    buttonBack.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

-(void)buttonBackSetting
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)deletetel_two
{
    customerNameText.text = nil;
    showCustom.hidden = YES;
}

-(void)hide_show:(UIButton *)show
{
    showPW.selected = !showPW.isSelected;
    if (showPW.isSelected) {
        pwdText.secureTextEntry = NO;
    }else{
        pwdText.secureTextEntry = YES;
    }
}

-(void)hide_show_two:(UIButton *)show
{
    showPWSure.selected = !showPWSure.isSelected;
    if (showPWSure.isSelected) {
        pwdsureText.secureTextEntry = NO;
    }else{
        pwdsureText.secureTextEntry = YES;
    }
}

-(void)backBtnClick
{
    //切换窗口根控制器
    QDXLoginViewController *viewController = [[QDXLoginViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
        CGFloat offset = QdxHeight - (textField.frame.origin.y + textField.frame.size.height +216 + 150);
        if (offset <= 0) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = self.view.frame;
                frame.origin.y = offset;
                self.view.frame = frame;
            }];
        }
    return YES;
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0.0 + 64;
        self.view.frame = frame;
    }];
    
    [self.view endEditing:YES];
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0.0 + 64;
        self.view.frame = frame;
    }];
    return YES;
}

-(void)commitBtnClick
{
    [self.view endEditing:YES];
    
    NSString *username = self.firstVaule;
    NSString *password = pwdText.text;
    NSString *passwordsure = pwdsureText.text;
    NSString *customername = customerNameText.text;
    
    if (![password isEqualToString:passwordsure]) {
        [MBProgressHUD showError:@"密码不一致"];
        return;
    }else if(![CheckDataTool checkForPasswordWithShortest:6 longest:16 password:pwdText.text]){
        [MBProgressHUD showError:@"密码在6到16位之间"];
        return;
    }
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"code"] = [NSString stringWithFormat:@"%@", username];
    params[@"password"] = [NSString stringWithFormat:@"%@", password];
    params[@"customer_name"] = [NSString stringWithFormat:@"%@", customername];
    NSString *url = [hostUrl stringByAppendingString:@"Home/Customer/register"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        QDXIsConnect *isConnect = [QDXIsConnect mj_objectWithKeyValues:dict];
        int ret = [isConnect.Code intValue];
        if (ret==1) {
            [MBProgressHUD showSuccess:@"注册成功"];
            //存储Token信息
            [NSKeyedArchiver archiveRootObject:isConnect.Msg[@"token"] toFile:XWLAccountFile];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        else{
            NSString *showerror = [infoDict objectForKey:@"Msg"];
            [MBProgressHUD showError:showerror];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
