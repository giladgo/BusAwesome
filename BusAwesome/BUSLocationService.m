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

@interface BUSLocationService() <CLLocationManagerDelegate> {
  
  // This is simple 'reference' counter which counts how many times 'startLocationUpdates'
  // was called vs. how many times 'stopLocatiopnUpdates' was called.
  int _locationRefCount;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) LocationBlock singleLocationCallback;
@property (nonatomic) double singleLocationAccuracy;
@property (nonatomic, strong) NSTimer *singleLocationTimer;
@property (nonatomic, strong) CLLocation *singleLocation;
@end

@implementation BUSLocationService

- (id)init
{
  if (self = [super init]) {
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
  NSLog(@"Firing single location callback");
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
  _locationRefCount++;
  NSLog(@"BUSLS rc = %d", _locationRefCount);
  
  if (_locationRefCount == 1) {
    if ([CLLocationManager locationServicesEnabled]) {
      NSLog(@"BUSLS starting");
      [self.locationManager startUpdatingLocation];
    }
    else {
      NSLog(@"Location services disabled.");
    }
  }
}

- (void)stopUpdatingLocation
{
  if (_locationRefCount > 0) {
    _locationRefCount--;
    
    NSLog(@"BUSLS rc = %d", _locationRefCount);
    
    if (_locationRefCount == 0) {
      if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"BUSLS stopping");
        [self.locationManager stopUpdatingLocation];
      }
    }
  }
  
}

@end
