//
//  ToolView.m
//  Qudingxiang
//
//  Created by Mac on 15/9/16.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "ToolView.h"

@implementation ToolView
+ (UIImageView *)createImageWithFrame:(CGRect)frame
{
    UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
    iv.backgroundColor = [UIColor clearColor];
//    iv.layer.cornerRadius = 10;
    iv.layer.masksToBounds = YES;
    return iv;
}
+ (UILabel *)createLabelWithFrame:(CGRect)frame text:(NSString *)text font:(CGFloat)fontSize superView:(UIView *)superView
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textAlignment = NSTextAlignmentLeft;
    [superView addSubview:label];
    return label;
}
+ (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title backGroundImage:(NSString *)image Target:(id)target action:(SEL)action superView:(UIView *)superView
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setTitle:title forState:UIControlStateNormal];
//    [btn setTitleColor:QDXGray forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [superView addSubview:btn];
    return btn;
}

+ (UIButton *)createNavitonButtonWith:(UIView *)superView Target:(id)target action:(SEL)action image:(NSString *)imageName
{
    UIButton *buttonBack = [[UIButton alloc] init];
    buttonBack.frame = CGRectMake(0, 0, 16, 16);
    [buttonBack addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setTitle:nil forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    buttonBack.layer.cornerRadius = 8;
    buttonBack.backgroundColor = [UIColor clearColor];
    buttonBack.alpha = 0.7;
    //buttonBack.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    //[buttonBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [superView addSubview:buttonBack];
    return buttonBack;

}

+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f,20.0f,73.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSString *)scoreTransfer:(NSString *)score
{
    int a = [score intValue];
    int h = (a/3600);
    NSMutableString *stringH = [NSMutableString stringWithFormat:@"%d",h];
    if (stringH.length == 1) {
        [stringH insertString:@"0" atIndex:0];
    }
    int m = (a - h * 3600)/60;
    NSMutableString *stringM = [NSMutableString stringWithFormat:@"%d",m];
    if (stringM.length == 1) {
        [stringM insertString:@"0" atIndex:0];
    }
    int s = (a - h * 3600)%60;
    NSMutableString *stringS = [NSMutableString stringWithFormat:@"%d",s];
    if (stringS.length == 1) {
        [stringS insertString:@"0" atIndex:0];
    }
    if (h>24) {
        int d = (h/24);
        NSMutableString *stringD = [NSMutableString stringWithFormat:@"%d",d];
        h = (h%24);
        NSMutableString *stringH = [NSMutableString stringWithFormat:@"%d",h];
        if (stringH.length == 1) {
            [stringH insertString:@"0" atIndex:0];
        }
        NSString *timeWithDay = [NSString stringWithFormat:@"%@天%@:%@:%@",stringD,stringH,stringM,stringS];
        return timeWithDay;
    }
    NSString *time = [NSString stringWithFormat:@"%@:%@:%@",stringH,stringM,stringS];
    return time;
}

+ (NSString *)md5:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


@end
