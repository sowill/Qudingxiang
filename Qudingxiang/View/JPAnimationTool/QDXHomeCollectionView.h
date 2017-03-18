//
//  QDXHomeCollectionView.h
//  趣定向
//
//  Created by Air on 2017/1/10.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Area;

@interface QDXHomeCollectionView : UICollectionViewCell

/** dataSrouce */
@property(nonatomic, strong)Area *dataString;

//@property(nonatomic, strong)NSString *dataString;

@property (strong, nonatomic)UIImageView *coverImageView;

@property (strong, nonatomic)UILabel *coverLabel;

@end
