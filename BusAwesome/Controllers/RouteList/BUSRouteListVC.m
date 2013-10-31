//
//  BUSRouteListVCViewController.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/29/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "UIViewController+IICNavigator.h"
#import "BUSRouteListVC.h"
#import "BUSGTFSService.h"
#import "BUSRouteListCell.h"
#import "BUSTripVC.h"

@interface BUSRouteListVC ()
@property (nonatomic, strong) NSArray *trips;
@property (nonatomic, strong) NSDictionary *tripsByLines;
@property (nonatomic, strong) NSArray *lines;
@end

@implementation BUSRouteListVC

- (void)viewDidLoad {
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  BUSGTFSService *service = [BUSGTFSService new];
  [service findTrips:@34.810998 withLongitude:@32.080251 withRadiusInMeters:nil withBlock:^(NSArray *trips) {
    self.trips = trips;
    
    NSMutableDictionary *reduceResult = _.reduce(trips, [NSMutableDictionary new], ^(NSDictionary *memo, BUSTrip *trip) {
      NSMutableArray *currentElement = [memo objectForKey:trip.route.shortName];
      if (!currentElement) {
        currentElement = [[NSMutableArray alloc] initWithArray:@[trip]];
      }
      else {
        [currentElement addObject:trip];
      }
      [memo setValue:currentElement forKey:trip.route.shortName];
      return memo;
    });
    self.tripsByLines = reduceResult;
    self.lines = _.keys(self.tripsByLines);
    [self.tableView reloadData];
  }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BUSRouteListCell *cell = (BUSRouteListCell*)[tableView dequeueReusableCellWithIdentifier:@"RouteList" forIndexPath:indexPath];
  NSString *lineName = self.lines[[indexPath section]];
  NSArray *trips = [self.tripsByLines objectForKey:lineName];
  BUSTrip *trip = trips[[indexPath row]];
  cell.routeNameLabel.text = [NSString stringWithFormat:@"לכיוון %@", trip.destination];
  return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
  if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
    
    UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
    tableViewHeaderFooterView.textLabel.textAlignment = UITextAlignmentRight;
    tableViewHeaderFooterView.textLabel.textColor = [UIColor blueColor];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSString *lineName = self.lines[section];
  NSArray *trips = [self.tripsByLines objectForKey:lineName];
  return trips.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.lines.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return self.lines[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *lineName = self.lines[indexPath.section];
  NSArray *trips = [self.tripsByLines objectForKey:lineName];
  BUSTrip *trip = trips[indexPath.row];
  
  BUSTripVC *vc = (BUSTripVC*)[self viewFrom:@"Trip"];
  vc.tripId = trip.Id;
  
  [self.navigationController pushViewController:vc animated:YES];
}

@end
