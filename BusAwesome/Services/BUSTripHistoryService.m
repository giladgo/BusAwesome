//
//  BUSTripHistoryService.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 2/20/14.
//  Copyright (c) 2014 Gilad Goldberg. All rights reserved.
//

#import "BUSTripHistoryService.h"
#import "BUSTripHistory.h"
#import "BUSTrip.h"

@implementation BUSTripHistoryService

+ (void) hitTrip:(BUSTrip *)trip
{
  // TODO: What about Halufut?
  NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
  BUSTripHistory *history = [BUSTripHistory MR_findFirstWithPredicate: [NSPredicate predicateWithFormat:@"routeName == %@ AND directionDescription == %@",
                                                                        trip.route.shortName,
                                                                        trip.destination]
                                                            inContext:context];
  if (!history) {
    history = [BUSTripHistory MR_createInContext:context];
  }
  
  history.hitTime = [NSDate date];
  history.tripId = trip.Id;
  history.routeName = trip.route.shortName;
  history.directionDescription = trip.destination;
  
  [context MR_saveToPersistentStoreAndWait];
}

+ (NSArray *) getTripHistory
{
  return [BUSTripHistory MR_findAllSortedBy:@"hitTime" ascending:NO  inContext:[NSManagedObjectContext MR_defaultContext]];
}
+ (void)clear
{
  [BUSTripHistory MR_deleteAllMatchingPredicate:[NSPredicate predicateWithValue:YES]];
}
@end
