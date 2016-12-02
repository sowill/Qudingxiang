//
//  QDXTicketTableViewCell.m
//  趣定向
//
//  Created by Air on 16/1/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXTicketTableViewCell.h"
#import "QDXOrderInfoModel.h"
#import "QDXOrdermodel.h"
#import "QDXTicketInfoModel.h"
#import "QDXostatus.h"
#import "QDXpaytype.h"
#import "QRCodeGenerator.h"
#import "zoomImage.h"
#import "QDXOrderDetailTableViewController.h"

@implementation QDXTicketTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"cellidentifier";
    QDXTicketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[QDXTicketTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        //添加cell的子控件
        [cell addSubViews];
    }
    return cell;
}

- (void)addSubViews
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.ticketinfo_code = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(24 - 20), FitRealValue(40 - 20), FitRealValue(180), FitRealValue(180))];
    [self.contentView addSubview:self.ticketinfo_code];
    
    self.ticketinfo_name = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24 + 140 + 30), FitRealValue(45), QdxWidth - FitRealValue(24 + 140 + 30), FitRealValue(30))];
    self.ticketinfo_name.textColor = QDXBlack;
    self.ticketinfo_name.font = [UIFont systemFontOfSize:16];
    self.ticketinfo_name.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.ticketinfo_name];
    
    self.lineName = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24 + 140 + 30), FitRealValue(45 + 30 + 22), QdxWidth - FitRealValue(24 + 140 + 30), FitRealValue(28))];
    self.lineName.textColor = QDXGray;
    self.lineName.font = [UIFont systemFontOfSize:14];
    self.lineName.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.lineName];
    
    self.linePrice = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24 + 140 + 30), FitRealValue(45 + 30 + 22 + 28 + 25), QdxWidth - FitRealValue(24 + 140 + 30), FitRealValue(35))];
    self.linePrice.textColor = QDXOrange;
    self.linePrice.font = [UIFont systemFontOfSize:18];
    self.linePrice.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.linePrice];
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(24 + 150), FitRealValue(312 - 40 - 52), FitRealValue(150), FitRealValue(52))];
    self.deleteButton.layer.borderWidth = 0.5;
    self.deleteButton.layer.cornerRadius = 2;
    self.deleteButton.layer.borderColor = [QDXGray CGColor];
    [self.deleteButton setTitleColor:QDXGray forState:UIControlStateNormal];
    [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.deleteButton];
}

-(void)setTicketInfo:(QDXTicketInfoModel *)TicketInfo
{
    _TicketInfo = TicketInfo;
    self.ticketinfo_name.text = [@"票号：" stringByAppendingString: TicketInfo.ticketinfo_name];
    self.ticketinfo_code.image = [QRCodeGenerator qrImageForString:TicketInfo.ticketinfo_name imageSize:89];
    self.ticketinfo_code.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [self.ticketinfo_code addGestureRecognizer:tap];

    self.linePrice.text = [@"￥" stringByAppendingString:TicketInfo.goods_price];
    self.lineName.text = [@"活动：" stringByAppendingString:TicketInfo.goods_name];
    if ([TicketInfo.tstatus_name isEqualToString:@"已使用"]){
        self.deleteButton.userInteractionEnabled = NO;
        [self.deleteButton setTitle:TicketInfo.tstatus_name forState:UIControlStateNormal];
    }else if ([TicketInfo.tstatus_name isEqualToString:@"未激活"]){
        self.deleteButton.layer.borderColor = [QDXBlue CGColor];
        [self.deleteButton setTitleColor:QDXBlue forState:UIControlStateNormal];
        [self.deleteButton setTitle:@"使用" forState:UIControlStateNormal];
    }
}

- (void)bigButtonTapped:(UIButton *)sender
{
    [zoomImage showImage:self.ticketinfo_code];
}

- (void)deleteButtonClick {
    if (self.btnBlock) {
        self.btnBlock();
    }
}


@end
