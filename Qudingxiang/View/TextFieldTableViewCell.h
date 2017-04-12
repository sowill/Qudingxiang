//
//  TextFieldTableViewCell.h
//  趣定向
//
//  Created by Air on 2017/3/29.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldTableViewCell : UITableViewCell

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) UILabel *titleLabel;

- (void)setTitleString:(NSString *)string andDataString:(NSString *)dataString andIndexPath:(NSIndexPath *)indexPath;

@end
