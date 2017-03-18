//
//  QDXActTableViewCell.m
//  趣定向
//
//  Created by Air on 2016/12/14.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXActTableViewCell.h"
#import "Goods.h"
#import "NSMutableAttributedString+ChangeColorFont.h"

@interface QDXActTableViewCell()

@property (nonatomic, strong) UIView *BGView;

@property (nonatomic, strong) UIImageView *act_img;

@property (nonatomic, strong) UILabel *act_name;

@property (nonatomic, strong) UILabel *act_place;

@property (nonatomic, strong) UILabel *act_state;

@property (nonatomic, strong) UILabel *act_price;

@property (nonatomic, strong) UIImageView *act_place_img;

@property (nonatomic, strong) UIImageView *act_state_img;

@end

@implementation QDXActTableViewCell

+ (instancetype)qdxActCellWithPriceWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"actCellWithPriceID";
    QDXActTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[QDXActTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        [cell addSubViewsWithPrice];
    }
    return cell;
}

-(void)addSubViewsWithPrice
{
    self.contentView.backgroundColor = QDXBGColor;
    
    self.BGView = [[UIView alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(20), QdxWidth - FitRealValue(48), FitRealValue(556))];
    self.BGView.backgroundColor = [UIColor whiteColor];
    self.BGView.layer.cornerRadius = 3;
    self.BGView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.BGView.layer.shadowColor = QDXGray.CGColor;
    self.BGView.layer.shadowOffset = CGSizeMake(0, 0);
    self.BGView.layer.shadowOpacity = 0.2;
    self.BGView.layer.shadowRadius = 3.0;
    [self.contentView addSubview:self.BGView];
    
    self.act_img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.BGView.frame.size.width, FitRealValue(424))];
    //    self.act_img.contentMode = UIViewContentModeScaleAspectFit;
    [self.BGView addSubview:self.act_img];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.act_img.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(2, 2)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.act_img.bounds;
    maskLayer.path = maskPath.CGPath;
    self.act_img.layer.mask = maskLayer;
    
    self.act_name = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(20), self.act_img.frame.size.height + FitRealValue(20), self.BGView.frame.size.width - FitRealValue(20), FitRealValue(30))];
    self.act_name.textColor = QDXBlack;
    self.act_name.font = [UIFont systemFontOfSize:17];
    self.act_name.textAlignment = NSTextAlignmentLeft;
    [self.BGView addSubview:self.act_name];
    
    _act_place_img = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(20), self.act_name.frame.origin.y + FitRealValue(30 + 30), FitRealValue(32), FitRealValue(32))];
    _act_place_img.image = [UIImage imageNamed:@"定位"];
    [self.BGView addSubview:_act_place_img];
    
    self.act_place = [[UILabel alloc] initWithFrame:CGRectMake(_act_place_img.frame.origin.x + FitRealValue(28 + 10), _act_place_img.frame.origin.y, 0, FitRealValue(26))];
    self.act_place.font = [UIFont systemFontOfSize:14];  //UILabel的字体大小
    self.act_place.numberOfLines = 0;  //必须定义这个属性，否则UILabel不会换行
    self.act_place.textColor = QDXGray;
    self.act_place.textAlignment = NSTextAlignmentLeft;  //文本对齐方式
    [self.BGView addSubview:self.act_place];
    
    self.act_price = [[UILabel alloc] initWithFrame:CGRectMake(self.BGView.frame.size.width - FitRealValue(20 + 200),  _act_place_img.frame.origin.y - FitRealValue(20), FitRealValue(200), FitRealValue(42))];
    self.act_price.textColor = QDXOrange;
//    self.act_price.font = [UIFont systemFontOfSize:14];
    self.act_price.textAlignment = NSTextAlignmentRight;
    [self.BGView addSubview:self.act_price];
}

+ (instancetype)qdxActCellWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"actCellID";
    QDXActTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[QDXActTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        [cell addSubViewsNew];
    }
    return cell;
}

- (void)addSubViewsNew
{
    self.contentView.backgroundColor = QDXBGColor;
    
    self.BGView = [[UIView alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(20), QdxWidth - FitRealValue(48), FitRealValue(556))];
    self.BGView.backgroundColor = [UIColor whiteColor];
    self.BGView.layer.cornerRadius = 3;
    self.BGView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.BGView.layer.shadowColor = QDXGray.CGColor;
    self.BGView.layer.shadowOffset = CGSizeMake(0, 0);
    self.BGView.layer.shadowOpacity = 0.2;
    self.BGView.layer.shadowRadius = 3.0;
    [self.contentView addSubview:self.BGView];
    
    self.act_img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.BGView.frame.size.width, FitRealValue(424))];
