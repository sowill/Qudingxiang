//
//  QDXCooperationCollectionViewCell.h
//  趣定向
//
//  Created by Air on 2017/3/6.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Partner;

@interface QDXCooperationCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic)UIImageView *cooperationImage;

@property(nonatomic, strong)Partner *dataString;

@end
