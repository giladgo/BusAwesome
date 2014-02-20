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
  
  __block BUSTrip *mockTrip;
  
  beforeAll(^{
    mockTrip = [BUSTrip new];
    mockTrip.destination = @"HOME";
    mockTrip.route = [BUSRoute new];
    mockTrip.route.shortName = @"61";
    mockTrip.Id = @"ABCDEFG";
  });
  
  beforeEach(^{
    [BUSTripHistoryService clear];
  });
  
  it(@"should hit a trip history successfully", ^{
    [BUSTripHistoryService hitTrip:mockTrip];
  });
  
  it(@"should get a visited trip successfully", ^{
    [BUSTripHistoryService hitTrip:mockTrip];
    
    NSArray *trips = [BUSTripHistoryService getTripHistory];
    BUSTripHistory *tripFromStore = [trips firstObject];
    
    [[tripFromStore.directionDescription should] equal:mockTrip.destination];
    [[tripFromStore.routeName should] equal:mockTrip.route.shortName];
  });
  
  it(@"should return only one trip after hitting the same trip twice", ^{
    [BUSTripHistoryService hitTrip:mockTrip];
    [NSThread sleepForTimeInterval:1];
    [BUSTripHistoryService hitTrip:mockTrip];
    
    NSArray *trips = [BUSTripHistoryService getTripHistory];
    
    [[theValue(trips.count) should] equal:@(1)];
    
    BUSTripHistory *tripFromStore = [trips firstObject];
    
    [[tripFromStore.directionDescription should] equal:mockTrip.destination];
    [[tripFromStore.routeName should] equal:mockTrip.route.shortName];
  });
  
});

SPEC_END