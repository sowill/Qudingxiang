//
//  myViewController.h
//  Qudingxiang
//
//  Created by  stone020 on 15/9/21.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>{
    UITableView* _myTableview;
}

@end
