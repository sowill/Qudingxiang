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
        cell = [ [[NSBundle mainBundle] loadNibNamed:@"QDXTicketTableViewCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

-(void)setTicketInfo:(QDXTicketInfoModel *)TicketInfo
{
    _TicketInfo = TicketInfo;
    self.ticketinfo_name.text = [@"票号:" stringByAppendingString: TicketInfo.ticketinfo_name];
    self.ticketinfo_code.image = [QRCodeGenerator qrImageForString:TicketInfo.ticketinfo_name imageSize:89];
    self.ticketinfo_code.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [self.ticketinfo_code addGestureRecognizer:tap];
//    self.tstatus_id.text = TicketInfo.tstatus_name;
    self.linePrice.text = [@"￥" stringByAppendingString:TicketInfo.goods_price];
    self.lineName.text = [@"活动:" stringByAppendingString:TicketInfo.goods_name];
    if ([TicketInfo.tstatus_name isEqualToString:@"已使用"]){
        self.deleteButton.userInteractionEnabled = NO;
        [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"按钮2"] forState:UIControlStateNormal];
        self.deleteButton.titleLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
        [self.deleteButton setTitleColor:[UIColor colorWithWhite:0.400 alpha:1.000] forState:UIControlStateNormal];
        [self.deleteButton setTitle:TicketInfo.tstatus_name forState:UIControlStateNormal];
    }else if ([TicketInfo.tstatus_name isEqualToString:@"未激活"]){
        [self.deleteButton setTitle:@"使用" forState:UIControlStateNormal];
    }
}

- (void)bigButtonTapped:(UIButton *)sender
{
    [zoomImage showImage:self.ticketinfo_code];
}

- (IBAction)delete:(UIButton *)sender {
    if (self.btnBlock) {
        self.btnBlock();
    }
}


@end
