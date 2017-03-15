//
//  ChoseCityCollectionViewCell.h
//  趣定向
//
//  Created by Air on 2017/3/6.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class City;

@interface ChoseCityCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic)City *city;

@property (nonatomic, strong)void (^btnBlock)();

@end
