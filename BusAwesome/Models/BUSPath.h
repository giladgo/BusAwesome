//
//  BUSPath.h
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestKit.h"

@interface BUSPath : NSObject
@property (nonatomic, copy) NSNumber *Id;
@property (nonatomic, copy) NSNumber *shapeId;
@property (nonatomic, copy) NSString *pathWKT;

+(RKObjectMapping *)rkMapping;
@end
