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

-(instancetype) init __attribute__((unavailable("init not available")));
+ (instancetype) sharedInstance;

- (void)getCurrentLocation:(LocationBlock)callback;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;


@end
