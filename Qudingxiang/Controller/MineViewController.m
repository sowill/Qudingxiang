//
//  MineViewController.m
//  趣定向
//
//  Created by Prince on 16/4/11.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "MineViewController.h"
#import "editMineInfoViewController.h"
#import "QDXLoginViewController.h"
#import "MineLineController.h"
#import "TeamLineController.h"
#import "SettingViewController.h"
#import "AboutUsViewController.h"
#import "HomeController.h"
#import "QDXNavigationController.h"
#import "SignViewController.h"
#import "UIImage+RTTint.h"
#import "UIButton+ImageText.h"
#import "Customer.h"
#import "MineCardViewController.h"

@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSString *_name;
    NSString *_filePath;
    NSString *_path;
    UIImage *_im;
    UIButton *_picBtn;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIImageView *bgimageView;
@property (nonatomic,assign) CGFloat lastOffsetY;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIView *infoView;
@property (nonatomic,strong) UILabel *nameLab;
@property (nonatomic,strong) UIButton *phoneLab;
@property (nonatomic,strong) UILabel *signLab;
@property (nonatomic,strong) UIButton *editBtn;
@property (nonatomic,strong) Customer *peopleDict;
@end

@implementation MineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateRefresh) name:@"stateRefresh" object:nil];
    
    [self authLogin];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stateRefresh" object:nil];
}

-(void)stateRefresh
{
    [self authLogin];
}

