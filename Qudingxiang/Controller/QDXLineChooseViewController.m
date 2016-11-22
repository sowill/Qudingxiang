//
//  QDXLineChooseViewController.m
//  Qudingxiang
//
//  Created by Air on 15/10/8.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "QDXLineChooseViewController.h"
#import "QDXDetailsModel.h"
#import "LineModel.h"
#import "QDXGameViewController.h"
#import "QDXProtocolViewController.h"
#import "QDXNavigationController.h"
#import "QDXTeamsViewController.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import <QuartzCore/QuartzCore.h>
//#import "TabbarController.h"
#import "QDXNavigationController.h"
@interface QDXLineChooseViewController ()
{
    UIImageView *map;
    UILabel *place;
    UITextView *details;
    UIButton *ready;
}
@property (nonatomic,strong) UIScrollView *QDXScrollView;
@end

@implementation QDXLineChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupFrame];
    
    [self setupData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti2) name:@"noti2" object:nil];

}

- (void)noti2
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)setupFrame
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"选择路线";
    
    self.QDXScrollView =[[UIScrollView alloc] initWithFrame:self.view.frame];
    self.QDXScrollView.showsVerticalScrollIndicator = FALSE;
    [self.view addSubview:self.QDXScrollView];
    
    //添加地图
    map = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxWidth*0.59)];
    map.userInteractionEnabled = YES;
    [self.QDXScrollView addSubview:map];
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 2;
    [map addGestureRecognizer:tap];
    
    CGFloat MaxMapY = CGRectGetMaxY(map.frame);
    UIView *placeBkg = [[UIView alloc] initWithFrame:CGRectMake(0, MaxMapY, QdxWidth, 45)];
    [placeBkg setBackgroundColor:[UIColor colorWithRed:147/255.0 green:230/255.0 blue:251/255.0 alpha:1]];
    [self.QDXScrollView addSubview:placeBkg];
    
    //添加地点label
    place = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 150, 30)];
    place.textColor = [UIColor colorWithRed:37/255.0 green:128/255.0 blue:250/255.0 alpha:1];
    place.font = [UIFont systemFontOfSize:18];
    [placeBkg addSubview:place];
    CGFloat lineY = CGRectGetMaxY(place.frame);
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(10, lineY, 80, 3)];
    line.image = [UIImage imageNamed:@"dd"];
    [placeBkg addSubview:line];
    UIImageView *line2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, lineY+3, QdxWidth, 45-lineY+3)];
    [line2 setBackgroundColor:[UIColor colorWithRed:120/255.0 green:214/255.0 blue:252/255.0 alpha:1]];
    [placeBkg addSubview:line2];
    
    CGFloat lineInfoY = CGRectGetMaxY(placeBkg.frame) + 10;
    UILabel *lineInfo = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth * 0.12, lineInfoY, 150, 30)];
    lineInfo.text = @"路线介绍";
    lineInfo.font = [UIFont systemFontOfSize:18];
    lineInfo.textColor = [UIColor colorWithRed:37/255.0 green:128/255.0 blue:250/255.0 alpha:1];
    [self.QDXScrollView addSubview:lineInfo];
    UIImageView *lineInfoImg = [[UIImageView alloc] initWithFrame:CGRectMake(QdxWidth * 0.05, lineInfoY, 20, 30)];
    lineInfoImg.image = [UIImage imageNamed:@"hongqi"];
    [self.QDXScrollView addSubview:lineInfoImg];
    
    //    UIView *horLine = [[UIView alloc] initWithFrame:CGRectMake(0, 355 , QdxWidth, 0.5)];
    //    [horLine setBackgroundColor:[UIColor grayColor]];
    //    [self.QDXScrollView addSubview:horLine];
    
    //添加详细信息
    CGFloat MaxPlaceY = CGRectGetMaxY(lineInfo.frame);
    details = [[UITextView alloc] initWithFrame:CGRectMake(10, MaxPlaceY +5, QdxWidth - 20, 350)];
    details.editable = NO;
    details.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    details.font = [UIFont fontWithName:@"Arial" size:17.0f];
    details.textColor = [UIColor grayColor];
    details.scrollEnabled = NO;
    [self.QDXScrollView addSubview:details];
    
    // 添加底部按钮
    ready = [[UIButton alloc] init];
    [ready setTitle:@"选择" forState:UIControlStateNormal];
    //[ready setBackgroundColor:[UIColor colorWithRed:49/255.0 green:121/255.0 blue:202/255.0 alpha:1]];
    CGFloat commitBtnCenterX = QdxWidth * 0.5;
    CGFloat commitBtnCenterY = QdxHeight - 90;
    ready.center = CGPointMake(commitBtnCenterX, commitBtnCenterY);
    ready.bounds = CGRectMake(0, 0, QdxWidth-20, 35);
    [ready setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [ready setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    [ready setBackgroundImage:[[UIImage imageNamed:@"sign_button"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [ready addTarget:self action:@selector(ready) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ready];
}

-(void)setupData
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"line_id"] = _model.line_id;
    NSString *url = [hostUrl stringByAppendingString:@"Home/Line/getInfoAjax"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret==1) {
            QDXDetailsModel *model = [[QDXDetailsModel alloc] init];
            [model setMap:infoDict[@"Msg"][@"area"][@"map"]];
            [model setArea_name:infoDict[@"Msg"][@"line_sub"]];
            [model setDescript:infoDict[@"Msg"][@"description"]];
            [map setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,model.map]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
            place.text = model.area_name;
            details.text = model.descript;
            
            CGRect orgRect=details.frame;
            CGSize  size = [details.text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(240, 2000) lineBreakMode:UILineBreakModeWordWrap];
            orgRect.size.height=size.height+10;
            [details setFrame:orgRect];
            
            [self refreshScrollView];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)ready
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定你所选择的比赛线路吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
        AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
        mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"TokenKey"] = save;
        params[@"line_id"] = _model.line_id;
        NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Myline/selectMyline"];
        [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
            int ret = [infoDict[@"Code"] intValue];
            if (ret == 1) {
                    QDXProtocolViewController *viewController = [[QDXProtocolViewController alloc] init];
                    [self.navigationController pushViewController:viewController animated:YES];
            }else{
                NSLog(@"qdxMsg= %@",infoDict[@"Msg"]);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }
    else
        if (buttonIndex ==0) {
            NSLog(@"点击了取消");
        }
}

-(void)refreshScrollView
{
    CGFloat scrollViewHeight = 0.0f;
    scrollViewHeight += details.frame.size.height + 450;
    [self.QDXScrollView setContentSize:(CGSizeMake(320, scrollViewHeight))];
}

- (void)bigButtonTapped:(id)sender
{
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = map.image;
    imageInfo.referenceRect = map.frame;
    imageInfo.referenceView = map.superview;
    imageInfo.referenceContentMode = map.contentMode;
    imageInfo.referenceCornerRadius = map.layer.cornerRadius;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
