//
//  CYAlertViewManager.h
//  趣定向
//
//  Created by Air on 2016/12/9.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYAlertController.h"

@interface CYAlertViewManager : NSObject
+(instancetype)sharedInstance;
@property (strong, nonatomic) CYAlertController* CYAlertVC;
@end
