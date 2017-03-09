//
//  PlaceCollectionViewCell.m
//  趣定向
//
//  Created by Air on 2017/3/9.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "PlaceCollectionViewCell.h"
#import "HomeModel.h"
@interface PlaceCollectionViewCell()

@property (nonatomic, strong) UIView *BGView;

@property (nonatomic, strong) UIImageView *act_img;

@property (nonatomic, strong) UILabel *act_name;

@property (nonatomic, strong) UILabel *act_place;

@property (nonatomic, strong) UIImageView *act_place_img;

@end

@implementation PlaceCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.contentView.backgroundColor = QDXBGColor;
    
    self.BGView = [[UIView alloc] initWithFrame:CGRectMake(0, FitRealValue(20), self.contentView.frame.size.width, self.contentView.frame.size.height - FitRealValue(20))];
    self.BGView.backgroundColor = [UIColor whiteColor];
    self.BGView.layer.cornerRadius = 3;
    self.BGView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.BGView.layer.shadowColor = QDXGray.CGColor;
    self.BGView.layer.shadowOffset = CGSizeMake(0, 0);
    self.BGView.layer.shadowOpacity = 0.2;
    self.BGView.layer.shadowRadius = 3.0;
    [self.contentView addSubview:self.BGView];
    
    self.act_img = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(20), FitRealValue(20), self.contentView.frame.size.width - FitRealValue(40), FitRealValue(306))];
    //    self.act_img.contentMode = UIViewContentModeScaleAspectFit;
    [self.BGView addSubview:self.act_img];

    self.act_name = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(20), self.act_img.frame.size.height + FitRealValue(20 + 20), self.contentView.frame.size.width - FitRealValue(40), FitRealValue(30))];
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
}

-(void)setHomeModel:(HomeModel *)homeModel
{
    _homeModel = homeModel;
    [self.act_img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,homeModel.good_url]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
    self.act_name.text = homeModel.goods_name;
    //高度固定不折行，根据字的多少计算label的宽度
    NSString *str = homeModel.act_address;
    CGSize size = [str sizeWithFont:self.act_place.font constrainedToSize:CGSizeMake(MAXFLOAT, self.act_place.frame.size.height)];
    
    if (size.width > (self.contentView.frame.size.width - FitRealValue(30))) {
        [self.act_place setFrame:CGRectMake(_act_place_img.frame.origin.x + FitRealValue(28 + 10), _act_place_img.frame.origin.y, self.contentView.frame.size.width - FitRealValue(30), FitRealValue(26))];
    }else{
        //根据计算结果重新设置UILabel的尺寸
        [self.act_place setFrame:CGRectMake(_act_place_img.frame.origin.x + FitRealValue(28 + 10), _act_place_img.frame.origin.y, size.width, FitRealValue(26))];
    }

    self.act_place.text = str;

}

@end
