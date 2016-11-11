//
//  QDXForgetPasswordViewController.m
//  Qudingxiang
//
//  Created by Air on 15/9/18.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXForgetPasswordViewController.h"
#import "QDXIsConnect.h"
#import "QDXLoginViewController.h"
#import "QDXChangePwdViewController.h"
#import "CheckDataTool.h"

@interface QDXForgetPasswordViewController ()<UITextFieldDelegate>
{
    UITextField *telText;
    UITextField *vcodeText;
    UILabel *timeLabel;
    UIButton *getCodeBtn;
    UIButton *showTel;
}
@end

@implementation QDXForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupFgpwd];
    
    self.navigationItem.title = @"获取验证码";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:telText];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)textChange
{
    showTel.hidden = NO;
}

-(void)setupFgpwd
{
    self.view.backgroundColor = QDXBGColor;
    
    //2 添加一个手机号码输入框
    telText = [[UITextField alloc]init];
    CGFloat telTextCenterX = QdxWidth * 0.5;
    CGFloat telTextCenterY = 10 + 40/2;
    telText.center = CGPointMake(telTextCenterX, telTextCenterY);
    telText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    telText.borderStyle = UITextBorderStyleNone;
    telText.placeholder = @"请输入手机号码";
    telText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    telText.textColor = QDXGray;
    telText.clearButtonMode = UITextFieldViewModeNever;
    telText.keyboardType = UIKeyboardTypeNumberPad;
    telText.backgroundColor = [UIColor whiteColor];
    telText.tag = 1;
    telText.delegate = self;
    //    [telText becomeFirstResponder];
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
    
    vcodeText = [[UITextField alloc]init];
    CGFloat vcodeTextCenterX = QdxWidth * 0.5;
    CGFloat vcodeTextCenterY = telTextCenterY + 20 + 20 + 1;
    vcodeText.center = CGPointMake(vcodeTextCenterX, vcodeTextCenterY);
    vcodeText.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    vcodeText.borderStyle = UITextBorderStyleNone;
    vcodeText.placeholder = @"请输入短信验证码";
    vcodeText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    vcodeText.textColor = QDXGray;
    vcodeText.clearButtonMode = UITextFieldViewModeNever;
    vcodeText.keyboardType = UIKeyboardTypeNumberPad;
    vcodeText.backgroundColor = [UIColor whiteColor];
    vcodeText.tag = 2;
    vcodeText.delegate = self;
    [self.view addSubview:vcodeText];
    UIView *vcodeLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, vcodeTextCenterY - 40/2, 20/2, 40)];
    vcodeLeftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:vcodeLeftView];
    UIView *vcodeRightView = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth - 20/2, vcodeTextCenterY - 40/2, 20/2, 40)];
    vcodeRightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:vcodeRightView];
    UIView *vcodeTextView = [[UIView alloc] initWithFrame:CGRectMake(0, vcodeTextCenterY+20, QdxWidth, 1)];
    vcodeTextView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [self.view addSubview:vcodeTextView];
    
    //3 添加一个获取验证码按钮
    getCodeBtn = [[UIButton alloc] init];
    CGFloat getCodeBtnCenterX = QdxWidth-10 - 90/2;
    CGFloat getCodeBtnCenterY = vcodeTextCenterY;
    getCodeBtn.center = CGPointMake(getCodeBtnCenterX, getCodeBtnCenterY);
    getCodeBtn.bounds = CGRectMake(0, 0, 90, 40);
    [getCodeBtn addTarget:self action:@selector(getCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getCodeBtn];
    
    timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 90, 40)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont systemFontOfSize:17];
    timeLabel.textColor = QDXBlack;
    timeLabel.text = @"获取验证码";
    [getCodeBtn addSubview:timeLabel];
    
    //3 添加一个登录按钮
    UIButton *loginBtn = [[UIButton alloc] init];
    [loginBtn setTitle:@"下一步" forState:UIControlStateNormal];
    CGFloat loginBtnCenterX = QdxWidth* 0.5;
    CGFloat loginBtnCenterY = getCodeBtnCenterY + 20 + 1 + 35/2 + 25;
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
    [loginBtn addTarget:self action:@selector(LoginBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
}

-(void)deletetel
{
    telText.text = nil;
    showTel.hidden = YES;
}

-(void)getCodeBtnClick
{
    NSString *username = telText.text;
    
    [self performSelector:@selector(reflashGetKeyBt:) withObject:[NSNumber numberWithInt:60] afterDelay:0];
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"code"] = [NSString stringWithFormat:@"%@", username];
    NSString *url = [hostUrl stringByAppendingString:@"Home/Customer/getVcode"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        QDXIsConnect *isConnect = [QDXIsConnect mj_objectWithKeyValues:dict];
        int ret = [isConnect.Code intValue];
        if (ret==1) {
            [MBProgressHUD showSuccess:@"请输入验证码"];
        }
        else{
            NSString *showerror = [infoDict objectForKey:@"Msg"];
            [MBProgressHUD showError:showerror];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)reflashGetKeyBt:(NSNumber *)second{
    if ([second integerValue] == 0)
    {
        
        getCodeBtn.enabled=YES;
        timeLabel.text = @"点击获取验证码";
    }
    else
    {
        getCodeBtn.enabled=NO;
        int i = [second intValue];
        timeLabel.text=[NSString stringWithFormat:@"%i秒后重发",i];
        [self performSelector:@selector(reflashGetKeyBt:) withObject:[NSNumber numberWithInt:i-1] afterDelay:1];
    }
}

-(void)LoginBtnClick
{
    NSString *username = telText.text;
    NSString *getcode = vcodeText.text;
    
    if(![CheckDataTool checkForMobilePhoneNo:username]){
        [MBProgressHUD showError:@"请输入正确的手机号"];
        return;
    }

    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"code"] = [NSString stringWithFormat:@"%@", username];
    params[@"vcode"] = [NSString stringWithFormat:@"%@", getcode];
    NSString *url = [hostUrl stringByAppendingString:@"Home/Customer/vcodeLogin"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        //将字典转模型
        QDXIsConnect *isConnect = [QDXIsConnect mj_objectWithKeyValues:dict];
        
        int ret = [isConnect.Code intValue];
        if (ret==1) {
            //存储Token信息
            [NSKeyedArchiver archiveRootObject:isConnect.Msg[@"token"] toFile:XWLAccountFile];
            
            //切换窗口根控制器
            QDXChangePwdViewController *viewController = [[QDXChangePwdViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else{
            NSString *showerror = [infoDict objectForKey:@"Msg"];
            [MBProgressHUD showError:showerror];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
//#warning 测试
//    QDXChangePwdViewController* qdx=[[QDXChangePwdViewController alloc]init];
//    [self.navigationController pushViewController:qdx animated:YES];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
        if (textField.tag== 2) {
            CGFloat offset = QdxHeight - (textField.frame.origin.y + textField.frame.size.height +216 + 100);
            if (offset <= 0) {
                [UIView animateWithDuration:0.3 animations:^{
                    CGRect frame = self.view.frame;
                    frame.origin.y = offset;
                    self.view.frame = frame;
                }];
            }
        }else if (textField.tag == 1) {
            CGFloat offset = QdxHeight - (textField.frame.origin.y + textField.frame.size.height +216 + 150);
            if (offset <= 0) {
                [UIView animateWithDuration:0.3 animations:^{
                    CGRect frame = self.view.frame;
                    frame.origin.y = offset;
                    self.view.frame = frame;
                }];
            }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
