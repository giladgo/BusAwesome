//
//  BUSRoute.m
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSRoute.h"
#import "RestKit.h"

@implementation BUSRoute
+ (RKObjectMapping *)rkMapping {
  RKObjectMapping* agencyMapping = [RKObjectMapping mappingForClass:[BUSAgency class] ];
  [agencyMapping addAttributeMappingsFromDictionary:@{
                                                      @"id":   @"Id",
                                                      @"name":     @"name"
                                                      }];
  
  //Setting up related mappings (Trip has_one Route)
  RKObjectMapping* routeMapping = [RKObjectMapping mappingForClass:[BUSRoute class] ];
  [routeMapping addAttributeMappingsFromDictionary:@{
                                                     @"id":   @"Id",
                                                     @"route_short_name":     @"shortName",
                                                     @"route_long_name":     @"longName",
                                                     @"route_desc":     @"routeDescription",
                                                     }];
  [routeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"agency" toKeyPath:@"agency" withMapping:agencyMapping]];
  return routeMapping;
}

@end
