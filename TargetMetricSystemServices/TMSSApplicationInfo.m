//
//  TMSSApplicationInfo.m
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import "TMSSApplicationInfo.h"

@implementation TMSSApplicationInfo


// Application Information

// Application Version
+ (NSString *)applicationVersion {
    // Get the Application Version Number
    @try {
        // Query the plist for the version
        NSString *Version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        // Validate the Version
        if (Version == nil || Version.length <= 0) {
            // Invalid Version number
            return nil;
        }
        // Successful
        return Version;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}



@end
