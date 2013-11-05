//
//  BUSTrip.h
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUSRoute.h"
#import "BUSPath.h"
#import "RestKit.h"
#import "BUSStop.h"

@interface BUSTrip : NSObject
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSNumber *directionId;
@property (nonatomic, copy) NSNumber *shapeId;
@property (nonatomic) NSString *origin;
@property (nonatomic) NSString *destination;
@property (nonatomic, strong) NSArray *stops;
@property (nonatomic) BUSRoute *route;
@property (nonatomic) BUSPath *path;

+(RKObjectMapping *)rkMapping;

// Project a point on a trip and return how far the projection is down along the trip
- (float) projectPoint:(float)lat lon:(float)lon;

// Get the two stops in the trip which bound the give point's projection on the trip.
- (void) getBoundingStops:(float)lat lon:(float)lon afterStop:(BUSStop **)afterStop prevStop:(BUSStop **)prevStop;

- (NSUInteger) indexOfStop:(BUSStop*)stop;
@end
