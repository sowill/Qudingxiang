//
//  QDXActTableViewCell.h
//  趣定向
//
//  Created by Air on 2016/12/14.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Goods;
@interface QDXActTableViewCell : UITableViewCell

@property (nonatomic, strong)Goods *goods;

+ (instancetype)qdxActCellWithTableView:(UITableView *)tableView;

+ (instancetype)qdxActCellWithPriceWithTableView:(UITableView *)tableView;

@end
