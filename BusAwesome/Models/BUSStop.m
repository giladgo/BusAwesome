//
//  BUSStop.m
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSStop.h"
#import "BUSRoute.h"

@implementation BUSStop
+ (RKObjectMapping *)rkMapping {
  RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[BUSStop class] ];
  [stopMapping addAttributeMappingsFromDictionary:@{
                                                     @"id":   @"stopId",
                                                     @"stop_sequence":     @"stopSequence",
                                                     @"code":     @"code",
                                                     @"name":     @"name",
                                                     @"description":     @"description",
                                                     @"lat":     @"lat",
                                                     @"lon":     @"lon",
                                                  }];
  return stopMapping;
}
@end
