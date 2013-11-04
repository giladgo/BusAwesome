//
//  BUSTripVC.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import <Underscore.h>
#import <Underscore+Functional.h>

#import "BUSTripVC.h"
#import "BUSStopCell.h"
#import "BUSGTFSService.h"
#import "BUSStop.h"
#import "BUSStop+TripProjection.h"


@interface BUSTripVC () {
  dispatch_queue_t _projCalcQ;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) BUSTrip *trip;
@property (nonatomic) int highlightStart;
@property (nonatomic, strong) BUSStop *destinationStop;
@end

@implementation BUSTripVC


- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _projCalcQ = dispatch_queue_create("ProjCalcQueue", nil);
 
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.labelText = @"טוען תחנות...";
  
  [BUSLocationService sharedInstance].delegate = self;
  [self setupNotifications];
  
  [BUSGTFSService getTripInfo:self.tripId withBlock:^(BUSTrip *trip) {
    self.trip = trip;
    self.stops = [trip.stops copy];
    self.title = [NSString stringWithFormat:@"קו %@ לכיוון %@", trip.route.shortName, trip.destination ];
    
    // Setting the trip for each stop will cause a calculation of the projection of the stop on the trip.
    // Calculating the projection for all stops takes a really really long time (> 1s), so we're doing
    // it asynchronously.
    dispatch_async(_projCalcQ, ^{
      for (BUSStop *stop in self.stops) {
        stop.trip = trip;
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        [[BUSLocationService sharedInstance] startUpdatingLocation];
      });
    });
    
  }];
}

- (void) setupNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(appHasGoneInBackground:)
                                               name:UIApplicationDidEnterBackgroundNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(appWillGoToForeground:)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
}

- (void) teardownNotifications
{
  
}

- (void)appHasGoneInBackground:(NSNotification *)notification
{
  [[BUSLocationService sharedInstance] stopUpdatingLocation];
}

- (void)appWillGoToForeground:(NSNotification *)notification
{
  [[BUSLocationService sharedInstance] startUpdatingLocation];
}

- (void) viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
}



- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [self teardownNotifications];
}


- (void) updateUIFromLocation:(CLLocationCoordinate2D)coord
{
  NSLog(@"Got coordinate: %f, %f", coord.latitude, coord.latitude);
  float myProjection = [self.trip projectPoint:coord.latitude lon:coord.longitude];
  
  for (int i = 0; i < self.stops.count; i++) {
    BUSStop *stop = self.stops[i];
    if (stop.projectionOnTrip > myProjection) {
      self.highlightStart = i - 1;
      
      if (self.destinationStop && stop.stopId == self.destinationStop.stopId) {
        [self sendStopArrivalNotification];
      }
      
      break;
    }
  }
  
  // Doing this here and not in the end of viewDidLoad because we want to
  // hide the progress HUD only after the first location has arrived
  // (and not when finished loading the stops)
  [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}

- (void)didUpdateLocations:(NSArray *)locations
{
  for (CLLocation* location in locations) {
    [self updateUIFromLocation:location.coordinate];
  }
}

- (void)setHighlightStart:(int)highlightStart
{
  if (highlightStart != _highlightStart) {
    
    int oldHiglightStart = _highlightStart;
    _highlightStart = highlightStart;

    if ([self.tableView numberOfRowsInSection:0]) {
      [self.tableView beginUpdates];
      NSArray* indexesToUpdate = Underscore.array( @[
                                   [NSIndexPath indexPathForRow:oldHiglightStart   inSection:0],
                                   [NSIndexPath indexPathForRow:oldHiglightStart+1 inSection:0],
                                   [NSIndexPath indexPathForRow:_highlightStart    inSection:0],
                                   [NSIndexPath indexPathForRow:_highlightStart+1  inSection:0]
                                   ]).uniq.unwrap;
      
      [self.tableView reloadRowsAtIndexPaths:indexesToUpdate
                            withRowAnimation:UITableViewRowAnimationNone];
      [self.tableView endUpdates];
      
      [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_highlightStart inSection:0]
                            atScrollPosition:UITableViewScrollPositionMiddle
                                    animated:YES];
    }
    


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

- (void) sendStopArrivalNotification
{
  UILocalNotification *notification = [UILocalNotification new];
  notification.alertBody = [NSString stringWithFormat:@"עוד מעט מגיעים ל%@!", self.destinationStop.name];
  notification.soundName = UILocalNotificationDefaultSoundName;
  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
  
  self.destinationStop = nil;
}


- (void)setDestinationStop:(BUSStop *)destinationStop
{
  if (destinationStop) {
    [[BUSLocationService sharedInstance] startUpdatingLocation];
  }
  else {
    [[BUSLocationService sharedInstance] stopUpdatingLocation];
  }
  _destinationStop = destinationStop;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  self.destinationStop = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  BUSStop *destinationStop = self.stops[indexPath.row];
  self.destinationStop = destinationStop;
}

@end
