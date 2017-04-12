//
//  QDXOffLineController.h
//  趣定向
//
//  Created by Air on 16/3/24.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AudioToolbox/AudioToolbox.h>

@interface QDXOffLineController : BaseViewController<CBCentralManagerDelegate,CBPeripheralDelegate,UIAlertViewDelegate>
@end
