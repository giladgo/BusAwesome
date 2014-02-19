//
//  BUSLocationService.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 11/3/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^LocationBlock)(CLLocation *location);

@protocol BUSLocationServiceDelegate <NSObject>

- (void)didUpdateLocations:(NSArray *)locations;

@end

@interface BUSLocationService : NSObject

@property id<BUSLocationServiceDelegate> delegate;

- (void)getCurrentLocation:(LocationBlock)callback withAccuracy:(double)accuracy withTimeout:(NSTimeInterval)timeout;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;


@end
