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


typedef struct {
  NSUInteger stop1;
  NSUInteger stop2;
  BOOL stop2Higlighted;
} StopHighlight;

@interface BUSTripVC () {
  dispatch_queue_t _projCalcQ;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) BUSTrip *trip;
@property (nonatomic) StopHighlight highlight;
@property (nonatomic, strong) BUSStop *destinationStop;
@property (nonatomic, strong) BUSLocationService *locationService;
@end

@implementation BUSTripVC


- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _projCalcQ = dispatch_queue_create("ProjCalcQueue", nil);
 
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.labelText = @"טוען תחנות...";
  
  self.locationService = [BUSLocationService new];
  self.locationService.delegate = self;
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
        
        [self.locationService startUpdatingLocation];
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
  [self.locationService stopUpdatingLocation];
}

- (void)appWillGoToForeground:(NSNotification *)notification
{
  [self.locationService startUpdatingLocation];
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
  
  NSUInteger afterIndex = [self.stops indexOfObject:@(myProjection)
                                      inSortedRange:NSMakeRange(0, self.stops.count)
                                            options:NSBinarySearchingInsertionIndex
                                    usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                      
                                      float proj1 = 0.0;
                                      if ([obj1 isKindOfClass:[NSNumber class]]) {
                                        proj1 = [obj1 floatValue];
                                      } else if ([obj1 conformsToProtocol:@protocol(HasTripProjection)]) {
                                        proj1 = ((id<HasTripProjection>)obj1).projectionOnTrip;
                                      }
                                      
                                      float proj2 = 0.0;
                                      if ([obj2 isKindOfClass:[NSNumber class]]) {
                                        proj2 = [obj2 floatValue];
                                      } else if ([obj1 conformsToProtocol:@protocol(HasTripProjection)]) {
                                        proj2 = ((id<HasTripProjection>)obj2).projectionOnTrip;
                                      }
                                      
                                      if (proj1 < proj2) {
                                        return NSOrderedAscending;
                                      } else if (proj2 < proj1) {
                                        return NSOrderedDescending;
                                      }
                                      return NSOrderedSame;
                                    }];
  
  BUSStop *afterStop = self.stops[afterIndex];
  BUSStop *prevStop = self.stops[afterIndex - 1];
  
  StopHighlight highlight;
#define CLOSE_ENOUGH_TO_STOP 0.0001
  // if we are too close to either stations, highlight it only
  if (fabsf(prevStop.projectionOnTrip - myProjection) < CLOSE_ENOUGH_TO_STOP ) {
    highlight.stop1 = afterIndex - 1;
    highlight.stop2Higlighted = NO;
  }
  else if (fabsf(afterStop.projectionOnTrip - myProjection) < CLOSE_ENOUGH_TO_STOP ) {
    highlight.stop1 = afterIndex;
    highlight.stop2Higlighted = NO;
  }
  else {
    highlight.stop1 = afterIndex - 1;
    highlight.stop2 = afterIndex;
    highlight.stop2Higlighted = YES;
  }
  
  self.highlight = highlight;
  
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

BOOL highlightDiff(StopHighlight h1, StopHighlight h2) {
  if (h1.stop1 != h2.stop1) {
    return YES;
  }
  
  if (h1.stop2Higlighted != h2.stop2Higlighted) {
    return YES;
  }
  
  if (h1.stop2Higlighted && h2.stop2Higlighted && h1.stop2 != h2.stop2) {
    return YES;
  }
  
  return NO;
}

- (void)setHighlight:(StopHighlight)highlight
{
  if (highlightDiff(highlight, _highlight)) {
    
    StopHighlight oldHiglight = _highlight;
    _highlight = highlight;

    if ([self.tableView numberOfRowsInSection:0]) {
      [self.tableView beginUpdates];
      
      NSMutableArray *indexesToUpdate = [NSMutableArray new];
      [indexesToUpdate addObject:[NSIndexPath indexPathForRow:oldHiglight.stop1 inSection:0]];
      [indexesToUpdate addObject:[NSIndexPath indexPathForRow:_highlight.stop1 inSection:0]];
      
      if (oldHiglight.stop2Higlighted) {
        [indexesToUpdate addObject:[NSIndexPath indexPathForRow:oldHiglight.stop2 inSection:0]];
      }
      if (_highlight.stop2Higlighted) {
        [indexesToUpdate addObject:[NSIndexPath indexPathForRow:_highlight.stop2 inSection:0]];
      }
      
      [self.tableView reloadRowsAtIndexPaths:Underscore.array(indexesToUpdate).uniq.unwrap
                            withRowAnimation:UITableViewRowAnimationNone];
      [self.tableView endUpdates];
      
      [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:highlight.stop1 inSection:0]
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
    
    if (indexPath.row == self.highlight.stop1) {
      stopCell.highlightMode = StopHighlightModeStopAndBottom;
    }
    else if (indexPath.row == self.highlight.stop2) {
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
    [self.locationService startUpdatingLocation];
  }
  else {
    [self.locationService stopUpdatingLocation];
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
