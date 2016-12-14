//
//  QDXActTableViewCell.h
//  趣定向
//
//  Created by Air on 2016/12/14.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeModel;
@interface QDXActTableViewCell : UITableViewCell

@property (nonatomic, strong)HomeModel *homeModel;

+ (instancetype)qdxActCellWithTableView:(UITableView *)tableView;

@end
