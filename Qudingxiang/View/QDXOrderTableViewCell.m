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
        cell = [[QDXOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        //添加cell的子控件
        [cell addSubViews];
    }
    return cell;
}

- (void)addSubViews
{
    self.contentView.backgroundColor = QDXBGColor;
    
    self.BGView = [[UIView alloc] init];
    self.BGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.BGView];
    
    self.orders_name = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24), 0, QdxWidth - FitRealValue(188 + 48), FitRealValue(100))];
    self.orders_name.textColor = QDXBlack;
    self.orders_name.font = [UIFont systemFontOfSize:17];
    self.orders_name.textAlignment = NSTextAlignmentLeft;
    [self.BGView addSubview:self.orders_name];
    
    self.ostatus_name = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(24 + 188), 0, FitRealValue(188), FitRealValue(100))];
    self.ostatus_name.textColor = QDXBlue;
    self.ostatus_name.font = [UIFont systemFontOfSize:17];
    self.ostatus_name.textAlignment = NSTextAlignmentRight;
    [self.BGView addSubview:self.ostatus_name];
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(100), QdxWidth - 2 * FitRealValue(24), FitRealValue(1))];
    lineView.backgroundColor = QDXLineColor;
    [self.BGView addSubview:lineView];
    
    self.order_img = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(100 + 40), FitRealValue(140), FitRealValue(140))];
    [self.BGView addSubview:self.order_img];
    
    self.order_name = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24 + 140 + 30), FitRealValue(100 + 44), QdxWidth - FitRealValue(24 + 140 + 30 + 24), FitRealValue(28))];
    self.order_name.textColor = QDXBlack;
    self.order_name.font = [UIFont systemFontOfSize:16];
    self.order_name.textAlignment = NSTextAlignmentLeft;
    [self.BGView addSubview:self.order_name];
    
    self.ticket_ct = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24 + 140 + 30), FitRealValue(100 + 44 + 28 + 26), FitRealValue(300), FitRealValue(28))];
    self.ticket_ct.textColor = QDXGray;
    self.ticket_ct.font = [UIFont systemFontOfSize:14];
    self.ticket_ct.textAlignment = NSTextAlignmentLeft;
    [self.BGView addSubview:self.ticket_ct];
    
    CGFloat ticket_ctMaxX = CGRectGetMaxX(self.ticket_ct.frame);
    
    if (QdxWidth < 375) {
        self.orders_am = [[UILabel alloc] initWithFrame:CGRectMake(ticket_ctMaxX - FitRealValue(30), FitRealValue(100 + 44 + 28 + 24), FitRealValue(200), FitRealValue(32))];
    }else{
        self.orders_am = [[UILabel alloc] initWithFrame:CGRectMake(ticket_ctMaxX - FitRealValue(60), FitRealValue(100 + 44 + 28 + 24), FitRealValue(200), FitRealValue(32))];
    }
    self.orders_am.textColor = QDXOrange;
    self.orders_am.font = [UIFont systemFontOfSize:18];
    self.orders_am.textAlignment = NSTextAlignmentLeft;
    [self.BGView addSubview:self.orders_am];
    
    self.orders_ct = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24 + 140 + 30), FitRealValue(100 + 44 + 28 + 26 + 28 + 26), FitRealValue(500), FitRealValue(28))];
    self.orders_ct.textColor = QDXGray;
    self.orders_ct.font = [UIFont systemFontOfSize:14];
    self.orders_ct.textAlignment = NSTextAlignmentLeft;
    [self.BGView addSubview:self.orders_ct];
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(24 + 150 + 60 + 150), FitRealValue(412 - 40 - 52), FitRealValue(150), FitRealValue(52))];
    self.deleteButton.layer.borderWidth = 0.5;
    self.deleteButton.layer.cornerRadius = 2;
    self.deleteButton.layer.borderColor = [QDXGray CGColor];
    [self.deleteButton setTitleColor:QDXGray forState:UIControlStateNormal];
    [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];

    
    self.payButton = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(24 + 150), FitRealValue(412 - 40 - 52), FitRealValue(150), FitRealValue(52))];
    self.payButton.backgroundColor = QDXBlue;
    self.payButton.layer.borderWidth = 0.5;
    self.payButton.layer.cornerRadius = 2;
    self.payButton.layer.borderColor = [QDXBlue CGColor];
    [self.payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.payButton setTitle:@"去支付" forState:UIControlStateNormal];
    self.payButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.payButton addTarget:self action:@selector(payButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
//    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 80)];
//    view2.backgroundColor = [UIColor redColor];
//    [self.BGView addSubview:view2];
//    
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view2.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = view2.bounds;
//    maskLayer.path = maskPath.CGPath;
//    view2.layer.mask = maskLayer;

}

-(void)setOrder:(QDXOrdermodel *)order
{
    _order = order;
    self.orders_name.text =[@"订单号：" stringByAppendingString:  order.Orders_name];
    self.orders_ct.text = [@"下单时间：" stringByAppendingString:  order.Orders_ct];
    
    [self.order_img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,order.img]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
    
    QDXostatus *ostatus = order.ostatus;
    self.ostatus_name.text = ostatus.ostatus_name;
    
    self.ticket_ct.text = [NSString stringWithFormat:@"数量：%d张 | 总价：",order.quantity];
    self.orders_am.text = [@"¥" stringByAppendingString:order.Orders_am];
    
    self.order_name.text = order.name;
    
    if (order.Orders_st == 2 || order.Orders_st == 3) {
        self.BGView.frame = CGRectMake(0, FitRealValue(20), QdxWidth, FitRealValue(324));
        [self.deleteButton removeFromSuperview];
        [self.payButton removeFromSuperview];
        if (order.Orders_st == 3) {
            self.orders_am.textColor = QDXGray;
        }
    }else{
        self.BGView.frame = CGRectMake(0, FitRealValue(20), QdxWidth, FitRealValue(412));
        [self.BGView addSubview:self.deleteButton];
        [self.BGView addSubview:self.payButton];
    }
}

-(void)payButtonClick
{
    if (self.payBtnBlock) {
        self.payBtnBlock();
    }
}

-(void)deleteButtonClick
{
    if (self.deleteBtnBlock) {
        self.deleteBtnBlock();
    }
}

@end
