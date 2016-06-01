//
//  QDXPayTableViewController.h
//  趣定向
//
//  Created by Air on 16/1/18.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDXOrdermodel;
@class QDXTicketInfoModel;
@interface QDXPayTableViewController : UIViewController
@property(nonatomic,retain) QDXOrdermodel *Order;
@property(nonatomic,retain) QDXTicketInfoModel *ticketInfo;
@end
