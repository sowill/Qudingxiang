//
//  HomeController.h
//  Qudingxiang
//
//  Created by Mac on 15/9/15.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeModel;
@protocol PassTicketIDDelegate
- (void)PassTicket:(NSString *)tictet andClick:(NSString *)click;
@end
@interface HomeController : BaseViewController<UIImagePickerControllerDelegate>
@property (nonatomic, strong) NSString *pass;
@property (nonatomic, strong) HomeModel *model;
@property (nonatomic, strong) NSMutableArray *scrollArr;
@property (nonatomic, strong) HomeModel *model_tmp;
@property (nonatomic, strong) id<PassTicketIDDelegate>delegate;
@end
