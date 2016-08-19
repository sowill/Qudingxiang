//
//  QDXPayTableViewController.m
//  趣定向
//
//  Created by Air on 16/1/18.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXPayTableViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import "APAuthV2Info.h"
#import "QDXOrdermodel.h"
#import "AlipayModel.h"
#import "WeixinModel.h"
#import "QDXTicketInfoModel.h"
#import "QDXOrderDetailTableViewController.h"

@interface QDXPayTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *pay;
    UIImageView *Aliselect;
    UIImageView *WXselect;
    int aliOrWX;
}
@property (nonatomic, strong) AlipayModel *Alipay;
@property (nonatomic, strong) WeixinModel *WXpay;
@property (nonatomic, strong) UITableView *tableview;
@end

@implementation QDXPayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"支付";
    self.view.backgroundColor=[UIColor colorWithWhite:0.949 alpha:1.000];
    [self createTableView];
    aliOrWX = 2;
}

-(void)createTableView
{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, QdxWidth, 245) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    self.tableview.scrollEnabled =NO;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableview];
    
    pay = [[UIButton alloc] initWithFrame:CGRectMake(10, 245, QdxWidth-20, 40)];
    [pay setTitle:@"确认支付" forState:UIControlStateNormal];
    pay.userInteractionEnabled = NO;
    [pay setBackgroundImage:[ToolView createImageWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
    [pay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pay setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [pay addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pay];
    
}
-(void)pay
{
    pay.userInteractionEnabled = NO;
    if (aliOrWX == 1) {
        [self AlipayClicked];
        pay.userInteractionEnabled = YES;
    }else if(aliOrWX == 0){
        [self WXClicked];
        pay.userInteractionEnabled = YES;
    }else{
        [MBProgressHUD showError:@"请选择支付方式!"];
    }
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 2;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    if (indexPath.section == 1&&indexPath.row == 0) {
//        UILabel *wxText = [[UILabel alloc] initWithFrame:CGRectMake(40 + 10 + 10, 21, 100, 18)];
//        wxText.text = @"微信支付";
//        wxText.font = [UIFont systemFontOfSize:14];
//        wxText.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
//        UIImageView *wxImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
//        wxImage.image = [UIImage imageNamed:@"微信"];
//        [cell addSubview:wxText];
//        [cell addSubview:wxImage];
        cell.textLabel.text = @"微信支付";
        cell.imageView.image = [UIImage imageNamed:@"微信"];
        WXselect = [[UIImageView alloc] initWithFrame:CGRectMake(QdxWidth - 35, 21, 18, 18)];
        WXselect.image = [UIImage imageNamed:@"勾选默认"];
        [cell addSubview:WXselect];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if (indexPath.section == 1&&indexPath.row == 1){
//        UILabel *aliText = [[UILabel alloc] initWithFrame:CGRectMake(40 + 10 + 10, 21, 100, 18)];
//        aliText.text = @"支付宝支付";
//        aliText.font = [UIFont systemFontOfSize:14];
//        aliText.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
//        UIImageView *aliImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
//        aliImage.image = [UIImage imageNamed:@"支付宝"];
//        [cell addSubview:aliText];
//        [cell addSubview:aliImage];
        cell.textLabel.text = @"支付宝支付";
        cell.imageView.image = [UIImage imageNamed:@"支付宝"];
        Aliselect = [[UIImageView alloc] initWithFrame:CGRectMake(QdxWidth - 35, 21, 18, 18)];
        Aliselect.image = [UIImage imageNamed:@"勾选默认"];
        [cell addSubview:Aliselect];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if (indexPath.section == 0&&indexPath.row == 0){
        cell.textLabel.text = @"总额";
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
        UILabel *cost = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth - 65, 5, 100, 30)];
        cost.textColor = [UIColor colorWithRed:1.000 green:0.318 blue:0.000 alpha:1.000];
        cost.font = [UIFont systemFontOfSize:16];
        cost.text =[@"¥" stringByAppendingString: self.Order.Orders_am];
        [cell addSubview:cost];
        cell.backgroundColor = [UIColor colorWithRed:0.996 green:0.957 blue:0.800 alpha:1.000];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark - 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 40;
    }else{
        return 60;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat sectionHeaderHeight = 40;
    
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1){
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 40)];
        headerView.backgroundColor = [UIColor whiteColor];
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, QdxWidth *  0.7 , 20)];
        header.text = @"选择支付方式";
        header.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
        header.font = [UIFont fontWithName:@"Arial" size:14];
        [headerView addSubview:header];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, QdxWidth, 1)];
        lineView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
        [headerView addSubview:lineView];
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40;
    }else{
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,0, 0, 0)];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1&&indexPath.row==0) {
        WXselect.image = [UIImage imageNamed:@"勾选选中"];
        Aliselect.image = [UIImage imageNamed:@"勾选默认"];
        aliOrWX = 0;
        [self getWeixinpay];
    }else if (indexPath.section == 1&&indexPath.row==1){
        Aliselect.image = [UIImage imageNamed:@"勾选选中"];
        WXselect.image = [UIImage imageNamed:@"勾选默认"];
        aliOrWX = 1;
        [self getAlipayapp];
    }
    
}

