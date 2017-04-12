//
//  ActCell.h
//  Qudingxiang
//
//  Created by Mac on 15/9/22.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ActModel;
@interface ActCell : UITableViewCell
@property (nonatomic, strong)ActModel *model;
+ (instancetype)actCellWithTableView:(UITableView *)tableView;
@end
