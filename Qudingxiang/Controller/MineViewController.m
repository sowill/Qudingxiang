//
//  MineViewController.m
//  趣定向
//
//  Created by Prince on 16/4/11.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "MineViewController.h"
#import "QDXChangeNameViewController.h"
#import "QDXLoginViewController.h"
#import "MineLineController.h"
#import "TeamLineController.h"
#import "SettingViewController.h"
#import "AboutUsViewController.h"
#import "HomeController.h"
#import "MineService.h"
#import "MineModel.h"
#import "UpdateService.h"
#import "QDXNavigationController.h"
#import "SignViewController.h"
#import "UIImage+RTTint.h"

@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSDictionary *_peopleDict;
    NSString *_name;
    NSString *_filePath;
    NSString *_path;
    UIImage *_im;
    UIButton *_picBtn;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIImageView *bgimageView;
@property (nonatomic,strong) UIVisualEffectView *effectView;
@property (nonatomic,assign) CGFloat lastOffsetY;
@property (nonatomic,strong) UIImageView *imageView;
@end

@implementation MineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateRefresh) name:@"stateRefresh" object:nil];
    
    [self netData];
    
    self.view.backgroundColor = QDXBGColor;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bgimageView];
    [self.bgimageView addSubview:self.effectView];
    [self.view addSubview:self.imageView];
}

-(void)stateRefresh
{
    [self netData];
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = QDXBGColor;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        CGFloat headImvH = FitRealValue(400);
        //这句很重要
        _tableView.contentInset = UIEdgeInsetsMake(headImvH-20, 0, 0, 0);
    }
    return _tableView;
}

-(UIImageView *)bgimageView
{
    if (!_bgimageView) {
        _bgimageView = [[UIImageView alloc] init];
        _bgimageView.frame = CGRectMake(0, 0, QdxWidth,FitRealValue(400));
        _bgimageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgimageView.clipsToBounds = YES;
    }
    return _bgimageView;
}

-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = CGRectMake(QdxWidth/2 - FitRealValue(60),FitRealValue(120),FitRealValue(150),FitRealValue(150));
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        _imageView.layer.cornerRadius = CGRectGetHeight(_imageView.bounds)/2;
        NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/image/%@.png",NSHomeDirectory(),@"image"];
        _path = aPath3;
        UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:aPath3];
        
        if(_im){
            _imageView.image = imgFromUrl3;
            self.bgimageView.image = imgFromUrl3;
        }else{
            if([save length] != 0){
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,_peopleDict[@"Msg"][@"headurl"]]];
                
                [_imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"my_head"]];
                [self.bgimageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Airbnb00"]];
            }else{
                _imageView.image = [UIImage imageNamed:@"my_head"];
            }
        }
        
        _picBtn = [[UIButton alloc] init];
        _picBtn.frame = _imageView.bounds;
        [_picBtn addTarget:self action:@selector(updatahead) forControlEvents:UIControlEventTouchUpInside];
        [_imageView addSubview:_picBtn];
    }
    return _imageView;
}

-(UIVisualEffectView *)effectView
{
    if (!_effectView) {
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _effectView.frame = CGRectMake(0, 0, QdxWidth,FitRealValue(400));
        _effectView.userInteractionEnabled = YES;
        _effectView.alpha = .5f;
    }
    return _effectView;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //拿到偏移量
    CGFloat offsetY = scrollView.contentOffset.y;
    NSInteger headImvH = FitRealValue(400) ;
    CGFloat offset = headImvH + offsetY;//计算偏移量
    
    //设置头部图片大小
    self.bgimageView.frame = CGRectMake(0, 0, QdxWidth, headImvH-offset);
    self.effectView.frame = CGRectMake(0, 0, QdxWidth, headImvH-offset);
    
    _imageView.frame = CGRectMake(QdxWidth/2 - FitRealValue(60),FitRealValue(120) - offset,FitRealValue(150),FitRealValue(150));
}

