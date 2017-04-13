//
//  CardModel.m
//  趣定向
//
//  Created by Air on 2017/4/12.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "CardModel.h"

@implementation CardModel
-(id)initWithDic:(NSDictionary *) infoDict{
    if(self=[super init]){
        _customer_id= infoDict[@"customer_id"];
        _mycard_cdate= infoDict[@"mycard_cdate"];
        _mycard_cn = infoDict[@"mycard_cn"];
        _mycard_id = infoDict[@"mycard_id"];
        _mycard_qrcode= infoDict[@"mycard_qrcode"];
        _mycard_url= infoDict[@"mycard_url"];
        _mycard_vdate = infoDict[@"mycard_vdate"];
        _onoff_id = infoDict[@"onoff_id"];
    }
    return self;
}
@end
