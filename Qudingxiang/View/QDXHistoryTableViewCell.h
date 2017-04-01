//
//  QDXHistoryTableViewCell.h
//  趣定向
//
//  Created by Air on 16/5/5.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HistoryModel;
//@class QDXGameModel;
@interface QDXHistoryTableViewCell : UITableViewCell
@property (nonatomic, strong) HistoryModel *HistoryInfo;
//@property (nonatomic, strong) QDXGameModel *GameInfo;

@property (nonatomic, strong)void (^historyBtnBlock)();

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
