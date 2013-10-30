//
//  BUSTrip.m
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSTrip.h"
#import "BUSStop.h"

@implementation BUSTrip
+ (RKObjectMapping *)rkMapping {
  RKObjectMapping *tripMapping = [RKObjectMapping mappingForClass:[BUSTrip class]];
  [tripMapping addAttributeMappingsFromDictionary:@{
                                                    @"id":   @"Id",
                                                    @"shape_id":     @"shapeId"
                                                    }];
  [tripMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"path" toKeyPath:@"path" withMapping:[BUSPath rkMapping]]];
  [tripMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"route" toKeyPath:@"route" withMapping:[BUSRoute rkMapping]]];
  [tripMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stops" toKeyPath:@"stops" withMapping:[BUSStop rkMapping]]];
  return tripMapping;
}
@end
