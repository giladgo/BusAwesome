//
//  BUSStop+TripProjection.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSStop+TripProjection.h"
#import "ShapeKitPolyline+Linearref.h"
#import <objc/runtime.h>
#import <ShapeKit/ShapeKit.h>


@implementation BUSStop (TripProjection)

@dynamic trip;
@dynamic projectionOnTrip;

static char TRIP_KEY = 0;
static char TRIP_PROJECTION_KEY = 0;


- (BUSTrip *)trip
{
  return objc_getAssociatedObject(self, &TRIP_KEY);
}

- (void)setTrip:(BUSTrip *)trip
{
  objc_setAssociatedObject(self, &TRIP_KEY, trip, OBJC_ASSOCIATION_ASSIGN /* == weak */);
  [self calcProjectionOnTrip];
}

- (void)calcProjectionOnTrip
{
  if (self.trip) {
    float projection = [self.trip projectPoint:[self.lat floatValue] lon:[self.lon floatValue]];
    objc_setAssociatedObject(self, &TRIP_PROJECTION_KEY, @(projection), OBJC_ASSOCIATION_COPY_NONATOMIC);
  }
}


- (float)projectionOnTrip
{
  if (!self.trip) {
    return -1.0;
  }
  
  id proj = objc_getAssociatedObject(self, &TRIP_PROJECTION_KEY);
  if (proj) {
    return [proj floatValue];
  }
  
  // if not found, calculate it and return its value
  [self calcProjectionOnTrip];
  return [objc_getAssociatedObject(self, &TRIP_PROJECTION_KEY) floatValue];
  
}

@end
