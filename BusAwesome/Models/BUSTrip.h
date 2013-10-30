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

@interface BUSTrip : NSObject
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSNumber *directionId;
@property (nonatomic, copy) NSNumber *shapeId;
@property (nonatomic) NSArray *stops;
@property (nonatomic) BUSRoute *route;
@property (nonatomic) BUSPath *path;
@end
