//
//  UIImage+watermark.m
//  趣定向
//
//  Created by Air on 16/5/17.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "UIImage+watermark.h"

@implementation UIImage (watermark)

-(UIImage *)imageFromText:(NSString *)text{
    
    
    
    //1.获取上下文
    
    UIGraphicsBeginImageContext(self.size);
    
    
    
    //2.绘制图片
    
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    
    
    //3.绘制水印文字
    
    CGRect rect = CGRectMake(0, self.size.height-30, self.size.width, 20);
    
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    
    style.alignment = NSTextAlignmentCenter;
    
    //文字的属性
    
    NSDictionary *dic = @{
                          
                          NSFontAttributeName:[UIFont systemFontOfSize:13],
                          
                          NSParagraphStyleAttributeName:style,
                          
                          NSForegroundColorAttributeName:[UIColor colorWithWhite:0.067 alpha:1.000]
                          
                          };
    
    //将文字绘制上去
    
    [text drawInRect:rect withAttributes:dic];
    
    
    
    //4.获取绘制到得图片
    
    UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    //5.结束图片的绘制
    
    UIGraphicsEndImageContext();
    
    
    
    return watermarkImage;
    
}

@end
