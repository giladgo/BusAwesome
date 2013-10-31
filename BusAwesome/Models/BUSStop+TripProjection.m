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

- (float) projectOnTrip:(BUSTrip *) trip
{
  return [trip projectPoint:[self.lat floatValue] lon:[self.lon floatValue]];
}

- (BUSTrip *)trip
{
  return objc_getAssociatedObject(self, @selector(trip));
}

- (void)setTrip:(BUSTrip *)trip
{
  objc_setAssociatedObject(self, @selector(trip), trip, OBJC_ASSOCIATION_ASSIGN /* == weak */);
}

- (float)projectionOnTrip
{
  if (!self.trip) {
    return -1.0;
  }
  
  id proj = objc_getAssociatedObject(self, @selector(projectionOnTrip));
  if (proj) {
    return [proj floatValue];
  }
  
  float projection = [self projectOnTrip:self.trip];
  objc_setAssociatedObject(@(projection), @selector(projectionOnTrip), [NSNumber numberWithFloat:projection], OBJC_ASSOCIATION_COPY_NONATOMIC);
  
  return projection;
}

@end
