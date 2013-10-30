//
//  BUSGTFSService.m
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSGTFSService.h"
#import "BUSTrip.h"
#import <RestKit.h>

#define BUSA_SERVER_URL @"http://busa.dev"

@implementation BUSGTFSService
- (void)findTrips:(NSNumber *)lat withLongitude:(NSNumber *)lon withRadiusInMeters:(NSNumber *)radius withBlock:(void (^)(NSArray *))block {
  if(!radius) {
    radius = @100;
  }
  NSString *reqUrl = [NSString stringWithFormat:@"%@/trips?lat=%@&lon=%@", BUSA_SERVER_URL, lat, lon];
  NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];

  //Setting up related mappings (Trip has_one Route)
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
  
  RKObjectMapping *tripMapping = [RKObjectMapping mappingForClass:[BUSTrip class]];
  [tripMapping addAttributeMappingsFromDictionary:@{
                                                @"id":   @"Id",
                                                @"shape_id":     @"shapeId"
                                                }];
  [tripMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"route" toKeyPath:@"route" withMapping:routeMapping]];
  RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tripMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
  RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:req responseDescriptors:@[responseDescriptor]];
  
  [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
    block([result array]);
  } failure:nil];
  [operation start];
}
@end
