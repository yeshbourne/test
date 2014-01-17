//
//  TMSSCoreLocationController.h
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol TMSSCoreLocationControllerDelegate
@required

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

@end


@interface TMSSCoreLocationController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locMgr;
    id delegate;
}

@property (nonatomic, retain) CLLocationManager *locMgr;
@property (nonatomic, strong) id delegate;

@end
