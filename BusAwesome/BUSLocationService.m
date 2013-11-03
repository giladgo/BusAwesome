//
//  BUSLocationService.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 11/3/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSLocationService.h"

#import <CoreLocation/CoreLocation.h>

@interface BUSLocationService() <CLLocationManagerDelegate> {
  
  // This is simple 'reference' counter which counts how many times 'startLocationUpdates'
  // was called vs. how many times 'stopLocatiopnUpdates' was called.
  int _locationRefCount;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) LocationBlock singleLocationCallback;
@end

@implementation BUSLocationService

+ (instancetype)sharedInstance
{
  static BUSLocationService *_sharedInstance;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{ _sharedInstance = [[BUSLocationService alloc] privateInit]; });
  return _sharedInstance;
}

- (id)privateInit
{
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // TODO: change this to ten meters
  self.locationManager.delegate = self;
  return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  [self.delegate didUpdateLocations:locations];
  
  if (self.singleLocationCallback) {
    [self stopUpdatingLocation];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:32.080251 longitude:34.810998];
    self.singleLocationCallback(location); // usually the first one is good enough
    self.singleLocationCallback = nil;
  }
}

- (void)getCurrentLocation:(LocationBlock)callback
{
  [self startUpdatingLocation];
  self.singleLocationCallback = callback;
}

- (void)startUpdatingLocation
{
  if (_locationRefCount == 0) {
    _locationRefCount++;
    if ([CLLocationManager locationServicesEnabled]) {
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
    if ([CLLocationManager locationServicesEnabled]) {
      [self.locationManager stopUpdatingLocation];
    }
  }
}

@end
