//
//  myViewCellTableViewCell.m
//  Qudingxiang
//
//  Created by  stone020 on 15/9/22.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "myViewCellTableViewCell.h"

@implementation myViewCellTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"cellId";
    myViewCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[myViewCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //添加cell的子控件
        [cell addSubViews];
    }
    return cell;
}

- (void) addSubViews
{
    self.imageV = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(40), FitRealValue(30), FitRealValue(33), FitRealValue(33))];
    self.imageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.imageV];
    
    self._name = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(40 + 33 + 20), FitRealValue(30), FitRealValue(400), FitRealValue(33))];
    self._name.textColor = [UIColor whiteColor];
    self._name.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self._name];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
