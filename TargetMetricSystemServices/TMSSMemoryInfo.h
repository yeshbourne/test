//
//  TMSSMemoryInfo.h
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import "TMSSConstants.h"

@interface TMSSMemoryInfo : NSObject

// Memory Information

// Total Memory
+ (double)totalMemory;

// Free Memory
+ (double)freeMemory:(BOOL)inPercent;

// Used Memory
+ (double)usedMemory:(BOOL)inPercent;

// Active Memory
+ (double)activeMemory:(BOOL)inPercent;

// Inactive Memory
+ (double)inactiveMemory:(BOOL)inPercent;

// Wired Memory
+ (double)wiredMemory:(BOOL)inPercent;

// Purgable Memory
+ (double)purgableMemory:(BOOL)inPercent;

@end
