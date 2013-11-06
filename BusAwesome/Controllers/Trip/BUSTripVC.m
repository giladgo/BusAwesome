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

@property (nonatomic, strong) BUSTrip *trip;
@property (nonatomic) StopHighlight highlight;
@property (nonatomic, strong) BUSStop *destinationStop;
@property (nonatomic, strong) BUSLocationService *locationService;
@property (nonatomic, strong) NSIndexPath *oldSelection;
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
    self.title = [NSString stringWithFormat:@"קו %@ לכיוון %@", trip.route.shortName, trip.destination ];
    
    // Setting the trip for each stop will cause a calculation of the projection of the stop on the trip.
    // Calculating the projection for all stops takes a really really long time (> 1s), so we're doing
    // it asynchronously.
    dispatch_async(_projCalcQ, ^{
      Underscore.arrayEach(self.trip.stops, ^(BUSStop* stop) {
        stop.trip = trip;
      });
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
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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


#define CLOSE_ENOUGH_TO_STOP 0.0001
- (void) updateHighlightFromLocation:(CLLocationCoordinate2D)coord
                                 withPrevStop:(BUSStop*)prevStop
                                 andAfterStop:(BUSStop*)afterStop
{
  float myProjection = [self.trip projectPoint:coord.latitude lon:coord.longitude];
  
  StopHighlight highlight;
  // if we are too close to either stations, highlight it only
  if (fabsf(prevStop.projectionOnTrip - myProjection) < CLOSE_ENOUGH_TO_STOP ) {
    highlight.stop1 = [self.trip indexOfStop:prevStop];
    highlight.stop2Higlighted = NO;
  }
  else if (fabsf(afterStop.projectionOnTrip - myProjection) < CLOSE_ENOUGH_TO_STOP ) {
    highlight.stop1 = [self.trip indexOfStop:afterStop];
    highlight.stop2Higlighted = NO;
  }
  else {
    highlight.stop1 = [self.trip indexOfStop:prevStop];
    highlight.stop2 = [self.trip indexOfStop:afterStop];
    highlight.stop2Higlighted = YES;
  }

  self.highlight = highlight;
}

- (void) updateUIFromLocation:(CLLocationCoordinate2D)coord
{
  BUSStop *prevStop;
  BUSStop *afterStop;
  
  [self.trip getBoundingStops:coord.latitude
                          lon:coord.longitude
                    afterStop:&afterStop
                     prevStop:&prevStop];
  
  [self updateHighlightFromLocation:coord
                       withPrevStop:prevStop
                       andAfterStop:afterStop];

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

// determine if we need to send a stop arrival notification, and send it if so (called
// from setHighlight below)
- (void) sendArrivalNotificationIfNecessary
{
  if (self.highlight.stop2Higlighted) {
    // case 1 for sending notification - when there is a second stop highlighted
    // and it's the destination selected by the user (more common)
    BUSStop *stop2 = self.trip.stops[self.highlight.stop2];
    if (self.destinationStop && stop2.stopId == self.destinationStop.stopId) {
      [self sendStopArrivalNotification];
    }
  }
  
  // case 2 for sending notification - when there is only one stop highlighted and
  // it's the destination stop. In theory this should happen less, but we add this
  // here just in case
  BUSStop *stop1 = self.trip.stops[self.highlight.stop1];
  if (self.destinationStop && stop1.stopId == self.destinationStop.stopId) {
    [self sendStopArrivalNotification];
  }

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
      
      [self sendArrivalNotificationIfNecessary];
      
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
  return self.trip.stops.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

-(void) setHighlightingForCell:(BUSStopCell *)stopCell withIndexPath:(NSIndexPath*)indexPath
{
  if (indexPath.row == self.highlight.stop1) {
    if (self.highlight.stop2Higlighted) {
      stopCell.highlightMode = StopHighlightModeStopAndBottom;
    }
    else {
      stopCell.highlightMode = StopHighlightModeStop;
    }
  }
  else if (self.highlight.stop2Higlighted && indexPath.row == self.highlight.stop2) {
    stopCell.highlightMode = StopHighlightModeStopAndTop;
  }
  else {
    stopCell.highlightMode = StopHighlightModeNone;
  }
}

- (void) setTerminusForCell:(BUSStopCell *)stopCell withIndexPath:(NSIndexPath*)indexPath
{
  if (indexPath.row == 0) {
    stopCell.terminusType = StopTerminusTypeStart;
  }
  else if (indexPath.row == (self.trip.stops.count - 1)) {
    stopCell.terminusType = StopTerminusTypeEnd;
  }
  else {
    stopCell.terminusType = StopTerminusTypeNone;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"BusStop";
  id cell =[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  if ([cell isKindOfClass:[BUSStopCell class]]) {
    BUSStopCell *stopCell = cell;
    BUSStop *stop = self.trip.stops[indexPath.row];

    stopCell.stopName = stop.name;
    [self setHighlightingForCell:stopCell withIndexPath:indexPath];
    [self setTerminusForCell:stopCell withIndexPath:indexPath];
    
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
  if (!self.oldSelection || (self.oldSelection.row != indexPath.row)) {
    BUSStop *destinationStop = self.trip.stops[indexPath.row];
    self.destinationStop = destinationStop;
  }
  self.oldSelection = nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  self.oldSelection = [self.tableView indexPathForSelectedRow];
  return indexPath;
}

@end
