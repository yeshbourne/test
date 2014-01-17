//
//  TMSSAccessoryInfo.h
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import "TMSSConstants.h"

@interface TMSSAccessoryInfo : NSObject

// Accessory Information

// Are any accessories attached?
+ (BOOL)accessoriesAttached;

// Are headphone attached?
+ (BOOL)headphonesAttached;

// Number of attached accessories
+ (NSInteger)numberAttachedAccessories;

// Name of attached accessory/accessories (seperated by , comma's)
+ (NSString *)nameAttachedAccessories;

@end
