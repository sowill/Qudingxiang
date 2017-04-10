//
//  QDXLineDetailViewController.m
//  Qudingxiang
//
//  Created by Air on 15/9/21.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXLineDetailViewController.h"
#import "QDXDetailsModel.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "Goods.h"
#import "QDXOrderDetailTableViewController.h"
#import "QDXLoginViewController.h"
#import "Orders.h"
#import "NSMutableAttributedString+ChangeColorFont.h"
#import <WebKit/WebKit.h>

@interface QDXLineDetailViewController ()<WKNavigationDelegate>
{
    UIButton *pay;
    UILabel *_price;
    UIButton *_addBtn;
    UIButton *_minBtn;
    UILabel *_numberLabel;
    float _totalPrice;
    int quantity;

    UIView *_bottom;
    UIView *_payView;
    WKWebView *_webView;
    UILabel *activityStartTime;
    UIImageView *activitypic;
    UILabel *place;
    UILabel *details;
    UIButton  *sign_up;
}
@property (nonatomic ,strong) UIView *deliverView; //底部View
@property (nonatomic ,strong) UIView *BGView; //遮罩
@property (strong, nonatomic) UIProgressView *progressView;
@property (assign, nonatomic) NSUInteger loadCount;
@property (nonatomic, strong) Orders *orders;
@end

@implementation QDXLineDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置线路详情
    [self setupDetail];

    UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 18)];
    [share addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    [share setBackgroundImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:share];
}

-(void)shareClick
{
    NSArray *shareButtonTitleArray = [[NSArray alloc] init];
    NSArray *shareButtonImageNameArray = [[NSArray alloc] init];
    shareButtonTitleArray = @[@"微信好友",@"朋友圈",@"QQ好友",@"QQ空间"];
    shareButtonImageNameArray = @[@"微信好友",@"朋友圈",@"qq好友",@"qq空间"];
    LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
    [lxActivity showInView:self.view];
}

#pragma mark - LXActivityDelegate

- (void)didClickOnImageIndex:(NSInteger *)imageIndex
{

    NSString *urlstr = [hostUrl stringByAppendingString:[NSString stringWithFormat:@"index.php/home/goods/index/goods_id/%@",_goods.goods_id]];
    NSURL *imgurl = [NSURL URLWithString:urlstr];
    NSString *title = @"趣定向";
    NSString *description = _goods.goods_cn;
    if (imageIndex == 0) {
        TencentOAuth *auth = [[TencentOAuth alloc] initWithAppId:QQ_KEY andDelegate:self];

        NSString *imgPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icon-76@2x.png"];
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:imgurl title:title description:description previewImageData:imgData];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    } else if (imageIndex == 1){
        TencentOAuth *auth = [[TencentOAuth alloc] initWithAppId:QQ_KEY andDelegate:self];
        NSString *utf8String =[imgurl absoluteString];
        NSString *imgPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icon-76@2x.png"];
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:[NSURL URLWithString:utf8String] title:title description:description previewImageData:imgData];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    }else if (imageIndex == 2){
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;
        message.description = description;
        [message setThumbImage:[UIImage imageNamed:@"Icon-76@2x.png"]];
        WXWebpageObject *webpageObject = [WXWebpageObject object];
        webpageObject.webpageUrl = urlstr;
        message.mediaObject = webpageObject;
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneSession;
        [WXApi sendReq:req];
    }else if (imageIndex == 3){
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = description;
        message.description = description;
        [message setThumbImage:[UIImage imageNamed:@"Icon-76@2x.png"]];
        WXWebpageObject *webpageObject = [WXWebpageObject object];
        webpageObject.webpageUrl = urlstr;
        message.mediaObject = webpageObject;
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneTimeline;
        [WXApi sendReq:req];
        
    }
}


-(void)setupDetail
{
    self.navigationItem.title = _goods.goods_cn;
    
    // 进度条
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth,6)];
    progressView.tintColor = QDXBlue;
    progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:progressView];
    
//    CGFloat progressBarHeight = FitRealValue(10);
//    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
//    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height, navigationBarBounds.size.width, progressBarHeight);
//    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:barFrame];
//    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    progressView.trackTintColor = [UIColor whiteColor];
//    progressView.tintColor = QDXBlue;
//    [self.navigationController.navigationBar addSubview:progressView];
    
    self.progressView = progressView;
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.navigationDelegate = self;
//    [self.view addSubview:_webView];
    [self.view insertSubview:_webView belowSubview:progressView];
    
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    NSString *url = [newHostUrl stringByAppendingString:[goodsIndexUrl stringByAppendingString:[NSString stringWithFormat:@"/goods_id/%@",_goods.goods_id]]];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    if([_goods.goodstatus_id isEqualToString:@"1"]){
        [self createPayUI];
    }else{
        
    }
}

// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}

// 记得取消监听
- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

// 计算webView进度条
- (void)setLoadCount:(NSUInteger)loadCount {
    _loadCount = loadCount;
    if (loadCount == 0) {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    }else {
        self.progressView.hidden = NO;
        CGFloat oldP = self.progressView.progress;
        CGFloat newP = (1.0 - oldP) / (loadCount + 1) + oldP;
        if (newP > 0.95) {
            newP = 0.95;
        }
        [self.progressView setProgress:newP animated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.loadCount ++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.loadCount --;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.loadCount --;
}

- (void)createPayUI
{
    // 添加底部按钮
    _bottom = [[UIView alloc] initWithFrame:CGRectMake(0, QdxHeight- FitRealValue(110)-64, QdxWidth, 0.5)];
    _bottom.backgroundColor = QDXLineColor;
    [self.view addSubview:_bottom];
    
    sign_up = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth/2, QdxHeight- FitRealValue(110)-64, QdxWidth/2, FitRealValue(110))];
    [sign_up setTitle:@"立即报名" forState:UIControlStateNormal];
    [sign_up setBackgroundImage:[ToolView createImageWithColor:QDXBlue] forState:UIControlStateNormal];
    [sign_up setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sign_up setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [sign_up setBackgroundImage:[ToolView createImageWithColor:QDXDarkBlue] forState:UIControlStateHighlighted];
    sign_up.titleLabel.font = [UIFont systemFontOfSize:16];
    [sign_up addTarget:self action:@selector(sign_up) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sign_up];
    
    UIButton *cost = [[UIButton alloc] initWithFrame:CGRectMake(0, QdxHeight- FitRealValue(110)-64, QdxWidth/2, FitRealValue(110))];
    [cost setBackgroundColor:[UIColor whiteColor]];
    cost.userInteractionEnabled = NO;
    [self.view addSubview:cost];

    UILabel * price_1 = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth/4 - 90/2 + 10, FitRealValue(110)/2-40/2, 90, 40)];
    price_1.textColor = QDXOrange;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];
    [string appendString:@"¥" withColor:QDXOrange font:[UIFont systemFontOfSize:14]];
    NSRange range = [_goods.goods_price rangeOfString:@"."];
    NSString *a = _goods.goods_price;
    [string appendString:[a substringToIndex:(int)range.location] withColor:QDXOrange font:[UIFont systemFontOfSize:24]];
    [string appendString:[a substringFromIndex:(int)range.location] withColor:QDXOrange font:[UIFont systemFontOfSize:14]];
    price_1.attributedText = string;
    [cost addSubview:price_1];
}

