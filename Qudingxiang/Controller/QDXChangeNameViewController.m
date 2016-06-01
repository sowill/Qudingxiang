//
//  QDXChangeNameViewController.m
//  Qudingxiang
//
//  Created by Air on 15/9/23.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXChangeNameViewController.h"
#import "QDXIsConnect.h"
#import "TabbarController.h"

@interface QDXChangeNameViewController ()<UITextFieldDelegate>
{
    UITextField *customerNameText;
    UIButton *showTel;
}
@end

@implementation QDXChangeNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupChangeName];
    [self createButtonBack];
    self.navigationItem.title = @"修改用户昵称";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:customerNameText];

}

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
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)textChange
{
    showTel.hidden = NO;
}

-(void)setupChangeName
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    
    //4 添加一个用户名称输入框
    customerNameText = [[UITextField alloc]init];
    CGFloat customerNameTextCenterX = QdxWidth * 0.5;
    CGFloat customerNameTextCenterY = 10 + 40/2;
    customerNameText.center = CGPointMake(customerNameTextCenterX, customerNameTextCenterY);
    customerNameText.bounds = CGRectMake(0, 0,QdxWidth-20, 40);
    customerNameText.borderStyle = UITextBorderStyleNone;
    customerNameText.placeholder = @"请修改昵称";
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
//    UIView *customerNameTextView = [[UIView alloc] initWithFrame:CGRectMake(0, customerNameTextCenterY+20, QdxWidth, 1)];
//    customerNameTextView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
//    [self.view addSubview:customerNameTextView];
    showTel = [[UIButton alloc] initWithFrame:CGRectMake((QdxWidth-10-19), customerNameTextCenterY - 19/2, 19, 19)];
    [showTel setBackgroundImage:[UIImage imageNamed:@"sign_delete"] forState:UIControlStateNormal];
    [showTel addTarget:self action:@selector(deletetel) forControlEvents:UIControlEventTouchUpInside];
    showTel.hidden = YES;
    [self.view addSubview:showTel];
    
    //6 添加提交按钮
    UIButton *commitBtn = [[UIButton alloc] init];
    [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    CGFloat commitBtnCenterX = QdxWidth * 0.5;
    CGFloat commitBtnCenterY = customerNameTextCenterY + 20 + 1 + 35/2 + 25;
    commitBtn.center = CGPointMake(commitBtnCenterX, commitBtnCenterY);
    commitBtn.bounds = CGRectMake(0, 0, QdxWidth-20, 35);
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

-(void)commitBtnClick
{
    [self.view endEditing:YES];

    NSString *customername = customerNameText.text;
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"customer_name"] = [NSString stringWithFormat:@"%@", customername];
    NSString *url = [hostUrl stringByAppendingString:@"Home/Customer/modify"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        QDXIsConnect *isConnect = [QDXIsConnect mj_objectWithKeyValues:dict];
        int ret = [isConnect.Code intValue];
        
        if (ret==1) {
            [MBProgressHUD showSuccess:@"修改成功"];
            
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
            [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
            
            [NSKeyedArchiver archiveRootObject:isConnect.Msg[@"token"] toFile:XWLAccountFile];
            
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        else{
            }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)deletetel
{
    customerNameText.text = nil;
    showTel.hidden = YES;
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
