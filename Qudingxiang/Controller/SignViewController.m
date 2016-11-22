//
//  SignViewController.m
//  趣定向
//
//  Created by Prince on 16/5/19.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "SignViewController.h"
#import "MineService.h"
@interface SignViewController ()<UITextViewDelegate>
{
    UITextView *_signText;
    NSDictionary *_signDict;
}
@end

@implementation SignViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self signData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"个性签名";
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [self createText];
//    [self createNavBtn];
    [_signText becomeFirstResponder];

}

- (void)createNavBtn
{
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonBack.frame = CGRectMake(0, 0, 18, 14);
    [buttonBack addTarget:self action:@selector(buttonBackSettin) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setTitle:nil forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"sign_return"] forState:UIControlStateNormal];
    buttonBack.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

- (void)buttonBackSettin
{
    [_signText endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
- (void)signData
{
    [MineService cellDataBlock:^(NSDictionary *dict) {
        NSDictionary* _dic = [[NSDictionary alloc] initWithDictionary:dict];
        _signDict=[[NSDictionary alloc] initWithDictionary:_dic];
        _signText.text = _signDict[@"Msg"][@"signature"];
        if([_signDict[@"Code"] integerValue] == 0){
            
        }else{
            
        }
        
    } FailBlock:^(NSMutableArray *array) {
        
    } andWithToken:save];

}
- (void)upDate
{
    [self.view endEditing:YES];
    NSString *text = _signText.text;
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"signature"] = [NSString stringWithFormat:@"%@", text];
    NSString *url = [hostUrl stringByAppendingString:@"Home/Customer/modify"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([dict[@"Code"] intValue]==1) {
            [MBProgressHUD showSuccess:@"修改成功"];
            
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
            [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
            
            [NSKeyedArchiver archiveRootObject:dict[@"Msg"][@"token"] toFile:XWLAccountFile];
            
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];

        }else
        {
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
