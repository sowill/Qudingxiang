//
//  ImagePickerController.h
//  趣定向
//
//  Created by Prince on 16/3/28.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartModel.h"
@protocol PassTicketIDDelegate
- (void)PassTicket:(NSString *)tictet andClick:(NSString *)click;
@end
@interface ImagePickerController : UIViewController
@property (nonatomic, strong) id<PassTicketIDDelegate>delegate;
@property (nonatomic, strong) NSString *from;
@property (nonatomic,copy)void(^ScanResult)(NSString*result,BOOL isSucceed,NSString *from);
-(id)initWithBlock:(void(^)(NSString*,BOOL,NSString*))a;
@end
