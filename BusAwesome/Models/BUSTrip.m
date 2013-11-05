//
//  BUSTrip.m
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSTrip.h"
#import "BUSStop.h"
#import "BUSStop+TripProjection.h"

#import <ShapeKit/ShapeKit.h>

@implementation BUSTrip
+ (RKObjectMapping *)rkMapping {
  RKObjectMapping *tripMapping = [RKObjectMapping mappingForClass:[BUSTrip class]];
  [tripMapping addAttributeMappingsFromDictionary:@{
                                                    @"id":   @"Id",
                                                    @"shape_id":     @"shapeId",
                                                    @"origin":     @"origin",
                                                    @"destination":     @"destination"
                                                    }];
  [tripMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"path" toKeyPath:@"path" withMapping:[BUSPath rkMapping]]];
  [tripMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"route" toKeyPath:@"route" withMapping:[BUSRoute rkMapping]]];
  [tripMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stops" toKeyPath:@"stops" withMapping:[BUSStop rkMapping]]];
  return tripMapping;
}

- (float) projectPoint:(float)lat lon:(float)lon
{
  if (self.path.pathWKT) {
    ShapeKitPolyline *polyLine = [[ShapeKitPolyline alloc] initWithWKT:self.path.pathWKT];
    
    ShapeKitPoint *pt = [[ShapeKitPoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lon)];
    return [polyLine distanceFromOriginToProjectionOfPoint:pt];
  }
  
  return -1.0;
}

- (NSUInteger) indexOfStop:(BUSStop*)busStop
{
  return [self.stops indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    return ((BUSStop*) obj).stopId == busStop.stopId;
  }];
}

// This is a special comparator which compares a BUSStop's trip projection to a float
NSComparisonResult stopProjectionComparator(id obj1, id obj2)
{
  float proj1 = 0.0;
  if ([obj1 isKindOfClass:[NSNumber class]]) {
    proj1 = [obj1 floatValue];
  } else if ([obj1 conformsToProtocol:@protocol(HasTripProjection)]) {
    proj1 = ((id<HasTripProjection>)obj1).projectionOnTrip;
  }
  
  float proj2 = 0.0;
  if ([obj2 isKindOfClass:[NSNumber class]]) {
    proj2 = [obj2 floatValue];
  } else if ([obj1 conformsToProtocol:@protocol(HasTripProjection)]) {
    proj2 = ((id<HasTripProjection>)obj2).projectionOnTrip;
  }
  
  if (proj1 < proj2) {
    return NSOrderedAscending;
  } else if (proj2 < proj1) {
    return NSOrderedDescending;
  }
  return NSOrderedSame;
}

- (void) getBoundingStops:(float)lat lon:(float)lon afterStop:(BUSStop **)afterStop prevStop:(BUSStop **)prevStop
{
  float myProjection = [self projectPoint:lat lon:lon];
  
  NSUInteger afterIndex = [self.stops indexOfObject:@(myProjection)
                                           inSortedRange:NSMakeRange(0, self.stops.count)
                                                 options:NSBinarySearchingInsertionIndex
                                         usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                           return stopProjectionComparator(obj1, obj2);
                                         }];
  
  *afterStop = self.stops[afterIndex];
  *prevStop = self.stops[afterIndex - 1];
}

@end
