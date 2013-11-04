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

#define BUSA_SERVER_URL @"http://176.58.98.162:12334"
#define DEFAULT_RADIUS @100 //Radius in meters

@implementation BUSGTFSService
+ (void)findTrips:(NSNumber *)lat withLongitude:(NSNumber *)lon withRadiusInMeters:(NSNumber *)radius withBlock:(void (^)(NSArray *))block {
  if(!radius) {
    radius = DEFAULT_RADIUS;
  }
  NSString *reqUrl = [NSString stringWithFormat:@"%@/trips?lat=%@&lon=%@", BUSA_SERVER_URL, lat, lon];
  NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
  
  RKObjectMapping *tripMapping = [BUSTrip rkMapping];
  RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tripMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
  RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:req responseDescriptors:@[responseDescriptor]];
  
  NSLog(@"Sending request to %@...", reqUrl);
  [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
    block([result array]);
  } failure:nil];
  [operation start];
}

+ (void)getTripInfo:(NSString *)tripId withBlock:(void (^)(BUSTrip *))block {
  NSString *reqUrl = [NSString stringWithFormat:@"%@/trips/show?trip_id=%@", BUSA_SERVER_URL, tripId];
  reqUrl = [reqUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
  
  RKObjectMapping *tripMapping = [BUSTrip rkMapping];
  RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tripMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
  RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:req responseDescriptors:@[responseDescriptor]];
  
  NSLog(@"Sending request to %@...", reqUrl);
  [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
    block((BUSTrip* )[result firstObject]);
  } failure:nil];
  [operation start];
}

@end
