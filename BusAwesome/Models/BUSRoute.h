//
//  BUSRoute.h
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUSAgency.h"
#import "RestKit.h"

@interface BUSRoute : NSObject
@property (nonatomic) NSString *Id;
@property (nonatomic) NSString *shortName;
@property (nonatomic) NSString *longName;
@property (nonatomic) NSString *routeDescription;
@property (nonatomic) BUSAgency *agency;

+(RKObjectMapping *)rkMapping;
@end