//    self.act_img.contentMode = UIViewContentModeScaleAspectFit;
    [self.BGView addSubview:self.act_img];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.act_img.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(2, 2)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.act_img.bounds;
    maskLayer.path = maskPath.CGPath;
    self.act_img.layer.mask = maskLayer;
    
    self.act_name = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(20), self.act_img.frame.size.height + FitRealValue(20), self.BGView.frame.size.width - FitRealValue(20), FitRealValue(30))];
    self.act_name.textColor = QDXBlack;
    self.act_name.font = [UIFont systemFontOfSize:17];
    self.act_name.textAlignment = NSTextAlignmentLeft;
    [self.BGView addSubview:self.act_name];
    
//    self.act_price = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(30), self.BGView.frame.size.height - FitRealValue(30 + 34), self.BGView.frame.size.width, FitRealValue(34))];
//    self.act_price.textColor = QDXOrange;
//    self.act_price.font = [UIFont systemFontOfSize:20];
//    self.act_price.textAlignment = NSTextAlignmentLeft;
//    [self.BGView addSubview:self.act_price];
    
    _act_place_img = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(20), self.act_name.frame.origin.y + FitRealValue(30 + 30), FitRealValue(32), FitRealValue(32))];
    _act_place_img.image = [UIImage imageNamed:@"定位"];
    [self.BGView addSubview:_act_place_img];
    
    self.act_place = [[UILabel alloc] initWithFrame:CGRectMake(_act_place_img.frame.origin.x + FitRealValue(28 + 10), _act_place_img.frame.origin.y, 0, FitRealValue(26))];
    self.act_place.font = [UIFont systemFontOfSize:14];  //UILabel的字体大小
    self.act_place.numberOfLines = 0;  //必须定义这个属性，否则UILabel不会换行
    self.act_place.textColor = QDXGray;
    self.act_place.textAlignment = NSTextAlignmentLeft;  //文本对齐方式
    [self.BGView addSubview:self.act_place];
    
    
    _act_state_img = [[UIImageView alloc] init];
    _act_state_img.image = [UIImage imageNamed:@"时间"];
    [self.BGView addSubview:_act_state_img];
    self.act_state = [[UILabel alloc] init];
//    self.act_state.text = @"进行中";
    self.act_state.textColor = QDXGray;
    self.act_state.font = [UIFont systemFontOfSize:14];
    self.act_state.textAlignment = NSTextAlignmentLeft;
    [self.BGView addSubview:self.act_state];
}

- (void)setGoods:(Goods *)goods
{
    _goods = goods;

    [self.act_img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",newHostUrl,goods.goods_url]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
    self.act_name.text = goods.goods_cn;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];
    [string appendString:@"¥" withColor:QDXOrange font:[UIFont systemFontOfSize:14]];
    NSRange range = [goods.goods_price rangeOfString:@"."];
    NSString *a = goods.goods_price;
    [string appendString:[a substringToIndex:(int)range.location] withColor:QDXOrange font:[UIFont systemFontOfSize:24]];
    [string appendString:[a substringFromIndex:(int)range.location] withColor:QDXOrange font:[UIFont systemFontOfSize:14]];
    self.act_price.attributedText = string;
//    self.act_price.text = [@"¥" stringByAppendingString:homeModel.goods_price];
    
    
    self.act_state.text = [goods.goods_time substringToIndex:10];
    
    //高度固定不折行，根据字的多少计算label的宽度
    NSString *str = goods.goods_address;
    CGSize size = [str sizeWithFont:self.act_place.font constrainedToSize:CGSizeMake(QdxWidth - FitRealValue(400), self.act_place.frame.size.height)];
    //根据计算结果重新设置UILabel的尺寸
    [self.act_place setFrame:CGRectMake(_act_place_img.frame.origin.x + FitRealValue(28 + 10), _act_place_img.frame.origin.y, size.width, FitRealValue(26))];
    self.act_place.text = str;
    
    _act_state_img.frame = CGRectMake(self.act_place.frame.origin.x + FitRealValue(60) + self.act_place.frame.size.width, _act_place_img.frame.origin.y, FitRealValue(32), FitRealValue(32));
    
    _act_state.frame = CGRectMake(_act_state_img.frame.origin.x + FitRealValue(28 + 10), _act_state_img.frame.origin.y, FitRealValue(200), FitRealValue(26));
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
