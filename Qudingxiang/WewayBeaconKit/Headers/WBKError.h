//
//  WBKError.h
//  Weway Beacon Kit
//
//  Created by Weway on 15/8/26.
//  Copyright (c) 2015年 微位科技. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const WBKErrorDomain;

typedef NS_ENUM(NSInteger, WBKError)
{
    /**
     *  Indicates that an unknown or unexpected error occurred.
     */
    WBKErrorUnknownError = 0,
    /**
     *  Indicates that the data is not valid.
     */
    WBKErrorInvalidData = 1400,
    /**
     *Unsupport feature.
     */
    WBKErrorUnsupport = 1500,
    /**
     *  Authorization failed.
     */
    WBKErrorAuthorizationFailed = 1600,
    /**
     *  range failed.
     */
    WBKErrorRangingFailed = 1700
};
