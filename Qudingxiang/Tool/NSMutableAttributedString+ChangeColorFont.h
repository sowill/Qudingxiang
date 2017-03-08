//
//  NSMutableAttributedString+ChangeColorFont.h
//  趣定向
//
//  Created by Air on 2017/3/8.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (ChangeColorFont)
- (void)appendString:(NSString *)string withColor:(UIColor *)color font:(UIFont *)font;
@end
