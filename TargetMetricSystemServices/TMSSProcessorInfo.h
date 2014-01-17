//
//  TMSSProcessorInfo.h
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import "TMSSConstants.h"

@interface TMSSProcessorInfo : NSObject

// Processor Information

// Number of processors
+ (NSInteger)numberProcessors;

// Number of Active Processors
+ (NSInteger)numberActiveProcessors;

// Processor Speed in MHz
+ (NSInteger)processorSpeed;

// Processor Bus Speed in MHz
+ (NSInteger)processorBusSpeed;

@end
