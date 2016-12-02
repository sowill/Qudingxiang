//
//  myViewCellTableViewCell.h
//  Qudingxiang
//
//  Created by  stone020 on 15/9/22.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myViewCellTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *_name;

//@property (nonatomic,strong) UILabel *_id;

@property (nonatomic,strong) UIImageView *imageV;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
