//
//  QDXHistoryTableViewCell.h
//  趣定向
//
//  Created by Air on 16/5/5.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDXHIstoryModel;
//@class QDXGameModel;
@interface QDXHistoryTableViewCell : UITableViewCell
@property (nonatomic, strong) QDXHIstoryModel *HistoryInfo;
//@property (nonatomic, strong) QDXGameModel *GameInfo;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
