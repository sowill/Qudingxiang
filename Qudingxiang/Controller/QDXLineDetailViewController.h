//
//  QDXLineDetailViewController.h
//  Qudingxiang
//
//  Created by Air on 15/9/21.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeModel;
@class ActModel;
@interface QDXLineDetailViewController : BaseViewController
@property (nonatomic, strong) HomeModel *homeModel;
@property (nonatomic, strong) ActModel *actModel;
@end