-(void)authLogin
{
    NSString *url = [newHostUrl stringByAppendingString:authLoginUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        
        if ([responseObject[@"Code"] intValue] == 0) {
            NSFileManager *fileManager = [[NSFileManager alloc]init];
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
            [fileManager removeItemAtPath:documentDir error:nil];
        }else{
            Customer *customer = [[Customer alloc] initWithDic:responseObject[@"Msg"]];
            if ([save length] == 0 ) {
                NSFileManager * fileManager = [[NSFileManager alloc]init];
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
                [fileManager removeItemAtPath:documentDir error:nil];
            }else{
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
                [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
                [NSKeyedArchiver archiveRootObject:customer.customer_token toFile:XWLAccountFile];
                _peopleDict = customer;
            }
        }
        [self setupUI];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //拿到偏移量
    CGFloat offsetY = scrollView.contentOffset.y;
    NSInteger headImvH = FitRealValue(330) ;
    CGFloat offset = headImvH + offsetY;//计算偏移量
    
    //设置头部图片大小
    self.bgimageView.frame = CGRectMake(0, 0, QdxWidth, headImvH-offset);
    
    _infoView.frame = CGRectMake(FitRealValue(214), FitRealValue(138) - offset, QdxWidth - FitRealValue(214), FitRealValue(152));
    _imageView.frame = CGRectMake(FitRealValue(40),FitRealValue(138) - offset,FitRealValue(152),FitRealValue(152));
    
    if (scrollView == self.tableView){
        CGFloat sectionHeaderHeight = FitRealValue(20);
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        }else if(scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y<0){
            
            [UIView animateWithDuration:1.0 animations:^{
                scrollView.contentInset = UIEdgeInsetsMake(headImvH, 0, 0, 0);
            } completion:^(BOOL finished) {
                
            }];
            
        }else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

-(void)editBtnClick
{
    if ([save length] == 0) {
        [self signbtn];
    }else{
        editMineInfoViewController *editVC = [[editMineInfoViewController alloc] init];
        editVC.peopleDict = _peopleDict;
        editVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editVC animated:YES];
    }
}

-(void)setupUI
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = QDXBGColor;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat headImvH = FitRealValue(330);
    //这句很重要
    _tableView.contentInset = UIEdgeInsetsMake(headImvH, 0, 0, 0);
    [self.view addSubview:self.tableView];
    
    _bgimageView = [[UIImageView alloc] init];
    _bgimageView.frame = CGRectMake(0, 0, QdxWidth,FitRealValue(330));
    _bgimageView.contentMode = UIViewContentModeScaleAspectFill;
    _bgimageView.clipsToBounds = YES;
    _bgimageView.image = [UIImage imageNamed:@"背景"];
    [self.view addSubview:self.bgimageView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.frame = CGRectMake(FitRealValue(40),FitRealValue(138),FitRealValue(152),FitRealValue(152));
    _imageView.userInteractionEnabled = YES;
    _imageView.layer.cornerRadius = 3;
    NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/image/%@.png",NSHomeDirectory(),@"image"];
    _path = aPath3;
    UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:aPath3];
    
    if(_im){
        _imageView.image = imgFromUrl3;
    }else{
        if([save length] != 0){
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",newHostUrl,_peopleDict.customer_headurl]];
            
            [_imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"默认头像"]];
        }else{
            _imageView.image = [UIImage imageNamed:@"默认头像"];
        }
    }
    
    _picBtn = [[UIButton alloc] init];
    _picBtn.frame = _imageView.bounds;
    [_picBtn addTarget:self action:@selector(updatahead) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_picBtn];
    [self.view addSubview:self.imageView];
    
    _infoView = [[UIView alloc] initWithFrame:CGRectMake(FitRealValue(214), FitRealValue(138), QdxWidth - FitRealValue(214), FitRealValue(152))];
    _infoView.backgroundColor = [UIColor clearColor];
    
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(10), FitRealValue(10), FitRealValue(380), FitRealValue(36))];
    _nameLab.textColor = [UIColor whiteColor];
    _nameLab.font = [UIFont systemFontOfSize:17];
    if ([save length] == 0) {
        _nameLab.text = @"昵称";
    }else{
        _nameLab.text = _peopleDict.customer_cn;
    }
    [_infoView addSubview:_nameLab];
    
    _signLab = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(10), FitRealValue(10 + 36 + 20 + 36 + 20), FitRealValue(380), FitRealValue(36))];
    _signLab.textColor = [UIColor whiteColor];
    _signLab.font = [UIFont systemFontOfSize:12];
    
    if ([save length] == 0 || _peopleDict.customer_signature.length == 0) {
        _signLab.text = @"签名:";
    }else{
        _signLab.text = [@"签名:"stringByAppendingString:_peopleDict.customer_signature];
    }
    [_infoView addSubview:_signLab];
    
    _phoneLab = [[UIButton alloc] initWithFrame:CGRectMake(FitRealValue(10), FitRealValue(10 + 36 + 20), FitRealValue(200), FitRealValue(36))];
    [_phoneLab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _phoneLab.titleLabel.font = [UIFont systemFontOfSize:12];
    
    if ([save length] == 0 || _peopleDict.customer_code.length == 0) {
        [_phoneLab setTitle:@"************" forState:UIControlStateNormal];
    }else{
        NSMutableString * str1 = [[NSMutableString alloc]initWithString:_peopleDict.customer_code];
        [str1 deleteCharactersInRange:NSMakeRange(3,6)];
        [str1 insertString:@"******" atIndex:3];
        [_phoneLab setTitle:str1 forState:UIControlStateNormal];
    }
    [_phoneLab setImage:[UIImage imageNamed:@"iphone"] forState:UIControlStateNormal];
    [_phoneLab setImagePosition:0 WithMargin:0];
    [_infoView addSubview:_phoneLab];
    
    _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(FitRealValue(380), 0, QdxWidth - FitRealValue(214 + 380), FitRealValue(152))];
    _editBtn.titleLabel.textColor = [UIColor whiteColor];
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_editBtn setTitle:@"编辑资料" forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(editBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_infoView addSubview:_editBtn];

    [self.view addSubview:self.infoView];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,0, 0,0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,0, 0,0)];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return FitRealValue(20);
    }else if(section == 2){
        return FitRealValue(20);
    }else{
        return 0.1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return FitRealValue(148);
    }else{
        return FitRealValue(106);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 2;
    }else{
        return 2;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if (indexPath.section == 0) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(148))];
        lineView.backgroundColor = [UIColor whiteColor];
        [cell addSubview:lineView];
        
        UIButton *mylineBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, QdxWidth/2, FitRealValue(148))];
        [mylineBtn setTitle:@"我的线路" forState:UIControlStateNormal];
        [mylineBtn setImage:[UIImage imageNamed:@"我的线路icon"] forState:UIControlStateNormal];
        [mylineBtn setTitleColor:QDXBlack forState:normal];
        mylineBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [mylineBtn addTarget:self action:@selector(mylineBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [mylineBtn setImagePosition:2 spacing:1];
        [lineView addSubview:mylineBtn];
        
        UIButton *teamlineBtn = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth/2, 0, QdxWidth/2, FitRealValue(148))];
        [teamlineBtn setTitle:@"团队线路" forState:UIControlStateNormal];
        [teamlineBtn setImage:[UIImage imageNamed:@"团队线路icon"] forState:UIControlStateNormal];
        [teamlineBtn setTitleColor:QDXBlack forState:normal];
        teamlineBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [teamlineBtn addTarget:self action:@selector(teamlineBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [teamlineBtn setImagePosition:2 spacing:1];
        [lineView addSubview:teamlineBtn];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(QdxWidth/2, 0, FitRealValue(1), FitRealValue(148))];
        line.backgroundColor = QDXLineColor;
        [lineView addSubview:line];
        
    }else if(indexPath.row == 0 && indexPath.section == 1){
        cell.textLabel.text = @"我的卡包";
        cell.imageView.image = [UIImage imageNamed:@"我的卡包icon"];
    }else if(indexPath.row == 1 && indexPath.section == 1){
        cell.textLabel.text = @"我的设置";
        cell.imageView.image = [UIImage imageNamed:@"我的设置"];
    }else if(indexPath.row == 0 && indexPath.section == 2){
        cell.textLabel.text = @"关于我们";
        cell.imageView.image =  [UIImage imageNamed:@"关于我们"];
    }else if(indexPath.row == 1 && indexPath.section == 2){
        cell.textLabel.text = @"联系我们";
        cell.imageView.image =  [UIImage imageNamed:@"联系我们"];
    }
    return cell;
}