- (void)netData
{
    [MineService cellDataBlock:^(NSDictionary *dict) {
        NSDictionary* _dic = [[NSDictionary alloc] initWithDictionary:dict];
        _peopleDict=[NSDictionary dictionaryWithDictionary:_dic];
        if ([_peopleDict[@"Code"] intValue] == 0) {
            NSFileManager * fileManager = [[NSFileManager alloc]init];
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
            [fileManager removeItemAtPath:documentDir error:nil];
        }else{
            if ([save length] == 0 ) {
                NSFileManager * fileManager = [[NSFileManager alloc]init];
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
                [fileManager removeItemAtPath:documentDir error:nil];
            }else{
                
            }
        }
        [_tableView reloadData];
        
    } FailBlock:^(NSMutableArray *array) {
        
    } andWithToken:save];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(90);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 7;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 6) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0,0, 0,0)];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0,0, 0,0)];
        }
    }else{
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0,FitRealValue(24), 0,FitRealValue(24))];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0,FitRealValue(24), 0, FitRealValue(24))];
        }
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if(indexPath.row == 0){
        if ([save length] == 0) {
            cell.textLabel.text = @"昵称";
        }else{
            cell.textLabel.text = _peopleDict[@"Msg"][@"customer_name"];
        }
        cell.imageView.image = [[UIImage imageNamed:@"my_name"] rt_tintedImageWithColor:QDXBlack level:1.f];
    }else if(indexPath.row == 1){
        if ([_peopleDict[@"Code"] intValue] == 0) {
            cell.textLabel.text = @"账号";
        }else{
            cell.textLabel.text =_peopleDict[@"Msg"][@"code"];
        }
        cell.userInteractionEnabled = NO;
        cell.imageView.image = [[UIImage imageNamed:@"my_account"] rt_tintedImageWithColor:QDXBlack level:1.f];
    }else if(indexPath.row == 2){
        cell.textLabel.text = @"我的路线";
        cell.imageView.image = [[UIImage imageNamed:@"my_line"] rt_tintedImageWithColor:QDXBlack level:1.f];
    }else if(indexPath.row == 3){
        cell.textLabel.text = @"团队线路";
        cell.imageView.image = [[UIImage imageNamed:@"my_line"] rt_tintedImageWithColor:QDXBlack level:1.f];
    }else if(indexPath.row == 4){
        cell.textLabel.text = @"设置";
        cell.imageView.image = [[UIImage imageNamed:@"my_setup"] rt_tintedImageWithColor:QDXBlack level:1.f];
    }else if(indexPath.row == 5){
        cell.textLabel.text = @"关于趣定向";
        cell.imageView.image = [[UIImage imageNamed:@"my_about"] rt_tintedImageWithColor:QDXBlack level:1.f];
    }else if(indexPath.row == 6){
        cell.textLabel.text = @"联系客服";
        cell.imageView.image = [[UIImage imageNamed:@"my_service"] rt_tintedImageWithColor:QDXBlack level:1.f];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([save length] == 0) {
        [self login];
    }else{
        if(indexPath.row == 0){
            QDXChangeNameViewController* regi=[[QDXChangeNameViewController alloc]init];
            regi.cusName = _peopleDict[@"Msg"][@"customer_name"];
            regi.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:regi animated:YES];
        }else if (indexPath.row == 1){
            
        }else if (indexPath.row == 2){
            
            MineLineController *mineVC = [[MineLineController alloc] init];
            mineVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mineVC animated:YES];
            
        }else if (indexPath.row == 3){
            
            TeamLineController *teamVC = [[TeamLineController alloc] init];
            teamVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:teamVC animated:YES];
            
        }else if (indexPath.row == 4){
            
            SettingViewController *setVC = [[SettingViewController alloc] init];
            setVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:setVC animated:YES];
            
        }else if (indexPath.row == 5){
            
            AboutUsViewController *aboutVC = [[AboutUsViewController alloc] init];
            aboutVC.level =  _peopleDict[@"Msg"][@"level"];
            aboutVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:aboutVC animated:YES];
            
        }else if (indexPath.row == 6){
            
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
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSData *data;
    
    if (UIImagePNGRepresentation(image) == nil) {
        
        data = UIImageJPEGRepresentation(image, 1);
        
    } else {
        
        data = UIImagePNGRepresentation(image);
        
    }
    NSData *imgData= data;
    long len = imgData.length/1024;
    float off =1.0f;
    while (len >1048) {
        off -= 0.01;
        imgData= UIImageJPEGRepresentation(image, off);
        len = imgData.length/1024;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    _filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"image"];         //将图片存储到本地documents
    [fileManager createDirectoryAtPath:_filePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [fileManager createFileAtPath:[_filePath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
    NSString *url = [NSString stringWithFormat:@"%@%@",hostUrl,imageUrl];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    //2.上传文件
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imgData name:@"imgfile" fileName:_path mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印下上传进度
//        NSLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"headurl"] = result;
        params[@"TokenKey"] = save;
        [manager POST:[hostUrl stringByAppendingString:@"index.php/Home/Customer/modify"] parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary * dict = [NSDictionary dictionaryWithDictionary:responseObject];
            if([dict[@"Code"] intValue] == 1){
                NSString *token = dict[@"Msg"][@"token"];
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
                [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
                [NSKeyedArchiver archiveRootObject:token toFile:XWLAccountFile];
                //[_tableView reloadData];
                
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
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
