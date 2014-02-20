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
  NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
  BUSTripHistory *history = [BUSTripHistory MR_findFirstByAttribute:@"tripId" withValue:trip.Id inContext:context];
  if (!history) {
    history = [BUSTripHistory MR_createInContext:context];
  }
  
  history.hitTime = [NSDate date];
  history.tripId = trip.Id;
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
