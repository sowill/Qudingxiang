//
//  ActCell.m
//  Qudingxiang
//
//  Created by Mac on 15/9/22.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "ActCell.h"
#import "ActModel.h"

@interface ActCell()
@property (nonatomic, strong) UIView *BGView;

@property (nonatomic, strong) UIImageView *act_img;

@property (nonatomic, strong) UILabel *act_name;
@end
@implementation ActCell

+ (instancetype)actCellWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"ID";
    ActCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[ActCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        [cell addSubViews];
        
    }
    return cell;

}

- (void)addSubViews
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.BGView = [[UIView alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(20), QdxWidth - FitRealValue(48), FitRealValue(508))];
    self.BGView.backgroundColor = [UIColor whiteColor];
    self.BGView.layer.cornerRadius = 2;
    self.BGView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.BGView.layer.shadowColor = QDXBlack.CGColor;
    self.BGView.layer.shadowOffset = CGSizeMake(0, 0);
    self.BGView.layer.shadowOpacity = 0.4;
    self.BGView.layer.shadowRadius = 4.0;
    [self.contentView addSubview:self.BGView];
    
    self.act_img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.BGView.frame.size.width, FitRealValue(416))];
    //    self.act_img.contentMode = UIViewContentModeScaleAspectFit;
    [self.BGView addSubview:self.act_img];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.act_img.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(2, 2)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.act_img.bounds;
    maskLayer.path = maskPath.CGPath;
    self.act_img.layer.mask = maskLayer;
    
    self.act_name = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(30), self.act_img.frame.size.height + FitRealValue(30), self.BGView.frame.size.width - FitRealValue(30), FitRealValue(30))];
    self.act_name.textColor = QDXBlack;
    self.act_name.font = [UIFont systemFontOfSize:17];
    self.act_name.textAlignment = NSTextAlignmentLeft;
    [self.BGView addSubview:self.act_name];
}

- (void)setModel:(ActModel *)model
{
    _model = model;
    [self.act_img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,model.good_url]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
    self.act_name.text = model.goods_name;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
