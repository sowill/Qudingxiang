//
//  QDXLoadViewController.m
//  Qudingxiang
//
//  Created by Air on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXLoginViewController.h"
#import "QDXRegisterViewController.h"
#import "QDXCreateCodeViewController.h"
#import "QDXForgetPasswordViewController.h"
#import "QDXIsConnect.h"
#import "TabbarController.h"
#import "QDXBindViewController.h"
#import "LoginService.h"
#import "MineViewController.h"
#import "HomeController.h"
@interface QDXLoginViewController ()<UITextFieldDelegate>
{
    UITextField *telText;
    UITextField *pwdText;
    UIButton *loginBtn;
    NSString *wxCode;
    NSString* wxAccessToken;
    NSString* wxOpenID;
    TencentOAuth *tencentOAuth;
    NSArray *permissions;
    UIButton *_OAuthWxinBtn;
    UILabel *WXLabel;
    UIButton *showPW;
    UIButton *showTel;
}

@end

@implementation QDXLoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"登录";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:telText];
    
    //添加登陆页面
    [self setupLoginView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveWechat:) name:@"WECHAT" object:nil];
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

-(void)setupLoginView
{
    [self createButtonBack];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    
    //2 添加一个手机号码输入框
    telText = [[UITextField alloc]init];
    CGFloat telTextCenterX = QdxWidth * 0.5;
    CGFloat telTextCenterY = 10 + 40/2;
    telText.center = CGPointMake(telTextCenterX, telTextCenterY);
    telText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    telText.borderStyle = UITextBorderStyleNone;
    telText.placeholder = @"请输入手机号码";
    telText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    telText.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    telText.clearButtonMode = UITextFieldViewModeNever;
    telText.keyboardType = UIKeyboardTypeNumberPad;
    telText.backgroundColor = [UIColor whiteColor];
    telText.tag = 1;
    telText.delegate = self;
    [self.view addSubview:telText];
    UIView *telLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, telTextCenterY - 40/2, 20/2, 40)];
    telLeftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:telLeftView];
    UIView *telRightView = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth - 20/2, telTextCenterY - 40/2, 20/2, 40)];
    telRightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:telRightView];
    UIView *telTextView = [[UIView alloc] initWithFrame:CGRectMake(0, telTextCenterY+25, QdxWidth, 1)];
    telTextView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [self.view addSubview:telTextView];
    showTel = [[UIButton alloc] initWithFrame:CGRectMake((QdxWidth-10-19), telTextCenterY - 19/2, 19, 19)];
    [showTel setBackgroundImage:[UIImage imageNamed:@"sign_delete"] forState:UIControlStateNormal];
    [showTel addTarget:self action:@selector(deletetel) forControlEvents:UIControlEventTouchUpInside];
    showTel.hidden = YES;
    [self.view addSubview:showTel];
    
    //4 添加一个密码输入框
    pwdText = [[UITextField alloc]init];
    CGFloat pwdTextCenterX = QdxWidth * 0.5;
    CGFloat pwdTextCenterY = telTextCenterY + 20 + 20 + 1;
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
    
    //6 添加登录按钮
    loginBtn = [[UIButton alloc] init];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    CGFloat loginBtnCenterX = QdxWidth* 0.5;
    CGFloat loginBtnCenterY = pwdTextCenterY + 20 + 1 + 35/2 + 25;
    loginBtn.center = CGPointMake(loginBtnCenterX, loginBtnCenterY);
    loginBtn.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [loginBtn setBackgroundColor:[UIColor colorWithRed:40/255.0 green:132/255.0 blue:250/255.0 alpha:1]];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    [loginBtn setBackgroundImage:[[UIImage imageNamed:@"sign_button"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    //7 立即注册
    UIButton *RegisterBtn = [[UIButton alloc] init];
    [RegisterBtn setTitle:@"立即注册" forState:UIControlStateNormal];
    CGFloat RegisterBtnCenterX = (loginBtnCenterX + (QdxWidth-20)/2) - 65/2;
    CGFloat RegisterBtnCenterY = loginBtnCenterY + 25/2 + 35/2 + 10;
    RegisterBtn.center = CGPointMake(RegisterBtnCenterX, RegisterBtnCenterY);
    RegisterBtn.bounds = CGRectMake(0, 0, 65, 25);
    [RegisterBtn setTitleColor:[UIColor colorWithRed:0.000 green:0.600 blue:0.992 alpha:1.000] forState:UIControlStateNormal];
    [RegisterBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    RegisterBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [RegisterBtn addTarget:self action:@selector(Register) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:RegisterBtn];
    
    //8 忘记密码
    UIButton *FgpwdBtn = [[UIButton alloc] init];
    [FgpwdBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    CGFloat FgpwdBtnCenterX = (loginBtnCenterX - (QdxWidth-20)/2) + 65/2;
    CGFloat FgpwdBtnCenterY = RegisterBtnCenterY;
    FgpwdBtn.center = CGPointMake(FgpwdBtnCenterX, FgpwdBtnCenterY);
    FgpwdBtn.bounds = CGRectMake(0, 0, 65, 25);
    [FgpwdBtn setTitleColor:[UIColor colorWithWhite:0.400 alpha:1.000] forState:UIControlStateNormal];
    [FgpwdBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    FgpwdBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [FgpwdBtn addTarget:self action:@selector(Fgpwd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:FgpwdBtn];
    
//    9 其他授权登录方式
    UILabel *OAuthLabel = [[UILabel alloc] init];
    CGFloat OAuthLabelCenterX = QdxWidth * 0.5;
    CGFloat OAuthLabelCenterY = QdxHeight - 230;
    OAuthLabel.center = CGPointMake(OAuthLabelCenterX, OAuthLabelCenterY);
    OAuthLabel.bounds = CGRectMake(0, 0, 70, 30);
    OAuthLabel.text = @"快捷登录";
    OAuthLabel.textAlignment = NSTextAlignmentCenter;
    OAuthLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    OAuthLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:OAuthLabel];
    UIView *OAuthLeftLabelView = [[UIView alloc] initWithFrame:CGRectMake(10, OAuthLabelCenterY, (QdxWidth-20)/2 - 70/2, 1)];
    OAuthLeftLabelView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1];
    [self.view addSubview:OAuthLeftLabelView];
    UIView *OAuthRightLabelView = [[UIView alloc] initWithFrame:CGRectMake(OAuthLabelCenterX + 70/2, OAuthLabelCenterY, (QdxWidth-20)/2 - 70/2, 1)];
    OAuthRightLabelView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1];
    [self.view addSubview:OAuthRightLabelView];
    
    _OAuthWxinBtn = [[UIButton alloc] init];
    CGFloat OAuthWxinBtnCenterX = OAuthLabelCenterX - 70/2 - 47/2 - 15;
    CGFloat OAuthWxinBtnCenterY = OAuthLabelCenterY + 35 + 60/2;
    _OAuthWxinBtn.center = CGPointMake(OAuthWxinBtnCenterX, OAuthWxinBtnCenterY);
    _OAuthWxinBtn.bounds = CGRectMake(0, 0, 47, 48);
    [_OAuthWxinBtn setBackgroundImage:[UIImage imageNamed:@"sign_weixin"] forState:UIControlStateNormal];
    [_OAuthWxinBtn addTarget:self action:@selector(OAuthWxinBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_OAuthWxinBtn];
    WXLabel = [[UILabel alloc] init];
    CGFloat WXLabelCenterX = OAuthWxinBtnCenterX+ 5;
    CGFloat WXLabelCenterY = OAuthWxinBtnCenterY + 48/2 + 5 + 30/2;
    WXLabel.center = CGPointMake(WXLabelCenterX, WXLabelCenterY);
    WXLabel.bounds = CGRectMake(0, 0, 70, 30);
    WXLabel.text = @"微信登录";
    WXLabel.font = [UIFont systemFontOfSize:15];
    WXLabel.textColor = [UIColor colorWithWhite:0.067 alpha:0.8];
    [self.view addSubview:WXLabel];
    
    UIButton *OAuthQQBtn = [[UIButton alloc] init];
    CGFloat OAuthQQBtnCenterX = OAuthLabelCenterX + 70/2 + 47/2 + 15;
    CGFloat OAuthQQBtnCenterY = OAuthWxinBtnCenterY;
    OAuthQQBtn.center = CGPointMake(OAuthQQBtnCenterX, OAuthQQBtnCenterY);
    OAuthQQBtn.bounds = CGRectMake(0, 0, 47, 48);
    [OAuthQQBtn setBackgroundImage:[UIImage imageNamed:@"sign_qq"] forState:UIControlStateNormal];
    [OAuthQQBtn addTarget:self action:@selector(OAuthQQBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:OAuthQQBtn];
    UILabel *QQLabel = [[UILabel alloc] init];
    CGFloat QQLabelCenterX = OAuthQQBtnCenterX + 5;
    CGFloat QQLabelCenterY = WXLabelCenterY;
    QQLabel.center = CGPointMake(QQLabelCenterX, QQLabelCenterY);
    QQLabel.bounds = CGRectMake(0, 0, 60, 30);
    QQLabel.text = @"QQ登录";
    QQLabel.font = [UIFont systemFontOfSize:15];
    QQLabel.textColor = [UIColor colorWithWhite:0.067 alpha:0.8];
    [self.view addSubview:QQLabel];
}

-(void)deletetel
{
    telText.text = nil;
    showTel.hidden = YES;
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

//授权登录
-(void)OAuthQQBtnClick
{
    [tencentOAuth authorize:permissions inSafari:NO];
}

#pragma mark -- TencentSessionDelegate
//登陆完成调用
- (void)tencentDidLogin
{
    [tencentOAuth getUserInfo];
}

//非网络错误导致登录失败：
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    NSLog(@"tencentDidNotLogin");
    if (cancelled)
    {
        [MBProgressHUD showError:@"用户取消登录"];
    }else{
        [MBProgressHUD showError:@"登录失败"];
    }
}
// 网络错误导致登录失败：
-(void)tencentDidNotNetWork
{
    [MBProgressHUD showError:@"无网络连接，请设置网络"];
}

-(void)getUserInfoResponse:(APIResponse *)response
{
//    NSLog(@"%@",tencentOAuth.openId);
//    NSLog(@"respons:%@",response.jsonResponse[@"nickname"]);
//    NSLog(@"respons:%@",response.jsonResponse[@"figureurl"]);
    [self QQandWXLogin];
}

-(void)OAuthWxinBtnClick

{
    
    SendAuthReq* request =[[SendAuthReq alloc]init];
    
    request.scope =@"snsapi_userinfo,snsapi_base";
    
    request.state =@"321";
    
    [WXApi sendReq:request];
    
}


-(void)didReceiveWechat:(NSNotification*)not

{
    
    NSDictionary* info =not.userInfo;
    
    wxCode =[info objectForKey:@"code"];
    NSString *urlString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWeChat_KEY,kWeChat_Secret,wxCode];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:Nil];
            NSLog(@"123%@",jsonData);
            wxAccessToken =[jsonData objectForKey:@"access_token"];
            wxOpenID =[jsonData objectForKey:@"openid"];
            [self WeiXinAccess];
            
        });
        
        
    }];
    [task resume];
    
}

