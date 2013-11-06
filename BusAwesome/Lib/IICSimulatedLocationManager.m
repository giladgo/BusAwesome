//
//  IICSimulatedLocationManager.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 11/3/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "IICSimulatedLocationManager.h"
#import <Simple-KML/SimpleKML.h>
#import <Simple-KML/SimpleKMLDocument.h>
#import <Simple-KML/SimpleKMLPlacemark.h>
#import <Simple-KML/SimpleKMLLineString.h>

@interface IICSimulatedLocationManager()

@property (nonatomic, strong) SimpleKML *kml;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic) int currentStep;

@end

@implementation IICSimulatedLocationManager

- (id) initWithKML:(NSString *)kmlFile
{
  if (self = [super init]) {
    NSError *error;
    self.kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kmlFile ofType:@"kml"] error:&error];
    if (error) {
      NSLog(@"Error loading KML file: %@", error);
    }
    
    
    if ([self.kml.feature isKindOfClass:[SimpleKMLDocument class]]) {
      SimpleKMLDocument *doc = (SimpleKMLDocument *)self.kml.feature;
      for (SimpleKMLFeature *feature in doc.features)
      {
        if ([feature isKindOfClass:[SimpleKMLPlacemark class]]) {
          [self handlePlacemark:(SimpleKMLPlacemark *)feature];
        }
      }
    }
    else if ([self.kml.feature isKindOfClass:[SimpleKMLPlacemark class]]) {
      [self handlePlacemark:(SimpleKMLPlacemark *)self.kml.feature];
    }
    
    self.currentStep = 0;
  }
  
  return self;
}

- (void) handlePlacemark:(SimpleKMLPlacemark *)placemark
{
  NSMutableArray *locations = [NSMutableArray new];
  
  SimpleKMLLineString *lineString;
  if (placemark.lineString) {
    lineString = placemark.lineString;
  }
  else if (placemark.geometry) {
    lineString = (SimpleKMLLineString*)placemark.firstGeometry;
  }
  
  for (CLLocation *location in lineString.coordinates) {
    [locations addObject:location];
    NSLog(@"IIC Simulated Location Manager adding location: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
  }
  
  self.locations = locations;

}

- (void) step
{
  if (self.delegate) {
    CLLocation *location = self.locations[self.currentStep];
    NSLog(@"IIC Simulated Location Manager reporting location: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
    [self.delegate locationManager:self didUpdateLocations:@[location]];
  }
  self.currentStep++;
  
  if (self.currentStep == self.locations.count) {
    self.currentStep = 0;
  }
}

- (void)startUpdatingLocation
{
  if (self.locations) {
    // not calling super on purpose
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(step) userInfo:nil repeats:YES];
  }
  else {
    [super startUpdatingLocation];
  }


}

- (void)stopUpdatingLocation
{
  if (self.locations) {
    // not calling super on purpose
    [self.timer invalidate];
  }
  else {
    [super stopUpdatingLocation];
  }


}



@end
