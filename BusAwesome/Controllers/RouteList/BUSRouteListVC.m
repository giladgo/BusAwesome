//
//  BUSRouteListVCViewController.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/29/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSRouteListVC.h"
#import "BUSGTFSService.h"

@interface BUSRouteListVC ()

@end

@implementation BUSRouteListVC

- (void)viewDidLoad {
  BUSGTFSService *service = [BUSGTFSService new];
  [service findTrips:@34.810998 withLongitude:@32.080251 withRadiusInMeters:nil withBlock:^(NSArray *trips) {
    NSLog(@"The trips: %@", trips);
  }];
}

@end
