//
//  BaseCell.h
//  Qudingxiang
//
//  Created by Mac on 15/9/16.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeModel;
@interface BaseCell : UITableViewCell
@property (nonatomic, strong)HomeModel *homeModel;
+ (instancetype)baseCellWithTableView:(UITableView *)tableView;
@end
