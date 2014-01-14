//
//  TMSSHardwareInfo.h
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import "TMSSConstants.h"

@interface TMSSHardwareInfo : NSObject

// System Hardware Information

// System Uptime (dd hh mm)
+ (NSString *)systemUptime;

// Model of Device
+ (NSString *)deviceModel;

// Device Name
+ (NSString *)deviceName;

// System Name
+ (NSString *)systemName;

// System Version
+ (NSString *)systemVersion;

// System Device Type (iPhone1,0) (Formatted = iPhone 1)
+ (NSString *)systemDeviceTypeFormatted:(BOOL)formatted;

// Get the Screen Width (X)
+ (NSInteger)screenWidth;

// Get the Screen Height (Y)
+ (NSInteger)screenHeight;

// Get the Screen Brightness
+ (float)screenBrightness;

// Multitasking enabled?
+ (BOOL)multitaskingEnabled;

// Proximity sensor enabled?
+ (BOOL)proximitySensorEnabled;

// Debugger Attached?
+ (BOOL)debuggerAttached;

// Plugged In?
+ (BOOL)pluggedIn;


@end
