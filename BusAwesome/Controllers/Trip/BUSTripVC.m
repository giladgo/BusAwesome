//
//  BUSTripVC.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//



#import "BUSTripVC.h"
#import "BUSStopCell.h"
#import "BUSGTFSService.h"
#import "BUSStop.h"
#import "BUSStop+TripProjection.h"

@interface BUSTripVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) BUSTrip *trip;
@property (nonatomic) int highlightStart;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation BUSTripVC


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  for (CLLocation* location in locations) {
    [self updateUIFromLocation:location.coordinate];
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

  
  if ([CLLocationManager locationServicesEnabled]) {
    self.locationManager = [CLLocationManager new];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
  }
  else {
    NSLog(@"Location services disabled.");
  }
  
  [BUSGTFSService getTripInfo:self.tripId withBlock:^(BUSTrip *trip) {
    self.trip = trip;
    self.stops = [trip.stops copy];
    
    for (BUSStop *stop in self.stops) {
      stop.trip = trip;
    }
    
    [self.tableView reloadData];
  }];
}

- (void) updateUIFromLocation:(CLLocationCoordinate2D)coord
{
  float myProjection = [self.trip projectPoint:coord.latitude lon:coord.longitude];
  for (int i = 0; i < self.stops.count; i++) {
    BUSStop *stop = self.stops[i];
    if (stop.projectionOnTrip > myProjection) {
      self.highlightStart = i - 1;
      break;
    }
  }
}

- (void)setHighlightStart:(int)highlightStart
{
  if (highlightStart != _highlightStart) {
    _highlightStart = highlightStart;
    [self.tableView reloadData];
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.stops.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"BusStop";
  id cell =[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  if ([cell isKindOfClass:[BUSStopCell class]]) {
    BUSStopCell *stopCell = cell;
    BUSStop *stop = self.stops[indexPath.row];
    stopCell.stopName = stop.name;
    
    if (indexPath.row == self.highlightStart) {
      stopCell.highlightMode = StopHighlightModeStopAndBottom;
    }
    else if (indexPath.row == (self.highlightStart + 1)) {
      stopCell.highlightMode = StopHighlightModeStopAndTop;
    }
    else {
      stopCell.highlightMode = StopHighlightModeNone;
    }
    
    return stopCell;
  }
  
  return nil;
}

@end
