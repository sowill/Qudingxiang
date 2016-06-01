//
//  QDXOrderTableViewCell.h
//  趣定向
//
//  Created by Air on 16/1/21.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDXOrdermodel;
@interface QDXOrderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orders_name;
@property (weak, nonatomic) IBOutlet UILabel *orders_ct;
@property (weak, nonatomic) IBOutlet UILabel *orders_am;
@property (weak, nonatomic) IBOutlet UILabel *ostatus_name;
@property (nonatomic, strong) QDXOrdermodel *order;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
