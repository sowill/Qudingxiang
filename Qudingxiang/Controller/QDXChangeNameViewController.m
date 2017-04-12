//
//  QDXChangeNameViewController.m
//  Qudingxiang
//
//  Created by Air on 15/9/23.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXChangeNameViewController.h"
#import "Customer.h"
//#import "TabbarController.h"

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

    self.navigationItem.title = @"修改用户昵称";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:customerNameText];

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
    //4 添加一个用户名称输入框
    customerNameText = [[UITextField alloc]init];
    CGFloat customerNameTextCenterX = QdxWidth * 0.5;
    CGFloat customerNameTextCenterY = 10 + 40/2;
    customerNameText.center = CGPointMake(customerNameTextCenterX, customerNameTextCenterY);
    customerNameText.bounds = CGRectMake(0, 0,QdxWidth-20, 40);
    customerNameText.borderStyle = UITextBorderStyleNone;
    customerNameText.text = _cusName;
//    customerNameText.placeholder = @"请修改昵称";
    customerNameText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    customerNameText.textColor = QDXGray;
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
    commitBtn.bounds = CGRectMake(0, 0, QdxWidth-20, 40);
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:QDXGray forState:UIControlStateHighlighted];
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
    
    NSString *url = [newHostUrl stringByAppendingString:modifyUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    params[@"customer_cn"] = [NSString stringWithFormat:@"%@", customername];
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
        }else{
            
        }
        
    } failure:^(NSError *error) {
        
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
