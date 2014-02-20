//
//  BUSTripHistoryServiceSpec.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 2/20/14.
//  Copyright (c) 2014 Gilad Goldberg. All rights reserved.
//

#import "Kiwi.h"
#import "BUSTripHistory.h"
#import "BUSTripHistoryService.h"

SPEC_BEGIN(BUSTripHistoryServiceSpec)


describe(@"BUSTripHistoryServiceSpec", ^{
  
  beforeEach(^{
    [BUSTripHistoryService clear];
  });
  
  it(@"should hit a trip history successfully", ^{
    BUSTrip *trip = [BUSTrip new];
    trip.Id = @"ABCD";
    [BUSTripHistoryService hitTrip:trip];
  });
  
  it(@"should get a visited trip successfully", ^{
    BUSTrip *trip = [BUSTrip new];
    trip.Id = @"ABCD";
    [BUSTripHistoryService hitTrip:trip];
    
    NSArray *trips = [BUSTripHistoryService getTripHistory];
    BUSTripHistory *tripFromStore = [trips firstObject];
    
    [[tripFromStore.tripId should] equal:trip.Id];
  });
});

SPEC_END