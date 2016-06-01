//
//  WBKBeaconID.h
//  Weway Beacon Kit
//
//  Created by Weway on 15/8/26.
//  Copyright (c) 2015年 微位科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WBKDefines.h"

/**
 *  WBKBeaconID instance is an obejct to specify a beacon’s identity. The proximityUUID property will never be nil, major and minor are optional.
 */
@interface WBKBeaconID : NSObject
/**---------------------------------------------------------------------------------------
 * @name Accessing the Attributes
 *  ---------------------------------------------------------------------------------------
 */

@property(nonatomic) BOOL isRanging;
/**
 *  The unique ID of the WBKBeaconIDs being targeted. (read-only)
 */
@property(nonatomic, retain, readonly) NSUUID *proximityUUID;
/**
 *  The value identifying a group of WBKBeaconIDs. (read-only)
 */
@property(nonatomic, retain, readonly) NSNumber *major;
/**
 *  The value identifying a specific WBKBeaconID within a group. (read-only)
 */
@property(nonatomic, retain, readonly) NSNumber *minor;
/**
 *  The value identifying a specific WBKBeaconID within a group. (read-only)
 */
@property(nonatomic, retain, readonly) NSString *identifier;

/**---------------------------------------------------------------------------------------
 * @name Initializing the WBKBeaconID
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Initializes and returns a WBKBeaconID object that targets a beacon with the specified proximity ID
 *
 *  @param proximityUUID The unique ID of the beacons being targeted. This value must not be nil.
 *
 *  @return An initialized WBKBeaconID object.
 */
+ (WBKBeaconID *)beaconIDWithProximityUUID:(NSUUID *)proximityUUID;
/**
 *  Initializes and returns a WBKBeaconID object that targets a beacon with the specified proximity ID
 *
 *  @param proximityUUID The unique ID of the beacons being targeted. This value must not be nil.
 *  @param major The major value that you use to identify one or more beacons.
 *
 *  @return An initialized WBKBeaconID object.
 */
+ (WBKBeaconID *)beaconIDWithProximityUUID:(NSUUID *)proximityUUID major:(CLBeaconMajorValue)major;
/**
 *  Initializes and returns a WBKBeaconID object that targets a beacon with the specified proximity ID
 *
 *  @param proximityUUID The unique ID of the beacons being targeted. This value must not be nil.
 *  @param major The major value that you use to identify one or more beacons.
 *  @param minor The minor value that you use to identify a specific beacon.
 *
 *  @return An initialized WBKBeaconID object.
 */
+ (WBKBeaconID *)beaconIDWithProximityUUID:(NSUUID *)proximityUUID major:(CLBeaconMajorValue)major minor:(CLBeaconMajorValue)minor;

@end
