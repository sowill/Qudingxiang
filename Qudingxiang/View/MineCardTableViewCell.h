//
//  MineCardTableViewCell.h
//  趣定向
//
//  Created by Air on 2017/4/13.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CardModel;

@interface MineCardTableViewCell : UITableViewCell

@property (nonatomic,strong) UIView *bgView;

@property (nonatomic,strong) UIImageView *bgImageView;

@property (nonatomic,strong) UIImageView *cardImageView;

@property (nonatomic,strong) UIView *lineView;

@property (nonatomic,strong) UILabel *dateLabel;

@property (nonatomic,strong) UIImageView *cardSTImageView;

@property (nonatomic,strong) UIButton *qrCodeBtn;

@property (nonatomic,strong) CardModel *cardModel;

@property (nonatomic, strong)void (^qrCodeBtnBlock)();

+ (instancetype)MineCardCellWithTableView:(UITableView *)tableView;

@end
