//
//  BUSStop+TripProjection.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSStop.h"
#import "BUSTrip.h"

@protocol HasTripProjection <NSObject>

@property (nonatomic, strong) BUSTrip *trip;
@property (nonatomic, readonly) float projectionOnTrip;

@end

@interface BUSStop (TripProjection) <HasTripProjection>

@property (nonatomic, strong) BUSTrip *trip;
@property (nonatomic, readonly) float projectionOnTrip;

@end
