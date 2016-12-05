//
//  XBTestTableViewController.h
//  XBScrollPageControllerDemo
//
//  Created by Scarecrow on 15/9/8.
//  Copyright (c) 2015年 xiu8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QDXStateView.h"

@interface XBTestTableViewController : BaseViewController<StateDelegate>
//XBScrollPageController 传参
@property (nonatomic,copy) NSString *XBParam;
@end
