//
//  MineCardTableViewCell.m
//  趣定向
//
//  Created by Air on 2017/4/13.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "MineCardTableViewCell.h"
#import "CardModel.h"

@implementation MineCardTableViewCell

+(instancetype)MineCardCellWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"ID";
    MineCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[MineCardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell addSubViews];
    }
    return cell;
}

-(void)addSubViews
{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(410))];
    _bgView.backgroundColor = QDXBGColor;
    [self.contentView addSubview:_bgView];
    
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(20), FitRealValue(20), QdxWidth - FitRealValue(20 * 2), FitRealValue(390))];
    _bgImageView.image = [UIImage imageNamed:@"分割线优惠券底"];
    _bgImageView.userInteractionEnabled = YES;
    [_bgView addSubview:_bgImageView];
    
    _cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(40), FitRealValue(36), FitRealValue(630), FitRealValue(230))];
    [_bgImageView addSubview:_cardImageView];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(20), FitRealValue(300), FitRealValue(320), FitRealValue(90))];
    _dateLabel.textAlignment = NSTextAlignmentLeft;
    _dateLabel.font = [UIFont systemFontOfSize:10];
    _dateLabel.textColor = QDXGray;
    [_bgImageView addSubview:_dateLabel];
    
    _cardSTImageView = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(20 + 320 + 100), FitRealValue(390 - 10 - 102), FitRealValue(102), FitRealValue(102))];
    [_bgImageView addSubview:_cardSTImageView];
    
    _qrCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(20 * 2) - FitRealValue(30) - FitRealValue(48), FitRealValue(390 - 22 - 48), FitRealValue(48), FitRealValue(48))];
    [_qrCodeBtn setImage:[UIImage imageNamed:@"二维码"] forState:UIControlStateNormal];
    [_qrCodeBtn addTarget:self action:@selector(qrCodeClick) forControlEvents:UIControlEventTouchUpInside];
    [_bgImageView addSubview:_qrCodeBtn];
}

-(void)qrCodeClick{
    if (self.qrCodeBtnBlock) {
        self.qrCodeBtnBlock();
    }
}

-(void)setCardModel:(CardModel *)cardModel
{
    _cardModel = cardModel;
    [_cardImageView setImageWithURL:[NSURL URLWithString:[newHostUrl stringByAppendingString:cardModel.mycard_url]] placeholderImage:[UIImage imageNamed:@"优惠券banner默认图"]];
    
    NSRange cdateRange = [cardModel.mycard_cdate rangeOfString:@" "]; //现获取要截取的字符串位置
    NSString *cdateResult = [cardModel.mycard_cdate substringToIndex:cdateRange.location]; //截取字符串
    NSRange vdateRange = [cardModel.mycard_vdate rangeOfString:@" "]; //现获取要截取的字符串位置
    NSString *vdateResult = [cardModel.mycard_vdate substringToIndex:vdateRange.location]; //截取字符串
    NSString *result = [cdateResult stringByAppendingFormat:@"-%@",vdateResult];
    _dateLabel.text = [@"有效期:" stringByAppendingString:result];
    
    if ([cardModel.onoff_id intValue] == 1) {
        _cardSTImageView.image = [UIImage imageNamed:@"已使用"];
    }else{
        _cardSTImageView.image = [UIImage imageNamed:@"已过期"];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