-(void)getAlipayapp
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *url = [hostUrl stringByAppendingString:@"Home/Alipay/app"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        _Alipay = [AlipayModel mj_objectWithKeyValues:dict];
        pay.userInteractionEnabled = YES;
        CGFloat top = 25;
        CGFloat bottom = 25;
        CGFloat left = 5;
        CGFloat right = 5;
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        [pay setBackgroundImage:[[UIImage imageNamed:@"sign_button"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)getWeixinpay
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"]= save;
    params[@"Orders_id"] = [NSString stringWithFormat:@"%d",self.Order.Orders_id];
    NSString *url = [hostUrl stringByAppendingString:@"Home/Weixin/pay"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if(dict != nil){
            NSMutableString *retcode = [dict objectForKey:@"retcode"];
            if (retcode.intValue == 0){
                _WXpay = [WeixinModel mj_objectWithKeyValues:dict];
                pay.userInteractionEnabled = YES;
                CGFloat top = 25;
                CGFloat bottom = 25;
                CGFloat left = 5;
                CGFloat right = 5;
                UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
                [pay setBackgroundImage:[[UIImage imageNamed:@"sign_button"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)WXClicked
{
    [MBProgressHUD showMessage:@"正在处理"];
                NSString *stamp  = _WXpay.timestamp;
                //调起微信支付
                PayReq* req             = [[PayReq alloc] init];
                req.partnerId           = _WXpay.partnerid;
                req.prepayId            = _WXpay.prepayid;
                req.nonceStr            = _WXpay.noncestr;
                req.timeStamp           = [stamp intValue];
                req.package             = @"Sign=WXPay";
                req.sign                = _WXpay.sign;
                [WXApi sendReq:req];
    [MBProgressHUD hideHUD];
}

#pragma mark
-(void)AlipayClicked
{
    /*
     *点击获取prodcut实例并初始化订单信息
     */
    //    Product *product = [self.productList alloc];
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    NSString *partner = _Alipay.partner;
    NSString *seller = _Alipay.seller;
    NSString *privateKey =_Alipay.privateKey;
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = self.Order.Orders_name; //订单ID（由商家自行制定）
    order.productName = self.ticketInfo.ticketinfo_name; //商品标题
    order.productDescription = self.ticketInfo.ticketinfo_name; //商品描述
    order.amount = self.Order.Orders_am; //商品价格
    order.notifyURL =  [hostUrl stringByAppendingString:@"Home/Alipay/notify"]; //回调URL
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"alipay2088121109128595";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
//    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSString *message = @"";
            switch([[resultDic objectForKey:@"resultStatus"] integerValue])
            {
                case 9000:message = @"订单支付成功";
                    break;
                case 8000:message = @"正在处理中";break;
                case 4000:message = @"订单支付失败";break;
                case 6001:message = @"用户中途取消";break;
                case 6002:message = @"网络连接错误";break;
                default:message = @"未知错误";
            }
            UIAlertController *aalert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [aalert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
                QDXOrderDetailTableViewController* QDetailVC=[[QDXOrderDetailTableViewController alloc]init];
                QDetailVC.orderId = [NSString stringWithFormat:@"%d",self.Order.Orders_id];
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:aalert animated:YES completion:nil];
            

        }];
    }

}

@end
