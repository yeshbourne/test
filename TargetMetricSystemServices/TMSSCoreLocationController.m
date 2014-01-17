//
//  TMSSCoreLocationController.m
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import "TMSSCoreLocationController.h"


@implementation TMSSCoreLocationController

@synthesize locMgr, delegate;

- (id)init {
	self = [super init];
	
	if(self != nil) {
		self.locMgr = [[CLLocationManager alloc] init];
		self.locMgr.delegate = self;
	}
	
	return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if([self.delegate conformsToProtocol:@protocol(TMSSCoreLocationControllerDelegate)]) {
		[self.delegate locationUpdate:newLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if([self.delegate conformsToProtocol:@protocol(TMSSCoreLocationControllerDelegate)]) {
		[self.delegate locationError:error];
	}
}

- (void)dealloc {

}

@end
