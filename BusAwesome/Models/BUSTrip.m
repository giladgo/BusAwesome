//
//  BUSTrip.m
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSTrip.h"
#import "BUSStop.h"

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
    return [polyLine normalizedDistanceFromOriginToProjectionOfPoint:pt];
  }
  
  return -1.0;
}

@end
