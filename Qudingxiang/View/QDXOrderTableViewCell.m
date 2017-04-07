//
//  QDXOrderTableViewCell.m
//  趣定向
//
//  Created by Air on 16/1/21.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXOrderTableViewCell.h"
#import "Orders.h"

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
//    self.order_img.contentMode = UIViewContentModeScaleAspectFit;
    [self.BGView addSubview:self.order_img];
    
    self.order_name = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24 + 140 + 30), FitRealValue(100 + 44), QdxWidth - FitRealValue(24 + 140 + 30 + 24), FitRealValue(28))];
    self.order_name.textColor = QDXBlack;
    self.order_name.font = [UIFont systemFontOfSize:16];
    self.order_name.textAlignment = NSTextAlignmentLeft;
    [self.BGView addSubview:self.order_name];
    
    self.ticket_ct = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24 + 140 + 30), FitRealValue(100 + 44 + 28 + 26), 0, FitRealValue(28))];
    self.ticket_ct.font = [UIFont systemFontOfSize:14];  //UILabel的字体大小
    self.ticket_ct.numberOfLines = 0;  //必须定义这个属性，否则UILabel不会换行
    self.ticket_ct.textColor = QDXGray;
    self.ticket_ct.textAlignment = NSTextAlignmentLeft;  //文本对齐方式
    
    self.orders_am = [[UILabel alloc] init];
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
}

-(void)setOrder:(Orders *)order{
    _order = order;
    self.orders_name.text =[@"订单号：" stringByAppendingString:  order.orders_cn];
    self.orders_ct.text = [@"下单时间：" stringByAppendingString:  order.orders_cdate];
    
    [self.order_img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",newHostUrl,order.goods_url]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
    
    //高度固定不折行，根据字的多少计算label的宽度
    NSString *str = [NSString stringWithFormat:@"数量：%@张 | 总价：",order.orders_quantity];
    CGSize size = [str sizeWithFont:self.ticket_ct.font constrainedToSize:CGSizeMake(MAXFLOAT, FitRealValue(28))];
    //根据计算结果重新设置UILabel的尺寸
    [self.ticket_ct setFrame:CGRectMake(FitRealValue(24 + 140 + 30), FitRealValue(100 + 44 + 28 + 26), size.width, FitRealValue(28))];
    self.ticket_ct.text = str;
    [self.BGView addSubview:self.ticket_ct];
    
    self.orders_am.text = [@"¥" stringByAppendingString:order.orders_am];
    CGFloat ticket_ctMaxX = CGRectGetMaxX(self.ticket_ct.frame);
    self.orders_am.frame = CGRectMake(ticket_ctMaxX,FitRealValue(100 + 44 + 28 + 24), FitRealValue(200), FitRealValue(32));
    
    self.order_name.text = order.orders_cn;
    
    if ([order.ordersst_id intValue] == 2 || [order.ordersst_id intValue] == 3) {
        self.BGView.frame = CGRectMake(0, FitRealValue(20), QdxWidth, FitRealValue(324));
        [self.deleteButton removeFromSuperview];
        [self.payButton removeFromSuperview];
        if ([order.ordersst_id intValue] == 3) {
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
