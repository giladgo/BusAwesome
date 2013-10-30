//
//  BUSStop.h
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestKit.h"

@interface BUSStop : NSObject

@property (nonatomic, copy) NSNumber* stopId;
@property (nonatomic, copy) NSNumber* stopSequence;
@property (nonatomic, copy) NSNumber* code;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lon;

+(RKObjectMapping *)rkMapping;
@end
