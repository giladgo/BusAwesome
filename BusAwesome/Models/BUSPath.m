//
//  BUSPath.m
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSPath.h"

@implementation BUSPath
+(RKObjectMapping *)rkMapping {
  RKObjectMapping* pathMapping = [RKObjectMapping mappingForClass:[BUSPath class] ];
  [pathMapping addAttributeMappingsFromDictionary:@{
                                                    @"id":   @"Id",
                                                    @"shape_id":     @"shapeId",
                                                    @"path":     @"pathWKT",
                                                  }];
  return pathMapping;
}
@end
