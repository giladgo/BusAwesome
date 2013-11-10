//
//  BUSRouteListVCViewController.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/29/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <HexColor.h>
#import "UIViewController+IICNavigator.h"
#import "BUSRouteListVC.h"
#import "BUSGTFSService.h"
#import "BUSRouteListCell.h"
#import "BUSTripVC.h"
#import <MBProgressHUD.h>
#import "BUSRouteListSectionHeader.h"
#import <Underscore.h>
#define _ Underscore

@interface BUSRouteListVC ()
@property (nonatomic, strong) NSDictionary *tripsByLines;
@property (nonatomic, strong) NSArray *lines;
@property (nonatomic, strong) NSDictionary *agencyColorsById;
@property (nonatomic, weak) UIRefreshControl *refreshControl;
@property (nonatomic, strong) BUSLocationService *locationService;
@property (nonatomic) BOOL didLoadDataForTheFirstTime;

- (NSArray *)getTripsFromSection:(NSInteger)section;
@end

@implementation BUSRouteListVC

- (void)viewDidLoad
{
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.locationService = [[BUSLocationService alloc] initWithName:@"RouteList LS"];
  
  [self initAgencyColors];
  [self initRefreshControl];
  [self initRouteListData];
}

- (void)initRouteListData
{
  self.didLoadDataForTheFirstTime = false;
  [self refresh:nil];
}

- (void)initRefreshControl
{
  // Doing this way because the property is weak, so we need a local variable to keep
  // it in memory until we add it as a subview, which will retain it
  UIRefreshControl *refreshControl = [UIRefreshControl new];
  [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
  [self.tableView addSubview:refreshControl];
  [self showHUD:YES];
  self.refreshControl = refreshControl;
}

-(void)initAgencyColors
{
  NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"agency-colors" ofType:@"plist"];
  self.agencyColorsById = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
}

- (void)showHUD:(BOOL)show
{
  if (show) {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"טוען קווים קרובים...";
  } else {
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
  }
}

- (void)refresh:(UIRefreshControl *)refreshControl {
  [self.refreshControl beginRefreshing];
  [self.locationService getCurrentLocation:^(CLLocation  *location) {
    [self updateTrips:location.coordinate];
  } withAccuracy:20.0 withTimeout:1.5];
}

-(void)updateTrips:(CLLocationCoordinate2D)coordinate
{
  NSNumber *lat =[[NSNumber alloc] initWithDouble:coordinate.latitude];
  NSNumber *lon =  [[NSNumber alloc] initWithDouble:coordinate.longitude];

  [BUSGTFSService findTrips:lat withLongitude:lon withRadiusInMeters:nil withBlock:^(NSArray *trips) {
    self.tripsByLines = _.reduce(trips, [NSMutableDictionary new], ^(NSMutableDictionary *memo, BUSTrip *trip) {
      NSMutableArray *currentElement = [memo objectForKey:trip.route.shortName];
      if (!currentElement) {
        currentElement = [[NSMutableArray alloc] initWithArray:@[trip]];
      } else {
        [currentElement addObject:trip];
      }
      memo[trip.route.shortName] = currentElement;
      return memo;
    });
    self.lines = [_.keys(self.tripsByLines) sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
      NSNumber *first = @([((NSString *)a) integerValue]);
      NSNumber *second = @([((NSString *)b) integerValue]);
      return [first compare:second];
    }];
    self.didLoadDataForTheFirstTime = true;
    [self.tableView reloadData];
    [self showHUD:NO];
    [self.refreshControl endRefreshing];
  }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  BUSRouteListCell *cell = (BUSRouteListCell*)[tableView dequeueReusableCellWithIdentifier:@"RouteList" forIndexPath:indexPath];
  if (self.lines.count == 0 && !self.didLoadDataForTheFirstTime) return cell;
  
  NSArray *trips = [self getTripsFromSection:indexPath.section];
  if (trips.count == 0) {
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = @"לא נמצאו קווים עבור המיקום הנוכחי.";
  } else {
    BUSTrip *trip = trips[indexPath.row];
    cell.routeNameLabel.text = [NSString stringWithFormat:@"לכיוון %@", trip.destination];
  }
  return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  NSArray *trips = [self getTripsFromSection:section];
  if (trips.count == 0) return nil;
  
  BUSTrip *aTrip = trips[0];
  NSString *agencyId = aTrip.route.agency.Id;
  NSString *agencyHexColor = self.agencyColorsById[agencyId];
  UIColor *agencyBGColor = [UIColor colorWithHexString:agencyHexColor alpha:1];
  
  NSString *lineNumberCaption = [NSString stringWithFormat:@"קו %@", aTrip.route.shortName];
  NSString *agencyCaption = aTrip.route.agency.name;
  
  BUSRouteListSectionHeader *sectionHeader = [[BUSRouteListSectionHeader alloc] initWithLineNumber:lineNumberCaption withAgencyName:agencyCaption withBackgroundColor:agencyBGColor];
  return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (![self hasLines]) return [[self tableViewHeight] integerValue];
  return CELL_ROW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  if (![self hasLines]) return 0;
  return SECTION_HEADER_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  int rowsInSectionCount = [self getTripsFromSection:section].count;
  if (rowsInSectionCount == 0) return 1;
  return rowsInSectionCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if (self.lines.count == 0) return 1;
  return self.lines.count;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (self.lines.count > 0) return indexPath;
  return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (self.lines.count == 0) return;
  
  NSArray *trips = [self getTripsFromSection:indexPath.section];
  BUSTrip *trip = trips[indexPath.row];
  
  BUSTripVC *vc = (BUSTripVC*)[self viewFrom:@"Trip"];
  vc.tripId = trip.Id;
  
  [self.navigationController pushViewController:vc animated:YES];
}

- (NSArray *)getTripsFromSection:(NSInteger)section
{
  if (self.lines.count == 0) return @[];
  
  NSString *lineName = self.lines[section];
  return self.tripsByLines[lineName];
}

- (BOOL)hasLines
{
  return self.lines.count > 0;
}

- (NSNumber *)tableViewHeight
{
  return @(self.tableView.frame.size.height - self.refreshControl.frame.size.height);
}

@end
