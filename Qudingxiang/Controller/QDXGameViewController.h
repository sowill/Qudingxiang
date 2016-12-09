//
//  QDXGameViewController.h
//  Qudingxiang
//
//  Created by Air on 15/9/29.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MineLineController.h"
#import "MineModel.h"

#import "CustomAnimateTransitionPush.h"

@class MineModel;
@interface QDXGameViewController : BaseViewController<CBCentralManagerDelegate,CBPeripheralDelegate,UINavigationControllerDelegate,MAMapViewDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property(strong, nonatomic) UIButton *history_button;

@property(strong, nonatomic) UIButton *task_button;

@property (nonatomic, strong) MineModel *model;
@end
