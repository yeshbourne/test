//
//  TMSSCarrierInfo.h
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import "TMSSConstants.h"

@interface TMSSCarrierInfo : NSObject

// Carrier Information

// Carrier Name
+ (NSString *)carrierName;

// Carrier Country
+ (NSString *)carrierCountry;

// Carrier Mobile Country Code
+ (NSString *)carrierMobileCountryCode;

// Carrier ISO Country Code
+ (NSString *)carrierISOCountryCode;

// Carrier Mobile Network Code
+ (NSString *)carrierMobileNetworkCode;

// Carrier Allows VOIP
+ (BOOL)carrierAllowsVOIP;

@end
