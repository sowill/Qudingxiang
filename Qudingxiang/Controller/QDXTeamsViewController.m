//
//  QDXTeamsViewController.m
//  Qudingxiang
//
//  Created by Air on 15/10/22.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "QDXTeamsViewController.h"

@interface QDXTeamsViewController ()<UITextFieldDelegate>
{
    UITextField *teamName;
    UITextField *masterNmae;
    UITextField *teamNumber1;
    UITextField *teamNumber2;
    UITextField *teamNumber3;
    UITextField *teamNumber4;
    
    NSString *manName;
    NSString *manId;
    
    NSString *customerId2;
    NSString *customerName2;
    
    NSString *customerId3;
    NSString *customerName3;
    
    NSString *customerId4;
    NSString *customerName4;
    
    NSString *customerId5;
    NSString *customerName5;
    
    UIButton *loginBtn;
    UIView *teamView;
    UIView *masterView;
    UIView *teamNumberView;
}
@property (nonatomic,strong) UIScrollView *QDXScrollView;
@end

@implementation QDXTeamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCurrentLine];
    
    self.QDXScrollView =[[UIScrollView alloc] initWithFrame:self.view.frame];
    self.QDXScrollView.showsVerticalScrollIndicator = FALSE;
    [self.view addSubview:self.QDXScrollView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [self setupFrame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:teamNumber1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:teamNumber2];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:teamNumber3];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:teamNumber4];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [teamName resignFirstResponder];
    [masterNmae resignFirstResponder];
    [teamNumber1 resignFirstResponder];
    [teamNumber2 resignFirstResponder];
    [teamNumber3 resignFirstResponder];
    [teamNumber4 resignFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textChange
{
    if (teamNumber1.text.length == 11  && ![teamNumber1.text isEqualToString:masterNmae.text]) {
        manId = teamNumber1.text;
        [self showProgessMsg:@"请求中"];
        [self setupgetCusByCode:teamNumber1];
    }else if (teamNumber2.text.length == 11  && ![teamNumber1.text isEqualToString:masterNmae.text]){
        manId = teamNumber2.text;
        [self showProgessMsg:@"请求中"];
        [self setupgetCusByCode:teamNumber2];
    }else if (teamNumber3.text.length == 11  && ![teamNumber1.text isEqualToString:masterNmae.text]){
        manId = teamNumber3.text;
        [self showProgessMsg:@"请求中"];
        [self setupgetCusByCode:teamNumber3];
    }else if (teamNumber4.text.length == 11 && ![teamNumber1.text isEqualToString:masterNmae.text]){
        manId = teamNumber4.text;
        [self showProgessMsg:@"请求中"];
        [self setupgetCusByCode:teamNumber4];
    }
}


-(void)setupFrame
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    //1 队伍名称 , 2 队长 ，3 成员 1 - 5 4 ，完成按钮
    
    teamView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, QdxWidth, 78)];
    teamView.backgroundColor = [UIColor whiteColor];
    [self.QDXScrollView addSubview:teamView];
    teamName = [[UITextField alloc]init];
    CGFloat teamNameCenterX = QdxWidth * 0.5;
    CGFloat teamNameCenterY = 10 + 15 + 10 + 40/2;
    teamName.center = CGPointMake(teamNameCenterX, teamNameCenterY);
    teamName.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    teamName.borderStyle = UITextBorderStyleNone;
    teamName.font = [UIFont fontWithName:@"Arial" size:16.0f];
    teamName.placeholder = @"请输入队伍名称";
    teamName.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    teamName.backgroundColor = [UIColor whiteColor];
    teamName.clearButtonMode = UITextFieldViewModeWhileEditing;
    teamName.tag = 1;
    teamName.delegate = self;
    [teamView addSubview:teamName];
    UILabel * tName = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 35, 15)];
    tName.text = @"队名";
    tName.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
    [teamView addSubview:tName];
    
    masterView = [[UIView alloc] initWithFrame:CGRectMake(0, 10 + 78 + 10, QdxWidth, 78)];
    masterView.backgroundColor = [UIColor whiteColor];
    [self.QDXScrollView addSubview:masterView];
    masterNmae = [[UITextField alloc]init];
    CGFloat masterNmaeCenterX = teamNameCenterX;
    CGFloat masterNmaeCenterY = teamNameCenterY;
    masterNmae.center = CGPointMake(masterNmaeCenterX, masterNmaeCenterY);
    masterNmae.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    masterNmae.borderStyle = UITextBorderStyleNone;
    masterNmae.font = [UIFont fontWithName:@"Arial" size:16.0f];
    masterNmae.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    masterNmae.placeholder = @"请输入队长名称";
    masterNmae.userInteractionEnabled = NO;
    masterNmae.backgroundColor = [UIColor whiteColor];
    masterNmae.clearButtonMode = UITextFieldViewModeWhileEditing;
    masterNmae.tag = 2;
    masterNmae.delegate = self;
    [masterView addSubview:masterNmae];
    UILabel * mName = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 35, 15)];
    mName.text = @"队长";
    mName.textColor = [UIColor colorWithRed:58/255.0 green:58/255.0 blue:58/255.0 alpha:1];
    [mName setTextColor:[UIColor blackColor]];
    [masterView addSubview:mName];
    
    teamNumberView = [[UIView alloc] initWithFrame:CGRectMake(0, 10 + 78 + 10 + 78 + 10, QdxWidth, 78 * 4)];
    teamNumberView.backgroundColor = [UIColor whiteColor];
    [self.QDXScrollView addSubview:teamNumberView];
    teamNumber1 = [[UITextField alloc]init];
    CGFloat teamNumber1CenterX = teamNameCenterX;
    CGFloat teamNumber1CenterY = 10 + 15 + 10 + 40/2 + 10 + 78 + 10 + 78 + 10;
    teamNumber1.center = CGPointMake(teamNumber1CenterX, teamNumber1CenterY);
    teamNumber1.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    teamNumber1.borderStyle = UITextBorderStyleNone;
    teamNumber1.font = [UIFont fontWithName:@"Arial" size:16.0f];
    teamNumber1.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    teamNumber1.keyboardType = UIKeyboardTypeNumberPad;
    teamNumber1.placeholder = @"请输入组员手机号";
    teamNumber1.clearButtonMode = UITextFieldViewModeWhileEditing;
    teamNumber1.tag = 3;
    teamNumber1.backgroundColor = [UIColor whiteColor];
    teamNumber1.delegate = self;
    [self.QDXScrollView addSubview:teamNumber1];
    UILabel * tNumber1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 35, 15)];
    tNumber1.text = @"队员";
    tNumber1.textColor = [UIColor colorWithRed:58/255.0 green:58/255.0 blue:58/255.0 alpha:1];
    [tNumber1 setTextColor:[UIColor blackColor]];
    [teamNumberView addSubview:tNumber1];
    
    teamNumber2 = [[UITextField alloc]init];
    CGFloat teamNumber2CenterX = teamNameCenterX;
    CGFloat teamNumber2CenterY = teamNumber1CenterY + 78;
    teamNumber2.center = CGPointMake(teamNumber2CenterX, teamNumber2CenterY);
    teamNumber2.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    teamNumber2.borderStyle = UITextBorderStyleNone;
    teamNumber2.font = [UIFont fontWithName:@"Arial" size:16.0f];
    teamNumber2.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    teamNumber2.placeholder = @"请输入组员手机号";
    teamNumber2.keyboardType = UIKeyboardTypeNumberPad;
    teamNumber2.clearButtonMode = UITextFieldViewModeWhileEditing;
    teamNumber2.tag = 4;
    teamNumber2.backgroundColor = [UIColor whiteColor];
    teamNumber2.delegate = self;
    [self.QDXScrollView addSubview:teamNumber2];
    UILabel * tNumber2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 15 + 78, 35, 15)];
    tNumber2.text = @"队员";
    tNumber2.textColor = [UIColor colorWithRed:58/255.0 green:58/255.0 blue:58/255.0 alpha:1];
    [tNumber2 setTextColor:[UIColor blackColor]];
    [teamNumberView addSubview:tNumber2];
    
    teamNumber3 = [[UITextField alloc]init];
    CGFloat teamNumber3CenterX = teamNameCenterX;
    CGFloat teamNumber3CenterY = teamNumber2CenterY + 78;
    teamNumber3.center = CGPointMake(teamNumber3CenterX, teamNumber3CenterY);
    teamNumber3.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    teamNumber3.borderStyle = UITextBorderStyleNone;
    teamNumber3.font = [UIFont fontWithName:@"Arial" size:16.0f];
    teamNumber3.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    teamNumber3.placeholder = @"请输入组员手机号";
    teamNumber3.keyboardType = UIKeyboardTypeNumberPad;
    teamNumber3.clearButtonMode = UITextFieldViewModeWhileEditing;
    teamNumber3.tag = 5;
    teamNumber3.backgroundColor = [UIColor whiteColor];
    teamNumber3.delegate = self;
    [self.QDXScrollView addSubview:teamNumber3];
    UILabel * tNumber3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 15 + 78 * 2, 35, 15)];
    tNumber3.text = @"队员";
    tNumber3.textColor = [UIColor colorWithRed:58/255.0 green:58/255.0 blue:58/255.0 alpha:1];
    [tNumber3 setTextColor:[UIColor blackColor]];
    [teamNumberView addSubview:tNumber3];
    
    teamNumber4 = [[UITextField alloc]init];
    CGFloat teamNumber4CenterX = teamNameCenterX;
    CGFloat teamNumber4CenterY = teamNumber3CenterY + 78;
    teamNumber4.center = CGPointMake(teamNumber4CenterX, teamNumber4CenterY);
    teamNumber4.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    teamNumber4.borderStyle = UITextBorderStyleNone;
    teamNumber4.font = [UIFont fontWithName:@"Arial" size:16.0f];
    teamNumber4.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    teamNumber4.placeholder = @"请输入组员手机号";
    teamNumber4.keyboardType = UIKeyboardTypeNumberPad;
    teamNumber4.clearButtonMode = UITextFieldViewModeWhileEditing;
    teamNumber4.tag = 6;
    teamNumber4.backgroundColor = [UIColor whiteColor];
    teamNumber4.delegate = self;
    [self.QDXScrollView addSubview:teamNumber4];
    UILabel * tNumber4 = [[UILabel alloc] initWithFrame:CGRectMake(10, 15 + 78 * 3, 35, 15)];
    tNumber4.text = @"队员";
    tNumber4.textColor = [UIColor colorWithRed:58/255.0 green:58/255.0 blue:58/255.0 alpha:1];
    [tNumber4 setTextColor:[UIColor blackColor]];
    [teamNumberView addSubview:tNumber4];
    
    loginBtn = [[UIButton alloc] init];
    [loginBtn setTitle:@"完成" forState:UIControlStateNormal];
    CGFloat loginBtnCenterX = QdxWidth* 0.5;
    CGFloat loginBtnCenterY = teamNumber4CenterY + 20 + 1 + 35/2 + 25;
    loginBtn.center = CGPointMake(loginBtnCenterX, loginBtnCenterY);
    loginBtn.bounds = CGRectMake(0, 0, QdxWidth-20, 35);
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    [loginBtn setBackgroundImage:[[UIImage imageNamed:@"sign_button"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
    [self.QDXScrollView addSubview:loginBtn];
    
    [self refreshScrollView];
}

-(void)refreshScrollView
{
    CGFloat scrollViewHeight = 0.0f;
    scrollViewHeight += loginBtn.frame.size.height + teamView.frame.size.height + masterView.frame.size.height + teamNumberView.frame.size.height + 300;
    [self.QDXScrollView setContentSize:(CGSizeMake(QdxWidth, scrollViewHeight))];
}

-(void)complete
{
    [self setupaddTeams];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupCurrentLine
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    NSString *url = [hostUrl stringByAppendingString:@"Home/Myline/getCurrentLine"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1 && self.model.myline_id == NULL) {
            teamName.text =infoDict[@"Msg"][@"team"];
            _myLineid =infoDict[@"Msg"][@"myline_id"];
        }
        else{
            _myLineid = self.model.myline_id;
        }
        [self setupgetMyTeam];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)setupgetMyTeam
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"myline_id"] = _myLineid;
    NSString *url = [hostUrl stringByAppendingString:@"Home/Myline/getMyTeam"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1) {
            masterNmae.text = infoDict[@"Msg"][@"men1"];
            teamNumber1.text = infoDict[@"Msg"][@"men2"];
            customerId2 = infoDict[@"Msg"][@"men2_id"];
            teamNumber2.text = infoDict[@"Msg"][@"men3"];
            customerId3 = infoDict[@"Msg"][@"men3_id"];
            teamNumber3.text = infoDict[@"Msg"][@"men4"];
            customerId4 = infoDict[@"Msg"][@"men4_id"];
            teamNumber4.text = infoDict[@"Msg"][@"men5"];
            customerId5 = infoDict[@"Msg"][@"men5_id"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)setupgetCusByCode:(UITextField *)textField
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"code"] = manId;
    NSString *url = [hostUrl stringByAppendingString:@"Home/Myline/getCusByCode"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1) {
            manName = infoDict[@"Msg"][@"customer_name"];
            if (textField.tag == 3) {
                teamNumber1.text = manName;
                customerId2 = infoDict[@"Msg"][@"customer_id"];
                customerName2 = infoDict[@"Msg"][@"customer_name"];
            }else if (textField.tag == 4){
                teamNumber2.text = manName;
                customerId3 = infoDict[@"Msg"][@"customer_id"];
                customerName3 = infoDict[@"Msg"][@"customer_name"];
            }else if (textField.tag == 5){
                teamNumber3.text = manName;
                customerId4 = infoDict[@"Msg"][@"customer_id"];
                customerName4 = infoDict[@"Msg"][@"customer_name"];
            }else if (textField.tag == 6){
                teamNumber4.text = manName;
                customerId5 = infoDict[@"Msg"][@"customer_id"];
                customerName5 = infoDict[@"Msg"][@"customer_name"];
            }
        }else{
            NSString *showerror = [infoDict objectForKey:@"Msg"];
            [MBProgressHUD showMessage:showerror];
            if (textField.tag == 3) {
                teamNumber1.text = nil;
            }else if (textField.tag == 4){
                teamNumber2.text = nil;
            }else if (textField.tag == 5){
                teamNumber3.text = nil;
            }else if (textField.tag == 6){
                teamNumber4.text = nil;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 2.0s后执行block里面的代码
                [MBProgressHUD hideHUD];
            });
        }
        [self showProgessOK:@"请求完成"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)setupaddTeams
{
    NSString *team = teamName.text;
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"team"] = team;
    params[@"myline_id"] = _myLineid;
    params[@"customer_id2"] = customerId2;
    if (teamNumber1.text) {
        params[@"customer_name2"] = teamNumber1.text;
    }else{
        params[@"customer_name2"] = customerName2;
    }
    
    params[@"customer_id3"] = customerId3;
    
    if (teamNumber2.text) {
        params[@"customer_name3"] = teamNumber2.text;
    }else{
        params[@"customer_name3"] = customerName3;
    }
    
    params[@"customer_id4"] = customerId4;
    
    if (teamNumber3.text) {
        params[@"customer_name4"] = teamNumber3.text;
    }else{
        params[@"customer_name4"] = customerName4;
    }
    
    params[@"customer_id5"] = customerId5;
    
    if (teamNumber4.text) {
        params[@"customer_name5"] = teamNumber4.text;
    }else{
        params[@"customer_name5"] = customerName5;
    }
    NSString *url = [hostUrl stringByAppendingString:@"Home/Myline/addTeams"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

//-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect frame = self.view.frame;
//        frame.origin.y = 0.0 + 64;
//        self.view.frame = frame;
//    }];
//    [self.view endEditing:YES];
//    return YES;
//}

//-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//        CGFloat offset = QdxHeight - (textField.frame.origin.y + textField.frame.size.height +216 + 50);
//        if (offset <= 0) {
//            [UIView animateWithDuration:0.3 animations:^{
//                CGRect frame = self.view.frame;
//                frame.origin.y = offset;
//                self.view.frame = frame;
//            }];
//        }
//    return YES;
//}

//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect frame = self.view.frame;
//        frame.origin.y = 0.0 + 64;
//        self.view.frame = frame;
//    }];
//    [self.view endEditing:YES];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
