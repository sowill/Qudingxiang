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
#import "myViewCellTableViewCell.h"
#import "UpdateService.h"
#import "QDXNavigationController.h"
#import "SignViewController.h"
@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UITableView *_tableView;
    NSDictionary *_peopleDict;
    NSString *_name;
    NSString *_acount;
    NSMutableArray *_dataArr;
    UILabel *_label;
    UIImageView *_imageView;
    UIImage *_image;
    UIButton *_picBtn;
    NSString *_filePath;
    NSString *_path;
    NSString *_data;
    NSData *_imageData;
    UIImage *_im;
    NSString *_imageName;
    NSString *_signText;
}
@end

@implementation MineViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self netData];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _peopleDict=[[NSDictionary alloc]init];
    [self createTableView];
    
    
    
}

- (void)createTableView
{
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageview.image = [UIImage imageNamed:@"my_bg.jpg"];
    imageview.userInteractionEnabled = YES;
    [self.view addSubview:imageview];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    _tableView.opaque = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.separatorStyle = NO;;
    _tableView.bounces = NO;
    
    [self.view addSubview:_tableView];
    
    
    
    
}

- (void)netData
{
    [MineService cellDataBlock:^(NSMutableDictionary *dict) {
        NSDictionary* _dic = [[NSDictionary alloc] initWithDictionary:dict];
        NSLog(@"%@",_dic);
        _peopleDict=[NSDictionary dictionaryWithDictionary:_dic];
        if([_peopleDict[@"Code"] integerValue] == 0){
            NSFileManager * fileManager = [[NSFileManager alloc]init];
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
            [fileManager removeItemAtPath:documentDir error:nil];
        }else{
            [_tableView reloadData];
        }
        
    } FailBlock:^(NSMutableArray *array) {
        
    } andWithToken:save];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth,QdxWidth/4)];
        view.userInteractionEnabled = YES;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20,64,47,47)];
        _imageView.clipsToBounds = YES;
        _imageView.layer.cornerRadius = CGRectGetHeight(_imageView.bounds)/2;
        _imageView.userInteractionEnabled = YES;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,_peopleDict[@"Msg"][@"headurl"]]];
        NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/image/%@.png",NSHomeDirectory(),@"image"];
        _path = aPath3;
        UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:aPath3];
        
        if(_im){
            _imageView.image = imgFromUrl3;
        }else{
            [_imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"my_head"]];
        }
        
        [view addSubview:_imageView];
        _picBtn = [[UIButton alloc] init];
        _picBtn.frame = CGRectMake(20,64,47,47);
        _picBtn.imageView.clipsToBounds = YES;
        _picBtn.imageView.layer.cornerRadius = CGRectGetHeight(_picBtn.bounds)/2;
        //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,_peopleDict[@"Msg"][@"headurl"]]];
        //[_picBtn.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"my_head"]];
        //        [_picBtn setImage:imgFromUrl3 forState:UIControlStateNormal];
        
        [_picBtn addTarget:self action:@selector(updatahead) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:_picBtn];
        
        CGFloat headBtnMaxY = CGRectGetMaxY(_picBtn.frame);
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, headBtnMaxY+30, QdxWidth,1)];
        lineView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];
        [view addSubview:lineView];
        
        UIButton *signBtn = [[UIButton alloc] init];
        signBtn.frame = CGRectMake(20,headBtnMaxY+35,QdxWidth*4/5,42);
        [signBtn setTitle:_peopleDict[@"Msg"][@"signature"] forState:UIControlStateNormal];
        [signBtn setTintColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]];
        signBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        signBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        signBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [signBtn addTarget:self action:@selector(signbtn) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:signBtn];
        
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(20, headBtnMaxY+80, QdxWidth,1)];
        lineView1.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];
        [view addSubview:lineView1];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(QdxWidth>320){
        return 54;
    }else
    {
        return 35;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 200;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdetify = @"SvTableViewCell";
    myViewCellTableViewCell* cell=(myViewCellTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"myViewCellTableViewCell" owner:self options:nil]lastObject];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.row == 0){
        cell._name.text = _peopleDict[@"Msg"][@"customer_name"];
        cell._id.text= nil;
        cell.imageV.image = [UIImage imageNamed:@"my_name"];
    }else if(indexPath.row == 1){
        cell._name.text =_peopleDict[@"Msg"][@"code"];
        cell._id.text= nil;
        cell.userInteractionEnabled = NO;
        cell.imageV.image = [UIImage imageNamed:@"my_account"];
    }else if(indexPath.row == 2){
        cell._name.text = @"我的路线";
        cell._id.text= nil;
        cell.imageV.image = [UIImage imageNamed:@"my_line"];
    }else if(indexPath.row == 3){
        cell._name.text = @"团队线路";
        cell._id.text= nil;
        cell.imageV.image = [UIImage imageNamed:@"my_line"];
    }else if(indexPath.row == 4){
        cell._name.text = @"设置";
        cell._id.text= nil;
        cell.imageV.image = [UIImage imageNamed:@"my_setup"];
    }else if(indexPath.row == 5){
        cell._name.text = @"关于趣定向";
        cell._id.text= nil;
        cell.imageV.image = [UIImage imageNamed:@"my_about"];
    }else if(indexPath.row == 6){
        cell._name.text = @"联系客服";
        cell._id.text= nil;
        cell.imageV.image = [UIImage imageNamed:@"my_service"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(indexPath.row == 0){
        QDXChangeNameViewController* regi=[[QDXChangeNameViewController alloc]init];
        regi.cusName = _peopleDict[@"Msg"][@"customer_name"];
        [self.sideMenuViewController hideMenuViewController];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:regi];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
        
    }else if (indexPath.row == 1){
        
    }else if (indexPath.row == 2){
        MineLineController *mineVC = [[MineLineController alloc] init];
        QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:mineVC];
        [self.sideMenuViewController setContentViewController:navController
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }else if (indexPath.row == 3){
        TeamLineController *teamVC = [[TeamLineController alloc] init];
        QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:teamVC];
        [self.sideMenuViewController setContentViewController:navController
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }else if (indexPath.row == 4){
        
        SettingViewController *setVC = [[SettingViewController alloc] init];
        [self.sideMenuViewController hideMenuViewController];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:setVC];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
    }else if (indexPath.row == 5){
        AboutUsViewController *aboutVC = [[AboutUsViewController alloc] init];
        UINavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:aboutVC];
        [self.sideMenuViewController setContentViewController:navController
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
        
    }else if (indexPath.row == 6){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"400-820-3899" message:@"客服工作时间:09:00-18:00" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *callStr = [NSString stringWithFormat:@"tel:4008203899"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callStr]];
        }]];
    }
    
}

- (void)updatahead
{
    //创建UIAlertController是为了让用户去选择照片来源,拍照或者相册.
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:0];
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"从相册选取" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"拍照" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
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
        NSLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //[_imageView setImage:[UIImage imageWithContentsOfFile:_path]];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"headurl"] = result;
        params[@"TokenKey"] = save;
        [manager POST:@"http://www.qudingxiang.cn/Home/Customer/modify" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
            
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
        NSLog(@"请求失败：%@",error);
    }];
    
}


- (void)login
{
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
    [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
    
    QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:regi];
    regi.hidesBottomBarWhenPushed = YES;
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)signbtn
{
    SignViewController *sign = [[SignViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sign];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)updatePortrait
{
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
