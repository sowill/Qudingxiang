//
//  QDXLineDetailWithImageViewController.h
//  趣定向
//
//  Created by Air on 2017/1/11.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JPNoParaBlock)(void);
typedef void(^JPContainIDBlock)(id);

@interface QDXLineDetailWithImageViewController : UIViewController

/** coverImage */
@property(nonatomic, strong)UIImage *coverImage;

/** 进入出现动画 */
@property(nonatomic, strong)JPNoParaBlock fadeBlock;

/** 关闭动画 */
@property(nonatomic, strong)JPContainIDBlock closeBlock;

@end
