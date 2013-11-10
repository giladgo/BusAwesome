//
//  BUSLocationService.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 11/3/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSLocationService.h"
#import "IICSimulatedLocationManager.h"

#import <CoreLocation/CoreLocation.h>

@interface BUSLocationService() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) LocationBlock singleLocationCallback;
@property (nonatomic) double singleLocationAccuracy;
@property (nonatomic, strong) NSTimer *singleLocationTimer;
@property (nonatomic, strong) CLLocation *singleLocation;
@property (strong, nonatomic, readwrite) NSString *name;
@end

@implementation BUSLocationService

- (id)initWithName:(NSString *)name
{
  if (self = [super init]) {
    self.name = name;
#if TARGET_IPHONE_SIMULATOR
    self.locationManager = [[IICSimulatedLocationManager alloc] initWithKML:@"bus161"];
#else
    self.locationManager = [[CLLocationManager alloc] init];
#endif
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // TODO: change this to ten meters
    self.locationManager.delegate = self;
  }
  return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  [self.delegate didUpdateLocations:locations];
  
  if (self.singleLocationCallback) {
    CLLocation *location = [locations firstObject]; // usually the first one is good enough

    NSLog(@"Did update location, acc %f, r_acc %f loc_count %d", location.horizontalAccuracy, self.singleLocationAccuracy, locations.count);
    self.singleLocation = location;
    if (location.horizontalAccuracy <= self.singleLocationAccuracy) {
      [self fireSingleLocationCallback];
    }
  }
}

- (void)fireSingleLocationCallback
{
  NSLog(@"[%@] Firing single location callback - %f %f", self.name, self.singleLocation.coordinate.latitude, self.singleLocation.coordinate.longitude);
  [self stopUpdatingLocation];
  self.singleLocationCallback(self.singleLocation);

  self.singleLocationCallback = nil;
  self.singleLocation = nil;
  [self.singleLocationTimer invalidate];
  self.singleLocationTimer = nil;
}

- (void)singleLocationTimeout:(NSTimer *)timer
{
  NSLog(@"Single location timeout, best accuracy = %f", self.singleLocation.horizontalAccuracy);
  [self fireSingleLocationCallback];
}

- (void)getCurrentLocation:(LocationBlock)callback withAccuracy:(double)accuracy withTimeout:(NSTimeInterval)timeout
{
  NSLog(@"[%@] Single location request", self.name);
  self.singleLocationCallback = callback;
  self.singleLocationAccuracy = accuracy;
  if (self.singleLocationTimer) {
    [self.singleLocationTimer invalidate];
    self.singleLocationTimer = nil;
  }
  self.singleLocationTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                              target:self
                                                            selector:@selector(singleLocationTimeout:)
                                                            userInfo:nil
                                                             repeats:NO];
    self.singleLocationTimer.tolerance = 0.5; // we're not that pedantic
  [self startUpdatingLocation];
}

- (void)startUpdatingLocation
{
  NSLog(@"[%@] Start updating location", self.name);
  [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
  NSLog(@"[%@] Stop updating location", self.name);
  [self.locationManager stopUpdatingLocation];
  
}

@end
