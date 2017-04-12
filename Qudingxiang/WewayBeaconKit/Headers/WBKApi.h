//
//  WBKApi.h
//  WewayBeaconKit
//
//  Created by Weway on 8/27/15.
//  Copyright (c) 2015 微位（上海）网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBKDefines.h"

/**
 *The class WBKApi is defined to check basic Settings for the SDK.
 */
@interface WBKApi : NSObject

/**---------------------------------------------------------------------------------------
 * @name Accessing the Attributes
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  The device whether support iBeacon.
 */
@property(nonatomic, readonly) BOOL isRangingAvailable;
/**
 *  able for alert view.
 *  @discussion YES alert for tip, NO don't alert for tip.
 */
@property(nonatomic) BOOL powerAlertEnable;
/**
 *  able for log.
 *  @discussion YES log for information, NO don't log for information.
 */
@property(nonatomic) BOOL debugModeActive;
/**
 *  The SDK version.
 *  @discussion default is 1.0.
 */
@property(nonatomic, readonly) NSString *version;
/**
 *  The authorzation status for request first.
 *  @discussion WBKAuthorizationStatusAuthorizedAlways or WBKAuthorizationStatusAuthorizedWhenInUse may run normal.
 */
@property(nonatomic) WBKAuthorizationStatus authorizationStatus;

/**---------------------------------------------------------------------------------------
 * @name Getting the Instance
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Returns the shared instance of the WBKApi class. Users are not allowed to create own instance.
 */
+ (WBKApi *)sharedInstance;

@end
