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
#import <HexColor.h>

#define SECTION_HEADER_HEIGHT 42

@interface BUSRouteListVC ()
@property (nonatomic, strong) NSDictionary *tripsByLines;
@property (nonatomic, strong) NSArray *lines;
@property (nonatomic, strong) NSDictionary *agencyColorsById;
@end

@implementation BUSRouteListVC

- (void)viewDidLoad
{
  [self initAgencyColors];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  
  [[BUSLocationService sharedInstance] getCurrentLocation:^(CLLocation  *location) {
    if (location.horizontalAccuracy <= 10.0 || location.verticalAccuracy <= 10.0) {
      [self updateTrips:location.coordinate];
    }
  }];
}

-(void)initAgencyColors
{
  NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"agency-colors" ofType:@"plist"];
  self.agencyColorsById = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
}

-(void)updateTrips:(CLLocationCoordinate2D)coordinate
{
  // TODO: due to error in server, we're reversing the lat/lon
  NSNumber *lat =[[NSNumber alloc] initWithDouble:coordinate.longitude];
  NSNumber *lon =  [[NSNumber alloc] initWithDouble:coordinate.latitude];

  [BUSGTFSService findTrips:lat withLongitude:lon withRadiusInMeters:nil withBlock:^(NSArray *trips) {
    self.tripsByLines = _.reduce(trips, [NSMutableDictionary new], ^(NSDictionary *memo, BUSTrip *trip) {
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
    self.lines = _.keys(self.tripsByLines);
    [self.tableView reloadData];
  }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  BUSRouteListCell *cell = (BUSRouteListCell*)[tableView dequeueReusableCellWithIdentifier:@"RouteList" forIndexPath:indexPath];
  NSString *lineName = self.lines[[indexPath section]];
  NSArray *trips = [self.tripsByLines objectForKey:lineName];
  BUSTrip *trip = trips[[indexPath row]];
  cell.routeNameLabel.text = [NSString stringWithFormat:@"לכיוון %@", trip.destination];
  return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  NSString *lineName = self.lines[section];
  NSArray *trips = self.tripsByLines[lineName];
  BUSTrip *aTrip = trips[0];
  NSString *agencyId = aTrip.route.agency.Id;
  NSString *agencyHexColor = self.agencyColorsById[agencyId];
  UIColor *agencyBGColor = [UIColor colorWithHexString:agencyHexColor alpha:1];
  
  // Create label with section title
  UILabel *lineLabel = [UILabel new];
  lineLabel.frame = CGRectMake(10, 6, 300, 30);
  lineLabel.backgroundColor = [UIColor clearColor];
  lineLabel.textColor = [UIColor whiteColor];
  lineLabel.textAlignment = UITextLayoutDirectionRight;
  lineLabel.font = [UIFont boldSystemFontOfSize:17];
  lineLabel.text = [NSString stringWithFormat:@"קו %@", aTrip.route.shortName];
  
  UILabel *agencyLabel = [UILabel new];
  agencyLabel.frame = CGRectMake(10, 6, 300, 30);
  agencyLabel.backgroundColor = [UIColor clearColor];
  agencyLabel.textColor = [UIColor whiteColor];
  agencyLabel.textAlignment = UITextLayoutDirectionLeft;
  agencyLabel.font = [UIFont boldSystemFontOfSize:17];
  agencyLabel.text = aTrip.route.agency.name;
  
  // Create header view and add label as a subview
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SECTION_HEADER_HEIGHT)];
  [view addSubview:lineLabel];
  [view addSubview:agencyLabel];
  view.backgroundColor = agencyBGColor;
  
  return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return SECTION_HEADER_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSString *lineName = self.lines[section];
  NSArray *trips = [self.tripsByLines objectForKey:lineName];
  return trips.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.lines.count;
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
