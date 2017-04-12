//
//  WBKBeaconManager.h
//  Weway Beacon Kit
//
//  Created by Weway on 15/8/26.
//  Copyright (c) 2015年 微位科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBKDefines.h"
#import "WBKBeacon.h"


@protocol WBKBeaconManagerDelegate;

/**
 *  The WBKBeaconManager class defines the interface for configuring the delivery of beacon-related events to your application. You use an instance of this class to get WBKBeaconID objects and WBKBeacon objects, and establish the parameters that determine which beacon's events should be delivered.
 *
 *  You should always use the shared instance. Creating own instance is not allowed.
 */
@interface WBKBeaconManager : NSObject

/**---------------------------------------------------------------------------------------
 * @name Setting and Getting the Delegate
 *  ---------------------------------------------------------------------------------------
 */

/**
 * The delegate of the app object.
 */
@property(nonatomic, assign) id<WBKBeaconManagerDelegate> delegate;
/**---------------------------------------------------------------------------------------
 * @name Setting and Getting the outOfRangeDelay
 *  ---------------------------------------------------------------------------------------
 */

/**
 * The delay of the WBKBeacon exist when it not be found in period of time.
 */
@property(nonatomic, readwrite) NSTimeInterval outOfRangeDelay;

/**---------------------------------------------------------------------------------------
 * @name Getting the Instance
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Returns the shared instance of the WBKBeaconManager class. Users are not allowed to create own instance. Use WBKBeaconManager to get WBKBeacon instances.
 */
+ (WBKBeaconManager *)sharedInstance;

/**---------------------------------------------------------------------------------------
 * @name Initiating Beacon Ranging
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Requests permission to use location services whenever the app is running.
 *
 *  @discussion When the current authorization status is WBKAuthorizationStatusNotDetermined, calling this method prompts the user to grant permission to the app to use location services.The user prompt contains the text from the NSLocationAlwaysUsageDescription key in your app’s Info.plist file, and the presence of that key is required when calling this method. You must call this method or the requestWhenInUseAuthorization method prior to using location services. If the current authorization status is anything other than WBKAuthorizationStatusNotDetermined, this method does nothing.
 *
 */
- (void)requestAlwaysAuthorization;
/**
 *  Requests permission to use location services while the app is in the foreground.
 *
 *  When the current authorization status is WBKAuthorizationStatusNotDetermined, calling this method prompts the user to grant permission to the app to use location services. The user prompt contains the text from the NSLocationWhenInUseUsageDescription key in your app’s Info.plist file, and the presence of that key is required when calling this method. You must call this method or the requestAlwaysAuthorization method prior to using location services. If the current authorization status is anything other than WBKAuthorizationStatusNotDetermined, this method does nothing.
 *
 */
- (void)requestWhenInUseAuthorization;

/**
 *  Starts the delivery of notifications for beacons with specified id.
 *
 *  @param beaconID          Using WBKBeaconID object to identify the beacons.
 */
- (void)startRangingBeaconsWithID:(WBKBeaconID *)beaconID;
/**
 *  Stops the delivery of notifications for beacons with specified id.
 *
 *  @param beaconID Using WBKBeaconID object to identify the beacons.
 */
- (void)stopRangingBeaconsWithID:(WBKBeaconID *)beaconID;
/**
 *  Stops all of  notifications for beacons with specified id.
 *
 *  @param beaconID Using WBKBeaconID object to identify the beacons.
 */
- (void)stopRangingAllBeacons;

/**
 *  The set of WBKBeaconID currently being ranged.
 *
 *  @return The objects in the set are instances of the WBKBeaconID class
 */
- (NSArray *)rangedBeaconIDs;
/**
 *  Get all the beacon instances.
 *
 *  @return Beacon instances in array sorted by accuracy if it have or sort by the time last update
 */
- (NSArray *)beaconsInRange;
/**
 *  Get the beacon instances in range now.
 *
 *  @return Beacon instances in array.
 */
- (NSArray *)allBeacons;


@end


@protocol WBKBeaconManagerDelegate <NSObject>

@optional

/**
 *  Tells the delegate that the authorization status for the application changed.
 *
 *  @param beaconManager The beacon manager object reporting the event.
 *  @param status        The new authorization status for the application.
 *  @discussion This method is called whenever the application’s ability to use location services changes. Changes can occur because the user allowed or denied the use of location services for your application or for the system as a whole.
 */
- (void)beaconManager:(WBKBeaconManager *)beaconManager didChangeAuthorizationStatus:(WBKAuthorizationStatus)status;

/**---------------------------------------------------------------------------------------
 * @name Responding to beacon ranging
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Tells the delegate that ranged a new beacon.
 *
 *  @param beaconManager The beacon manager object reporting the event.
 *  @param beacon        The beacon instance just be ranged.
 */
- (void)beaconManager:(WBKBeaconManager *)beaconManager didEnterBeacon:(WBKBeacon *)beacon;
/**
 *  Tells the delegate that a beacon has been out of range.
 *
 *  @param beaconManager The beacon manager object reporting the event.
 *  @param beacon        The beacon instance just be out of range.
 */
- (void)beaconManager:(WBKBeaconManager *)beaconManager didExitBeacon:(WBKBeacon *)beacon;

/*
 *  Discussion:
 *    Invoked when a new set of beacons are available in the specified WBKBeaconID.
 *    beacons is an array of WBKBeacon objects.
 *    If beacons is empty, it may be assumed no beacons that match the WBKBeaconID are nearby.
 *    Similarly if a specific WBKBeacon no longer appears in beacons, it may be assumed the WBKBeacon is no longer received
 *    by the device.
 */
- (void)beaconManager:(WBKBeaconManager *)beaconManager didRangeBeacons:(NSArray *)beacons;

/**
 *  Tells the delegate that enter a new beaconID.
 *
 *  @param beaconManager The beacon manager object reporting the event.
 *  @param beacon        The beaconID instance just be enter.
 */
- (void)beaconManager:(WBKBeaconManager *)beaconManager didEnterBeaconID:(WBKBeaconID *)beaconID;

/**
 *  Tells the delegate that exit a beaconID.
 *
 *  @param beaconManager The beacon manager object reporting the event.
 *  @param beacon        The beaconID instance just be exit.
 */
- (void)beaconManager:(WBKBeaconManager *)beaconManager didExitBeaconID:(WBKBeaconID *)beaconID;

/**
 *  Tells the delegate that error had occured.
 *
 *  @param beaconManager The beacon manager object reporting the event.
 *  @param beacon        the error occured just now. Error type defined in "WBKError.h" and "CLError.h".
 */
- (void)beaconManager:(WBKBeaconManager *)beaconManager didRangeError:(NSError *)error;



@end