-(void)sign_up
{
    if ([save length] == 0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"登陆后才可使用此功能" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"立即登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
            
            QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];

            [self.navigationController pushViewController:regi animated:YES];
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"暂不登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
            
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }else{
        // ------全屏遮罩
        self.BGView                 = [[UIView alloc] init];
        self.BGView.frame           = [[UIScreen mainScreen] bounds];
        self.BGView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        //--UIWindow的优先级最高，Window包含了所有视图，在这之上添加视图，可以保证添加在最上面
        UIWindow *appWindow = [[UIApplication sharedApplication] keyWindow];
        [appWindow addSubview:self.BGView];
        
        // ------给全屏遮罩添加的点击事件
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exitClick)];
        gesture.numberOfTapsRequired = 1;
        gesture.cancelsTouchesInView = NO;
        [self.BGView addGestureRecognizer:gesture];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.BGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
            
        }];
        
        // ------底部弹出的View
        self.deliverView                 = [[UIView alloc] init];
        self.deliverView.frame           = CGRectMake(0, QdxHeight - FitRealValue(506), QdxWidth, FitRealValue(506));
        self.deliverView.backgroundColor = [UIColor clearColor];
        
        [appWindow addSubview:self.deliverView];
        
        [self payDataWithNumber:@"0" isPush:NO];
        
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, FitRealValue(506) - FitRealValue(110) , QdxWidth, 0.5)];
        bottom.backgroundColor = QDXLineColor;
        [self.deliverView addSubview:bottom];
        // 添加底部按钮
        pay = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth/2, FitRealValue(506)- FitRealValue(110), QdxWidth/2, FitRealValue(110))];
        pay.titleLabel.font = [UIFont systemFontOfSize:16.0];
        pay.titleLabel.textAlignment = NSTextAlignmentCenter;
        [pay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [pay addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
        pay.userInteractionEnabled = YES;
        [pay setBackgroundImage:[ToolView createImageWithColor:QDXBlue] forState:UIControlStateNormal];
        [pay setTitle:@"去支付" forState:UIControlStateNormal];
        [self.deliverView addSubview:pay];
        
        UIButton *cost = [[UIButton alloc] initWithFrame:CGRectMake(0, FitRealValue(506)- FitRealValue(110), QdxWidth/2, FitRealValue(110))];
        [cost setBackgroundColor:[UIColor whiteColor]];
        cost.userInteractionEnabled = NO;
        [self.deliverView addSubview:cost];

        _price = [[UILabel alloc] initWithFrame:CGRectMake(0, FitRealValue(110)/2-40/2, QdxWidth/2, 40)];
        _price.textAlignment = NSTextAlignmentCenter;
        [cost addSubview:_price];
        _totalPrice = [self.goods.goods_price floatValue];
        [self setUpPriceFont];
        
        float viewHeight = FitRealValue(506);
        float cellHeight = FitRealValue(210);
        float payHeight = FitRealValue(110);
        float activityHeight = viewHeight-cellHeight-payHeight;
        
        _payView = [[UIView alloc] initWithFrame:CGRectMake(0, activityHeight, QdxWidth, cellHeight)];
        _payView.backgroundColor = [UIColor whiteColor];
        [self.deliverView addSubview:_payView];
        

        _addBtn = [ToolView createButtonWithFrame:CGRectMake(QdxWidth-20 - 18, cellHeight/2, 25, 18) title:@"" backGroundImage:@"加号" Target:self action:@selector(addClick) superView:_payView];
        
        _minBtn = [ToolView createButtonWithFrame:CGRectMake(QdxWidth-95 - 18, cellHeight/2, 25, 18) title:@"" backGroundImage:@"减号" Target:self action:@selector(minClick) superView:_payView];
  
        _numberLabel = [ToolView createLabelWithFrame:CGRectMake(QdxWidth-50-18,cellHeight/2, 30, 18) text:[NSString stringWithFormat:@"%i",[self.orders.orders_quantity intValue]] font:12 superView:_payView];
        
        
        UILabel *activityTime = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(40), FitRealValue(60), 60, 15)];
        activityTime.text = @"截止日期";
        activityTime.font = [UIFont systemFontOfSize:14];
        activityTime.textColor = QDXBlack;
        [_payView addSubview:activityTime];
        
        activityStartTime = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(40), cellHeight/2 +5, QdxWidth/2, 15)];
        activityStartTime.text = self.goods.goods_time;
        activityStartTime.font = [UIFont systemFontOfSize:13];
        activityStartTime.textColor = QDXGray;
        [_payView addSubview:activityStartTime];
        
        UIView *activity = [[UIView alloc] initWithFrame:CGRectMake(0, 0 , QdxWidth, activityHeight)];
        activity.backgroundColor = [UIColor whiteColor];
        [self.deliverView addSubview:activity];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, activityHeight + FitRealValue(1), QdxWidth, FitRealValue(1))];
        line.backgroundColor = QDXLineColor;
        [self.deliverView addSubview:line];
        
        UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(QdxWidth-15 - 24, 15, 24, 24);
        [closeBtn setBackgroundImage:[UIImage imageNamed:@"取消按钮"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(exitClick) forControlEvents:UIControlEventTouchUpInside];
        [activity addSubview:closeBtn];
        
        UIView *picView = [[UIView alloc] initWithFrame:CGRectMake(FitRealValue(30), -FitRealValue(60), FitRealValue(200), FitRealValue(200))];
        picView.layer.cornerRadius = 3;
        picView.layer.borderColor = [[UIColor whiteColor] CGColor];
        picView.backgroundColor = [UIColor whiteColor];
        [activity addSubview:picView];
        
        activitypic = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(10), FitRealValue(10), FitRealValue(180), FitRealValue(180))];
