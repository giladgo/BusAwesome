//
//  BUSRouteListVCViewController.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/29/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSRouteListVC.h"
#import "BUSGTFSService.h"
#import "BUSRouteListCell.h"

@interface BUSRouteListVC ()
@property (nonatomic, strong) NSArray *trips;
@end

@implementation BUSRouteListVC

- (void)viewDidLoad {
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  BUSGTFSService *service = [BUSGTFSService new];
  [service findTrips:@34.810998 withLongitude:@32.080251 withRadiusInMeters:nil withBlock:^(NSArray *trips) {
    self.trips = trips;
    [service getTripInfo:trips[0] withBlock:^(BUSTrip *trip) {
      NSLog(@"Trip info %@", trip);
    }];
    [self.tableView reloadData];
  }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BUSRouteListCell *cell = (BUSRouteListCell*)[tableView dequeueReusableCellWithIdentifier:@"RouteList" forIndexPath:indexPath];
  BUSTrip *trip = self.trips[indexPath.item];
  cell.lineNumLabel.text = trip.route.shortName;
  cell.lineDescriptionLabel.text = trip.route.longName;
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.trips.count;
}

@end
