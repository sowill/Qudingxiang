//
//  NSMutableAttributedString+ChangeColorFont.m
//  趣定向
//
//  Created by Air on 2017/3/8.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "NSMutableAttributedString+ChangeColorFont.h"

@implementation NSMutableAttributedString (ChangeColorFont)
- (void)appendString:(NSString *)string withColor:(UIColor *)color font:(UIFont *)font
{
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSRange range = NSMakeRange(0, string.length);
    [attString addAttribute:NSFontAttributeName value:font range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    [self appendAttributedString:attString];
    
}
@end
