//
//  HomeCell.h
//  Qudingxiang
//
//  Created by Mac on 15/10/22.
//  Copyright © 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CellModel;
@interface HomeCell : UITableViewCell
@property (nonatomic, strong) CellModel *model;
+ (instancetype)baseCellWithTableView:(UITableView *)tableView;
@end
