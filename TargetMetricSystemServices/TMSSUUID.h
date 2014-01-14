//
//  TMSSUUID.h
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import "TMSSConstants.h"

@interface TMSSUUID : NSObject 

// Universal Unique Identifiers

// Unique ID - Unique Identifier based on unchanging information about the device
+ (NSString *)uniqueID;

// Device Signature - Device Signature based on assorted information about the device including: SystemVersion, ScreenHeight, ScreenWidth, PluggedIn, Jailbroken, HeadphonesAttached, BatteryLevel, FullyCharged, ConnectedtoWiFi, DeviceOrientation, Country, TimeZone, NumberProcessors, ProcessorSpeed, TotalDiskSpace, TotalMemory, and a Salt
+ (NSString *)deviceSignature;

// CFUUID - Random Unique Identifier that changes every time
+ (NSString *)cfuuid;

@end