- (void)WeiXinAccess
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",wxAccessToken,wxOpenID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:Nil];
            
            [self QQandWXLogin];
            
        });
        
        
    }];
    [task resume];
}

-(void)QQandWXLogin
{
    [LoginService QQandWXlog:^(NSMutableDictionary *dict) {
        QDXIsConnect *isConnect = [QDXIsConnect mj_objectWithKeyValues:dict];
        int ret = [isConnect.Code intValue];
        if (ret==1) {
//            [MBProgressHUD showSuccess:@"登录成功"];
            
            NSLog(@"%@",isConnect.Msg[@"token"]);
            
            //存储Token信息
            [NSKeyedArchiver archiveRootObject:isConnect.Msg[@"token"] toFile:XWLAccountFile];
            [self goHome];
            //切换窗口根控制器
    }
        else{
            QDXBindViewController *BindViewController =[[QDXBindViewController alloc] init];
            self.trendDelegate=BindViewController; //设置代理
            [self.trendDelegate passTrendValues:tencentOAuth.openId andWXValue:wxOpenID];
            [self.navigationController pushViewController:BindViewController animated:YES];
        }
    } andWithTXOpenID:tencentOAuth.openId andWithWXOpenID:wxOpenID];
}

//登录
-(void)login
{
    loginBtn.userInteractionEnabled = NO;
    [self.view endEditing:YES];
    
    NSString *username = telText.text;
    NSString *password = pwdText.text;
    
    [LoginService logInBlock:^(NSMutableDictionary *dict) {

        QDXIsConnect *isConnect = [QDXIsConnect mj_objectWithKeyValues:dict];
        int ret = [isConnect.Code intValue];
        if (ret==1) {
            [NSKeyedArchiver archiveRootObject:isConnect.Msg[@"token"] toFile:XWLAccountFile];
            [self goHome];
        }
        else{
            [MBProgressHUD showError:@"账号密码错误"];
            loginBtn.userInteractionEnabled = YES;
        }

    } andWithUserName:[NSString stringWithFormat:@"%@", username] andWithPassWord:[NSString stringWithFormat:@"%@",password]];
    
}

- (void)goHome
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
//注册
-(void)Register
{
    //切换窗口控制器
    QDXCreateCodeViewController *viewController = [[QDXCreateCodeViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

//忘记密码
-(void)Fgpwd
{
    //切换窗口控制器
    QDXForgetPasswordViewController *viewController = [[QDXForgetPasswordViewController alloc] init];
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0.0 + 64;
        self.view.frame = frame;
    }];
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

-(void)viewWillAppear:(BOOL)animated
{
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        _OAuthWxinBtn.hidden = YES;
        WXLabel.hidden = YES;
    }else{
        _OAuthWxinBtn.hidden = NO;
        WXLabel.hidden = NO;
    }
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
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
