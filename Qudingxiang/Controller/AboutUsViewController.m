//
//  AboutUsViewController.m
//  趣定向
//
//  Created by Prince on 16/3/17.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "AboutUsViewController.h"
#import "NoticeViewController.h"
#import "TabbarController.h"
@interface AboutUsViewController ()<UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSString *_strVersion;
    UITableView *_tableView;
}
@end

@implementation AboutUsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"关于趣定向";
    self.view.backgroundColor = [UIColor whiteColor];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    _strVersion = [NSString stringWithFormat:@"V%@",[infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    [self createTableView];
    [self createButtonBack];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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
    
    [self.sideMenuViewController setContentViewController:[[TabbarController alloc] init]
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];}

- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = NO;
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    _tableView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    [self.view addSubview:_tableView];
    UILabel *coChinese = [ToolView createLabelWithFrame:CGRectMake(0, QdxHeight-90, QdxWidth, 10) text:@"趣定向体育科技发展(上海)有限公司" font:12 superView:self.view];
    coChinese.textAlignment = NSTextAlignmentCenter;
    coChinese.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ID";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        if(indexPath.section == 1){
            UILabel *label = [ToolView createLabelWithFrame:CGRectMake(10, 10, 100, 24) text:@"活动须知" font:14 superView:cell];
            label.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else if(indexPath.section == 0){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImageView *imageIcon = [ToolView createImageWithFrame:CGRectMake(QdxWidth/2-22.5, 25, 55, 55)];
            imageIcon.image = [UIImage imageNamed:@"icon"];
            imageIcon.backgroundColor = [UIColor colorWithRed:35/255.0 green:164/255.0 blue:248/255.0 alpha:1];            [cell addSubview:imageIcon];
            UIButton *version = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth/2-20, 85, 50, 20)];
            [version setTitle:_strVersion forState:UIControlStateNormal];
            version.titleLabel.font = [UIFont systemFontOfSize:14];
            [version setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [cell addSubview:version];
            UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 115, QdxWidth-20, 100)];
            //desLabel.text = @"        趣定向是国内首家定向运动互联网增值服务平台运营商，同时也是国内最大的城市定向系列赛事的发起者和组织者。以‘趣定向，趣生活’为理念，倡导全民户外定向运动。现已覆盖上海多家公园。";
            //desLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
            //desLabel.font = [UIFont systemFontOfSize:14];
            desLabel.numberOfLines = 0;
            if (QdxWidth>320) {
                NSDictionary *attributesDic = [self settingAttributesWithLineSpacing:3 FirstLineHeadIndent:2 * 14 Font:[UIFont systemFontOfSize:15] TextColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1]];
                desLabel.attributedText = [[NSAttributedString alloc] initWithString:@"趣定向是国内首家定向运动互联网增值服务平台运营商，同时也是国内最大的城市定向系列赛事的发起者和组织者。以‘趣定向，趣生活’为理念，倡导全民户外定向运动。现已覆盖上海多家公园。" attributes:attributesDic];
            }else{
                NSDictionary *attributesDic = [self settingAttributesWithLineSpacing:3 FirstLineHeadIndent:2 * 14 Font:[UIFont systemFontOfSize:14] TextColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1]];
                desLabel.attributedText = [[NSAttributedString alloc] initWithString:@"趣定向是国内首家定向运动互联网增值服务平台运营商，同时也是国内最大的城市定向系列赛事的发起者和组织者。以‘趣定向，趣生活’为理念，倡导全民户外定向运动。现已覆盖上海多家公园。" attributes:attributesDic];
                
            }
            
            
            [cell addSubview:desLabel];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 225;
    }else{
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 1) {
        NoticeViewController *noticeVC = [[NoticeViewController alloc] init];
        [self.navigationController pushViewController:noticeVC animated:YES];
    }
}
- (void)createUI
{
    UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [share addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    [share setImage:[UIImage imageNamed:@"food_wall_icon_share"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:share];
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        share.hidden = YES;
    }else{
        share.hidden = NO;
    }
    
    UIImageView *imageBg = [ToolView createImageWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-64)];
    imageBg.image = [UIImage imageNamed:@""];
    imageBg.backgroundColor = [UIColor clearColor];
    imageBg.userInteractionEnabled = YES;
    [self.view addSubview:imageBg];
    UIImageView *imageIcon = [ToolView createImageWithFrame:CGRectMake(QdxWidth/2-38, QdxHeight/7, 76, 76)];
    CGFloat imageIconMaxY = CGRectGetMaxY(imageIcon.frame);
    imageIcon.image = [UIImage imageNamed:@"Icon-76@2x"];
    [imageBg addSubview:imageIcon];
    UIButton *version = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth/2-25, imageIconMaxY+20, 50, 20)];
    [version setTitle:_strVersion forState:UIControlStateNormal];
    version.titleLabel.font = [UIFont systemFontOfSize:13];
    [version setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [imageBg addSubview:version];
    CGFloat versionMaxY = CGRectGetMaxY(version.frame);
    UIButton *telephone = [[UIButton alloc] initWithFrame:CGRectMake(0, versionMaxY+100, QdxWidth, 30)];
    [telephone setTitle:[NSString stringWithFormat:@"电话:400-820-3899"] forState:UIControlStateNormal];
    telephone.titleLabel.font = [UIFont systemFontOfSize:15];
    [telephone setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [telephone addTarget:self action:@selector(takeTelephone) forControlEvents:UIControlEventTouchUpInside];
    [imageBg addSubview:telephone];
    
    UIButton *download = [[UIButton alloc] initWithFrame:CGRectMake(0, versionMaxY+130, QdxWidth, 30)];
    [download setTitle:[NSString stringWithFormat:@"趣定向官网"] forState:UIControlStateNormal];
    download.titleLabel.font = [UIFont systemFontOfSize:15];
    [download setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [download addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
    [imageBg addSubview:download];
    
    UILabel *coChinese = [ToolView createLabelWithFrame:CGRectMake(0, QdxHeight-25-64, QdxWidth, 10) text:@"趣定向体育科技发展(上海)有限公司" font:15 superView:imageBg];
    coChinese.textAlignment = NSTextAlignmentCenter;
    coChinese.textColor = [UIColor grayColor];
    
}

- (NSDictionary *)settingAttributesWithLineSpacing:(CGFloat)lineSpacing FirstLineHeadIndent:(CGFloat)firstLineHeadIndent Font:(UIFont *)font TextColor:(UIColor *)textColor{
    //分段样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //行间距
    paragraphStyle.lineSpacing = lineSpacing;
    //首行缩进
    paragraphStyle.firstLineHeadIndent = firstLineHeadIndent;
    //富文本样式
    NSDictionary *attributeDic = @{
                                   NSFontAttributeName : font,
                                   NSParagraphStyleAttributeName : paragraphStyle,
                                   NSForegroundColorAttributeName : textColor
                                   };
    return attributeDic;
}
-(void)shareClick
{
    NSArray *shareButtonTitleArray = [[NSArray alloc] init];
    NSArray *shareButtonImageNameArray = [[NSArray alloc] init];
    shareButtonTitleArray = @[@"QQ",@"QQ空间",@"微信",@"朋友圈"];
    shareButtonImageNameArray = @[@"sns_icon_24@2x",@"sns_icon_6@2x",@"sns_icon_22@2x",@"sns_icon_23@2x"];
    LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:@"分享到社交平台" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
    [lxActivity showInView:self.view];
    
}

#pragma mark - LXActivityDelegate

- (void)didClickOnImageIndex:(NSInteger *)imageIndex
{
    NSString *utf8String =@"http://a.app.qq.com/o/simple.jsp?pkgname=com.oketion.srt";
    NSString *title = @"趣定向";
    NSString *description = @"趣定向下载";
    if (imageIndex == 0) {
        TencentOAuth *auth = [[TencentOAuth alloc] initWithAppId:@"1104830915"andDelegate:self];
        NSString *imgPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icon-76.png"];
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:[NSURL URLWithString:utf8String] title:title description:description previewImageData:imgData];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    } else if (imageIndex == 1){
        TencentOAuth *auth = [[TencentOAuth alloc] initWithAppId:@"1104830915"andDelegate:self];
        NSString *imgPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icon-76.png"];
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:[NSURL URLWithString:utf8String] title:title description:description previewImageData:imgData];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    }else if (imageIndex == 2){
        WXMediaMessage *mess = [[WXMediaMessage alloc] init];
        mess.title = title;
        mess.description = description;
        [mess setThumbImage:[UIImage imageNamed:@"Icon-76"]];
        
        WXWebpageObject *web = [WXWebpageObject object];
        web.webpageUrl = utf8String;
        mess.mediaObject = web;
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = mess;
        req.scene = WXSceneSession;
        [WXApi sendReq:req];
    }else if (imageIndex == 3){
        WXMediaMessage *mess = [[WXMediaMessage alloc] init];
        mess.title = title;
        mess.description = description;
        [mess setThumbImage:[UIImage imageNamed:@"Icon-76"]];
        WXWebpageObject *web = [WXWebpageObject object];
        web.webpageUrl = utf8String;
        mess.mediaObject = web;
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = mess;
        req.scene = WXSceneTimeline;
        [WXApi sendReq:req];
    }
}

- (void)download
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-64)];
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.qudingxiang.cn"]]]];
    
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
