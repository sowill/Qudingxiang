//
//  SignViewController.m
//  趣定向
//
//  Created by Prince on 16/5/19.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "SignViewController.h"
#import "Customer.h"


@interface SignViewController ()<UITextViewDelegate>
{
    UITextView *_signText;
    NSDictionary *_signDict;
}
@end

@implementation SignViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"个性签名";
    [self createText];
    [_signText becomeFirstResponder];
}

- (void)createText
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    _signText = [[UITextView alloc] init];
    CGFloat signTextCenterX = QdxWidth * 0.5;
    CGFloat signTextCenterY = 40 + 50/2;
    _signText.center = CGPointMake(signTextCenterX, signTextCenterY);
    _signText.bounds = CGRectMake(0, 20,QdxWidth-20, 100);
    _signText.font = [UIFont fontWithName:@"Arial" size:16.0f];
    _signText.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    _signText.keyboardType = UIKeyboardTypeDefault;
    _signText.backgroundColor = [UIColor whiteColor];
    _signText.delegate = self;
    _signText.keyboardType = UIKeyboardTypeDefault;
    _signText.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_signText];
    
    
    UIButton *commitBtn = [[UIButton alloc] init];
    [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    CGFloat commitBtnCenterX = QdxWidth * 0.5;
    CGFloat commitBtnCenterY = 10 + 40/2 + 20 + 1 + 35/2 + 25 + 55;
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
    [commitBtn addTarget:self action:@selector(upDate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commitBtn];
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    // Position the insertion cursor at the end of any existing text
    NSRange insertionPoint = NSMakeRange([_signText.text length], 0);
    _signText.selectedRange = insertionPoint;
}

- (void)upDate
{
    [self.view endEditing:YES];
    NSString *text = _signText.text;
    
    NSString *url = [newHostUrl stringByAppendingString:modifyUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    params[@"customer_signature"] = [NSString stringWithFormat:@"%@", text];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
