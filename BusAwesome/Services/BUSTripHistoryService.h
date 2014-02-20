//
//  BUSTripHistoryService.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 2/20/14.
//  Copyright (c) 2014 Gilad Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BUSTrip.h"

@interface BUSTripHistoryService : NSObject

+ (void) hitTrip:(BUSTrip *)trip;

+ (NSArray *) getTripHistory;

+ (void) clear;

@end
