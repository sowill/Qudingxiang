//
//  WBKDefines.h
//  Weway Beacon Kit
//
//  Created by Weway on 8/27/15.
//  Copyright (c) 2015 微位科技. All rights reserved.
//

#ifndef Weway_Beacon_Kit_WBKDefines_h
#define Weway_Beacon_Kit_WBKDefines_h

#import <UIKit/UIKit.h>

#define WBKVersion @"1.0.0"

/*
 *  WBKAuthorizationStatus
 *
 *  Discussion:
 *      Represents the current authorization state of the application.
 *
 */
typedef NS_ENUM(NSInteger, WBKAuthorizationStatus)
{
    // User has not yet made a choice with regards to this application
    WBKAuthorizationStatusNotDetermined = 0,
    // This application is not authorized to use location services.  Due
    // to active restrictions on location services, the user cannot change
    // this status, and may not have personally denied authorization
    WBKAuthorizationStatusRestricted,
    // User has explicitly denied authorization for this application, or
    // location services are disabled in Settings.
    WBKAuthorizationStatusDenied,
    // User has granted authorization to use their location at any time,
    // including monitoring for regions, visits, or significant location changes.
    WBKAuthorizationStatusAuthorizedAlways,
    // User has granted authorization to use their location only when your app
    // is visible to them (it will be made visible to them if you continue to
    // receive location updates while in the background).  Authorization to use
    // launch APIs has not been granted.
    WBKAuthorizationStatusAuthorizedWhenInUse
};


#endif
