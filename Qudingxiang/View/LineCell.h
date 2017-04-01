//
//  LineCell.h
//  Qudingxiang
//
//  Created by Mac on 15/9/18.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Line;
@protocol lineDelegate <NSObject>

-(void)CellBtnClickedWithRow:(NSInteger)row;

@end

@interface LineCell : UITableViewCell
@property (nonatomic, strong)Line *line;
@property(nonatomic,assign)NSInteger  select;
@property(nonatomic,weak)id<lineDelegate>delegate;
@property(nonatomic, strong) void(^detailClick)();
@property(nonatomic, strong) void(^quickClick)();
+ (instancetype)baseCellWithTableView:(UITableView *)tableView;

@end
