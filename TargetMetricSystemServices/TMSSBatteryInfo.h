//
//  TMSSBatteryInfo.h
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import "TMSSConstants.h"

@interface TMSSBatteryInfo : NSObject

// Battery Information

// Battery Level
+ (float)batteryLevel;

// Charging?
+ (BOOL)charging;

// Fully Charged?
+ (BOOL)fullyCharged;

@end
