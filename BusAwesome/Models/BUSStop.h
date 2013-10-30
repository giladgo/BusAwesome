//
//  BUSStop.h
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BUSStop : NSObject

@property (nonatomic) int stopId;
@property (nonatomic) int stopSequnce;
@property (nonatomic) int code;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic) float lat;
@property (nonatomic) float lon;

@end
