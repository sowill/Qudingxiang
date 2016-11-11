//
//  QDXChangePwdViewController.m
//  Qudingxiang
//
//  Created by Air on 15/9/18.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXChangePwdViewController.h"
#import "TabbarController.h"
#import "QDXIsConnect.h"
#import "CheckDataTool.h"

@interface QDXChangePwdViewController ()<UITextFieldDelegate>
{

    UITextField *pwdText;
    UITextField *pwdsureText;
    UIButton *showPW;
    UIButton *showPWSure;
}
@end

@implementation QDXChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupChangePwd];
    [self createButtonBack];
    self.navigationItem.title = @"修改密码";
}

-(void)setupChangePwd
{
    self.view.backgroundColor = QDXBGColor;
    
    //4 添加一个密码输入框
    pwdText = [[UITextField alloc]init];
    CGFloat pwdTextCenterX = QdxWidth * 0.5;
    CGFloat pwdTextCenterY = 10 + 40/2;
    pwdText.center = CGPointMake(pwdTextCenterX, pwdTextCenterY);
    pwdText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    pwdText.borderStyle = UITextBorderStyleNone;
    pwdText.placeholder = @"请输入密码";
    pwdText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    pwdText.textColor = QDXGray;
    pwdText.clearButtonMode = UITextFieldViewModeNever;
    pwdText.keyboardType = UIKeyboardTypeDefault;
    pwdText.secureTextEntry = YES;
    pwdText.tag = 2;
    pwdText.backgroundColor = [UIColor whiteColor];
    pwdText.delegate = self;
    [self.view addSubview:pwdText];
    UIView *pwdLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, pwdTextCenterY - 40/2, 20/2, 40)];
    pwdLeftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdLeftView];
    UIView *pwdRightView = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth - 20/2, pwdTextCenterY - 40/2, 20/2, 40)];
    pwdRightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdRightView];
    UIView *pwdTextView = [[UIView alloc] initWithFrame:CGRectMake(0, pwdTextCenterY+25, QdxWidth, 1)];
    pwdTextView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [self.view addSubview:pwdTextView];
    showPW = [[UIButton alloc] initWithFrame:CGRectMake((QdxWidth-10-20), pwdTextCenterY - 12/2, 20, 12)];
    [showPW setBackgroundImage:[UIImage imageNamed:@"sign_hide"] forState:UIControlStateNormal];
    [showPW addTarget:self action:@selector(hide_show:) forControlEvents:UIControlEventTouchUpInside];
    showPW.selected = NO;
    [self.view addSubview:showPW];
    
    //添加一个label
//    UILabel *info = [[UILabel alloc] init];
//    CGFloat infoCenterX = QdxWidth * 0.4;
//    CGFloat infoCenterY = QdxHeight * 0.25;
//    info.center = CGPointMake(infoCenterX, infoCenterY);
//    info.bounds = CGRectMake(0, 0, 240, 20);
//    info.text = @"密码由6-20位英文字母，数字或符号组成";
//    info.textColor = [UIColor grayColor];
//    info.font = [UIFont fontWithName:@"Arial" size:13];
//    [bkImg addSubview:info];
    
    //4 添加一个确认密码输入框
    pwdsureText = [[UITextField alloc]init];
    CGFloat pwdsureTextCenterX = pwdTextCenterX;
    CGFloat pwdsureTextCenterY = pwdTextCenterY + 20 + 20 + 1;
    pwdsureText.center = CGPointMake(pwdsureTextCenterX, pwdsureTextCenterY);
    pwdsureText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    pwdsureText.borderStyle = UITextBorderStyleNone;
    pwdsureText.placeholder = @"请确认密码";
    pwdsureText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    pwdsureText.textColor = QDXGray;
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
    UIButton *loginBtn = [[UIButton alloc] init];
    [loginBtn setTitle:@"完成" forState:UIControlStateNormal];
    CGFloat loginBtnCenterX = QdxWidth* 0.5;
    CGFloat loginBtnCenterY = pwdsureTextCenterY + 20 + 1 + 35/2 + 25;
    loginBtn.center = CGPointMake(loginBtnCenterX, loginBtnCenterY);
    loginBtn.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitleColor:QDXGray forState:UIControlStateHighlighted];
    //    [loginBtn setBackgroundColor:[UIColor colorWithRed:40/255.0 green:132/255.0 blue:250/255.0 alpha:1]];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    [loginBtn setBackgroundImage:[[UIImage imageNamed:@"sign_button"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(commitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
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

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)commitBtnClick
{
    [self.view endEditing:YES];
    
    NSString *password = pwdText.text;
    NSString *passwordsure = pwdsureText.text;
    
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
    params[@"password"] = [NSString stringWithFormat:@"%@", password];
    params[@"TokenKey"] = save;
    NSString *url = [hostUrl stringByAppendingString:@"Home/Customer/modify"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        QDXIsConnect *isConnect = [QDXIsConnect mj_objectWithKeyValues:dict];
        int ret = [isConnect.Code intValue];
        if (ret==1) {
            [self showProgessMsg:@"修改中"];
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
            [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
            [NSKeyedArchiver archiveRootObject:isConnect.Msg[@"token"] toFile:XWLAccountFile];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 2.0s后执行block里面的代码
                [self hideProgess];
//                //切换窗口控制器
//                [self.sideMenuViewController setContentViewController:[[TabbarController alloc] init]
//                                                             animated:YES];
//                [self.sideMenuViewController hideMenuViewController];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            });
        }
        else{
            //            NSString *showerror = [infoDict objectForKey:@"Msg"];
            //            [MBProgressHUD showError:showerror];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

// 返回按钮
-(void)createButtonBack
{
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonBack.frame = CGRectMake(0, 0, 18, 14);
    [buttonBack addTarget:self action:@selector(buttonBackSetting) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setTitle:nil forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"sign_return"] forState:UIControlStateNormal];
    buttonBack.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

-(void)buttonBackSetting
{
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
