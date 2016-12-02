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
@property (nonatomic, strong) UILabel *orders_name;
@property (nonatomic, strong) UILabel *orders_ct;
@property (nonatomic, strong) UILabel *orders_am;
@property (nonatomic, strong) UILabel *ostatus_name;
@property (nonatomic, strong) UIImageView *order_img;
@property (nonatomic, strong) UILabel *order_name;
@property (nonatomic, strong) UILabel *ticket_ct;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *payButton;
@property (nonatomic, strong) UIView *BGView;
@property (nonatomic, strong) QDXOrdermodel *order;

@property (nonatomic, strong)void (^deleteBtnBlock)();

@property (nonatomic, strong)void (^payBtnBlock)();

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
