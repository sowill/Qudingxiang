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
@class MineModel;
@interface QDXGameViewController : BaseViewController<CBCentralManagerDelegate,CBPeripheralDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,MAMapViewDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) MineModel *model;
@end