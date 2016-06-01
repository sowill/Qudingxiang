//
//  QDXTeamsViewController.h
//  Qudingxiang
//
//  Created by Air on 15/10/22.
//  Copyright © 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineModel.h"
@class MineModel;
//@protocol PassPlayerInfoDelegate
//- (void)passInfo:(NSString *)info;
//@end
@interface QDXTeamsViewController : UIViewController
@property (nonatomic, strong) NSString *myLineid;
@property (nonatomic, strong) MineModel *model;
//@property (nonatomic, retain) id<PassPlayerInfoDelegate>delegate;
@end