//        activitypic.contentMode = UIViewContentModeScaleAspectFit;
        [activitypic setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",newHostUrl,_goods.goods_url]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
        [picView addSubview:activitypic];
        
        place = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(200 + 30 + 30), FitRealValue(26), 150, 20)];
        place.textColor = QDXBlack;
        place.font = [UIFont systemFontOfSize:15];
        place.text = _goods.goods_cn;
        [activity addSubview:place];
        
        details = [[UILabel alloc] initWithFrame:CGRectMake(place.frame.origin.x, FitRealValue(26 ) + 20, FitRealValue(360), FitRealValue(60))];
//        details.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        details.numberOfLines = 0;
        details.font = [UIFont fontWithName:@"Arial" size:11];
        details.textColor = QDXGray;
        details.text = _goods.goods_address;
        [activity addSubview:details];
        
        // ------View出现动画
        self.deliverView.transform = CGAffineTransformMakeTranslation(0.01, QdxHeight);
        [UIView animateWithDuration:0.3 animations:^{
            self.deliverView.transform = CGAffineTransformMakeTranslation(0.01, 0.01);
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)setUpPriceFont
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];
    [string appendString:@"总计:" withColor:QDXGray font:[UIFont systemFontOfSize:13]];
    [string appendString:@"¥" withColor:QDXOrange font:[UIFont systemFontOfSize:14]];
    NSRange range = [[NSString stringWithFormat:@"%.2f",_totalPrice]  rangeOfString:@"."];
    NSString *a = [NSString stringWithFormat:@"%.2f",_totalPrice];
    [string appendString:[a substringToIndex:(int)range.location] withColor:QDXOrange font:[UIFont systemFontOfSize:24]];
    [string appendString:[a substringFromIndex:(int)range.location] withColor:QDXOrange font:[UIFont systemFontOfSize:14]];
    _price.attributedText = string;
}

/**
 * 功能： View退出
 */
- (void)exitClick {
    
    if (quantity >1) {
        [self payDataWithNumber:[NSString stringWithFormat:@"%d",quantity] isPush:NO];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.deliverView.transform = CGAffineTransformMakeTranslation(0.01, QdxHeight);
        self.deliverView.alpha = 0.2;
        self.BGView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.BGView removeFromSuperview];
        [self.deliverView removeFromSuperview];
    }];
}

-(void)pay{
    
    [self exitClick];
    [self payDataWithNumber:[NSString stringWithFormat:@"%d",quantity] isPush:YES];
}

- (void)addClick{
    if(quantity == 99){
        return;
    }else{
        quantity++;
        _numberLabel.text = [NSString stringWithFormat:@"%d",quantity];
        _totalPrice = [self.goods.goods_price floatValue] * quantity;
        [self setUpPriceFont];
    }
}

- (void)minClick{
    if(quantity == 1){
        return;
    }else{
        quantity--;
        _numberLabel.text = [NSString stringWithFormat:@"%d",quantity];
        _totalPrice = [self.goods.goods_price floatValue] * quantity;
        [self setUpPriceFont];
    }
}

- (void)payDataWithNumber:(NSString *)number isPush:(BOOL)boolean
{
    NSString *url = [newHostUrl stringByAppendingString:addOrdersUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    params[@"goods_id"] = _goods.goods_id;
    params[@"orders_quantity"] = number;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        int ret = [responseObject[@"Code"] intValue];
        if (ret == 1) {
            
            Orders *orders = [[Orders alloc] initWithDic:responseObject[@"Msg"]];
            self.orders = orders;
            
            if (boolean == YES) {
                QDXOrderDetailTableViewController* QDetailVC=[[QDXOrderDetailTableViewController alloc]init];
                QDetailVC.orders = _orders;
                [self.navigationController pushViewController:QDetailVC animated:YES];
            }else{
                quantity = [self.orders.orders_quantity intValue];
                _numberLabel.text = self.orders.orders_quantity;
                _totalPrice = [self.goods.goods_price floatValue] * quantity;
                [self setUpPriceFont];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pay" object:nil];
        }else{
            quantity = 1;
            _numberLabel.text = [NSString stringWithFormat:@"%d",quantity];
        }
    } failure:^(NSError *error) {
        
    }];
}

//- (UIImage*)screenView:(UIView *)view{
//    CGRect rect = view.frame;
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
////        要导航栏的话把[view.layer renderInContext:context]改成
//    [self.navigationController.view.layer renderInContext:context];
////    [view.layer renderInContext:context];
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return img;
//}

- (UIImage *)captureScrollView:(UIScrollView *)scrollView{
    UIImage* image = nil;
    UIGraphicsBeginImageContext(scrollView.contentSize);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    if (image != nil) {
        return image;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
