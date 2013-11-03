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
+ (void)findTrips:(NSNumber *)lat withLongitude:(NSNumber *)lon withRadiusInMeters:(NSNumber *)radius withBlock:(void (^)(NSArray *))block {
  if(!radius) {
    radius = @100;
  }
  NSString *reqUrl = [NSString stringWithFormat:@"%@/trips?lat=%@&lon=%@", BUSA_SERVER_URL, lat, lon];
  NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
  
  RKObjectMapping *tripMapping = [BUSTrip rkMapping];
  RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tripMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
  RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:req responseDescriptors:@[responseDescriptor]];
  
  [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
    block([result array]);
  } failure:nil];
  [operation start];
}

+ (void)getTripInfo:(NSString *)tripId withBlock:(void (^)(BUSTrip *))block {
  NSString *reqUrl = [NSString stringWithFormat:@"%@/trips/%@", BUSA_SERVER_URL, tripId];
  NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
  
  RKObjectMapping *tripMapping = [BUSTrip rkMapping];
  RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tripMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
  RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:req responseDescriptors:@[responseDescriptor]];
  
  [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
    block((BUSTrip* )[result firstObject]);
  } failure:nil];
  [operation start];
}

@end
