//
//  WBKBeacon.h
//  Weway Beacon Kit
//
//  Created by Weway on 15/8/26.
//  Copyright (c) 2015年 微位科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WBKDefines.h"
#import "WBKBeaconID.h"


/**
 *WBKBeacon instance is an obejct to specify a beacon. You can use instances of this class to get rssi and sensor data.You do not create instances of this class directly.
 *
 */
@interface WBKBeacon : NSObject

/**---------------------------------------------------------------------------------------
 * @name Accessing the Attributes
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  The unique ID of the beacons being targeted. (read-only)
 */
@property(nonatomic, retain, readonly) NSUUID *proximityUUID;
/**
 *  The value identifying a group of beacons. (read-only)
 */
@property(nonatomic, retain, readonly) NSNumber *major;
/**
 *  The value identifying a specific beacon within a group. (read-only)
 */
@property(nonatomic, retain, readonly) NSNumber *minor;
/**
 *  The relative distance to the beacon. (read-only)
 *
 *  @discussion The value in this property gives a general sense of the relative distance to the beacon. Use it to quickly identify beacons that are nearer to the user rather than farther away.
 */
@property(nonatomic, readonly) CLProximity proximity;
/**
 *  The accuracy of the proximity value, measured in meters from the beacon. (read-only)
 *
 *  @discussion Indicates the one sigma horizontal accuracy in meters. Use this property to differentiate between beacons with the same proximity value. Do not use it to identify a precise location for the beacon. Accuracy values may fluctuate due to RF interference. A negative value in this property signifies that the actual accuracy could not be determined.
 */
@property(nonatomic, readonly) CLLocationAccuracy accuracy;
/**
 *  The received signal strength of the beacon, measured in decibels. (read-only)
 *
 *  @discussion If beacon is out of range, the value will be 0.
 */
@property(nonatomic, readonly) NSInteger rssi;
/**
 *  The value identifying a specific WBKBeacon. (read-only)
 */
@property(nonatomic, retain, readonly) NSString *identifier;

/**
 *  The WBKBeacon is in range. (read-only)
 *
 *  @discussion If beacon is out of range, the value will be NO.
 */
@property(nonatomic, readonly) BOOL inRange;
/**
 *  The time be update by range at last time.
 *
 *  @discussion If beacon is out of range, the value will be 0.
 */
@property(nonatomic) NSTimeInterval lastUpdateTime;


@end
