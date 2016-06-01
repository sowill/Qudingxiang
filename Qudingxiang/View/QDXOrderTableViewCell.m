//
//  QDXOrderTableViewCell.m
//  趣定向
//
//  Created by Air on 16/1/21.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXOrderTableViewCell.h"
#import "QDXOrderInfoModel.h"
#import "QDXOrdermodel.h"
#import "QDXTicketInfoModel.h"
#import "QDXostatus.h"
#import "QDXpaytype.h"

@implementation QDXOrderTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"cellidentifier";
    QDXOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [ [[NSBundle mainBundle] loadNibNamed:@"QDXOrderTableViewCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

-(void)setOrder:(QDXOrdermodel *)order
{
    _order = order;
    self.orders_name.text =[@"订单号:" stringByAppendingString:  order.Orders_name];
    self.orders_ct.text = order.Orders_ct;
    if (order.Orders_st == 3) {
        self.orders_am.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    }
    self.orders_am.text = [@"￥" stringByAppendingString: order.Orders_am];
    QDXostatus *ostatus = order.ostatus;
    self.ostatus_name.text = ostatus.ostatus_name;
}



@end
