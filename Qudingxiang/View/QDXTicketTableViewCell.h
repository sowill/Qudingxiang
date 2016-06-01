//
//  QDXTicketTableViewCell.h
//  趣定向
//
//  Created by Air on 16/1/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDXTicketInfoModel;

@interface QDXTicketTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *linePrice;
@property (weak, nonatomic) IBOutlet UIImageView *ticketinfo_code;
@property (weak, nonatomic) IBOutlet UILabel *ticketinfo_name;
@property (nonatomic, strong) QDXTicketInfoModel *TicketInfo;
//@property (weak, nonatomic) IBOutlet UILabel *tstatus_id;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *lineName;

@property (nonatomic, strong)void (^btnBlock)();

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
