//
//  BUSGTFSService.h
//  BusAwesome
//
//  Created by Itay Adler on 30/10/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUSTrip.h"

@interface BUSGTFSService : NSObject
-(void)findTrips:(NSNumber*)lat withLongitude:(NSNumber*)lon withRadiusInMeters:(NSNumber*)radius withBlock:(void (^)(NSArray *))block;
-(void)getTripInfo:(NSString*)tripId withBlock:(void (^)(BUSTrip *))block;
@end
