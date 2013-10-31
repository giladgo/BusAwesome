//
//  BUSStop+TripProjection.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSStop.h"
#import "BUSTrip.h"

@interface BUSStop (TripProjection)

@property (nonatomic, strong) BUSTrip *trip;
@property (nonatomic, readonly) float projectionOnTrip;

@end
