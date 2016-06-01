//
//  DetailCell.h
//  Qudingxiang
//
//  Created by Air on 15/9/28.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDXDetailsModel;
@interface DetailCell : UITableViewCell
@property (nonatomic,strong)QDXDetailsModel *detailModel;

+(instancetype)baseCellWithTableView:(UITableView *)tableView;
@end
