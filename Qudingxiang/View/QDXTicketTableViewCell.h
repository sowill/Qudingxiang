//
//  QDXTicketTableViewCell.h
//  趣定向
//
//  Created by Air on 16/1/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Ordersinfo;

@interface QDXTicketTableViewCell : UITableViewCell
@property (nonatomic,strong) UILabel *linePrice;
@property (nonatomic,strong) UIImageView *ticketinfo_code;
@property (nonatomic,strong) UILabel *ticketinfo_name;
@property (nonatomic, strong) Ordersinfo *ordersInfo;
//@property (weak, nonatomic) IBOutlet UILabel *tstatus_id;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UILabel *lineName;

@property (nonatomic, strong)void (^btnBlock)();

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