-(void)teamlineBtnClick
{
    if ([save length] == 0) {
        [self signbtn];
    }else{
        TeamLineController *teamVC = [[TeamLineController alloc] init];
        teamVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:teamVC animated:YES];
    }
}

-(void)mylineBtnClick
{
    if ([save length] == 0) {
        [self signbtn];
    }else{
        MineLineController *mineVC = [[MineLineController alloc] init];
        mineVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:mineVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([save length] == 0) {
        [self login];
    }else{
        if (indexPath.row == 0 && indexPath.section == 1) {
            
            MineCardViewController *cardVC = [[MineCardViewController alloc] init];
            cardVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:cardVC animated:YES];
            
        }else if (indexPath.row == 1 && indexPath.section == 1){
            
            SettingViewController *setVC = [[SettingViewController alloc] init];
            setVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:setVC animated:YES];
            
        }else if (indexPath.row == 0 && indexPath.section == 2){
            
            AboutUsViewController *aboutVC = [[AboutUsViewController alloc] init];
            aboutVC.level =  _peopleDict.customer_level;
            aboutVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:aboutVC animated:YES];
            
        }else if (indexPath.row == 1 && indexPath.section == 2){
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"400-820-3899" message:@"客服工作时间:09:30-18:30" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertController animated:YES completion:nil];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *callStr = [NSString stringWithFormat:@"tel:4008203899"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callStr]];
            }]];
        }
    }
}

- (void)updatahead
{
    if ([save length] == 0) {
        [self login];
    }else{
        //创建UIAlertController是为了让用户去选择照片来源,拍照或者相册.
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:0];
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"从相册选取" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            
            [self presentViewController:imagePickerController animated:YES completion:^{
                
            }];
        }];
        
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"拍照" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:imagePickerController animated:YES completion:^{

            }];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action)
                                       {
                                           //这里可以不写代码
                                       }];
        [self presentViewController:alertController animated:YES completion:nil];
        
        //用来判断来源 Xcode中的模拟器是没有拍摄功能的,当用模拟器的时候我们不需要把拍照功能加速
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];
            [alertController addAction:photoAction];
        }
        else
        {
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    //选取裁剪后的图片
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    _imageView.image = image;
    _im = image;

    NSData *data;
    
    if (UIImagePNGRepresentation(image) == nil) {
        
        data = UIImageJPEGRepresentation(image,1.f);
        
    } else {
        
        data = UIImagePNGRepresentation(image);
        
    }
    NSData *imageData= data;
    long len = imageData.length/1024;
    float off =1.0f;
    while (len >1048) {
        off -= 0.01;
        imageData= UIImageJPEGRepresentation(image, off);
        len = imageData.length/1024;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    _filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"image"];  //将图片存储到本地documents
    [fileManager createDirectoryAtPath:_filePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [fileManager createFileAtPath:[_filePath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",newHostUrl,getImageUrl];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    //2.上传文件
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:imageData name:@"imgfile" fileName:_path mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印下上传进度
        //        NSLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *url = [newHostUrl stringByAppendingString:modifyUrl];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"customer_headurl"] = result;
        params[@"customer_token"] = save;
        [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
            int ret = [responseObject[@"Code"] intValue];
            if (ret==1) {
                NSString *token = responseObject[@"Msg"][@"customer_token"];
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
                [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
                [NSKeyedArchiver archiveRootObject:token toFile:XWLAccountFile];
            }else{
                
            }
        } failure:^(NSError *error) {
            
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //请求失败
        //        NSLog(@"请求失败：%@",error);
    }];
}


- (void)login
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"登陆后才可使用此功能" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"立即登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        
        QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
        QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
        [self presentViewController:navController animated:YES completion:^{
            
        }];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"暂不登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)signbtn
{
    if ([save length] == 0) {
        [self login];
    }else{
        SignViewController *sign = [[SignViewController alloc] init];
        sign.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:sign animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
