//
//  QDXNoNetWorkView.h
//  趣定向
//
//  Created by Air on 2016/12/5.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckNetworkDelegate <NSObject>
@optional

/** 重新加载数据 */
- (void)reloadData;

@end

@interface QDXNoNetWorkView : UIView

@property (nonatomic,weak) id<CheckNetworkDelegate> delegate;

@end
