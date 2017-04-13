//
//  CardModel.h
//  趣定向
//
//  Created by Air on 2017/4/12.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardModel : NSObject

@property (nonatomic,copy) NSString *customer_id;

@property (nonatomic,copy) NSString *mycard_cdate;

@property (nonatomic,copy) NSString *mycard_cn;

@property (nonatomic,copy) NSString *mycard_id;

@property (nonatomic,copy) NSString *mycard_qrcode;

@property (nonatomic,copy) NSString *mycard_url;

@property (nonatomic,copy) NSString *mycard_vdate;

@property (nonatomic,copy) NSString *onoff_id;

-(id)initWithDic:(NSDictionary *) infoDict;

@end
