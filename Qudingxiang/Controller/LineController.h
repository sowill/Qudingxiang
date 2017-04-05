//
//  LineController.h
//  Qudingxiang
//
//  Created by Mac on 15/9/18.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LineList;
@interface LineController : BaseViewController
@property (nonatomic, strong) NSString *click;
@property (nonatomic, strong) NSString *ticketID;
@property (nonatomic, strong) LineList *lineList;

@property (nonatomic, strong) void (^LineClickBlock)();
@end
