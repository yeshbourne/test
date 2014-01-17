//
//  TMSSLocalizationInfo.h
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import "TMSSConstants.h"

@interface TMSSLocalizationInfo : NSObject

// Localization Information

// Country
+ (NSString *)country;

// Language
+ (NSString *)language;

// TimeZone
+ (NSString *)timeZone;

// Currency Symbol
+ (NSString *)currency;

@end
