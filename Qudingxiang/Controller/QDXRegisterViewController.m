//
//  QDXRegisterViewController.m
//  Qudingxiang
//
//  Created by Air on 15/9/16.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXRegisterViewController.h"
//#import "TabbarController.h"
#import "Customer.h"

#import "CheckDataTool.h"
#import "QDXLoginViewController.h"

@interface QDXRegisterViewController ()<UITextFieldDelegate>
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
    
    NSString *url = [newHostUrl stringByAppendingString:registerUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_cn"] = [NSString stringWithFormat:@"%@", customername];
    params[@"customer_code"] = [NSString stringWithFormat:@"%@", username];
    params[@"customer_pwd"] = [NSString stringWithFormat:@"%@", password];
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        
        int ret = [responseObject[@"Code"] intValue];
        if (ret==1) {
            [MBProgressHUD showSuccess:@"注册成功"];
            Customer *customer = [[Customer alloc] initWithDic:responseObject[@"Msg"]];
            [NSKeyedArchiver archiveRootObject:customer.customer_token toFile:XWLAccountFile];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }else{
            NSString *showerror = responseObject[@"Msg"];
            [MBProgressHUD showError:showerror];
        }
        
    } failure:^(NSError *error) {
        
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
