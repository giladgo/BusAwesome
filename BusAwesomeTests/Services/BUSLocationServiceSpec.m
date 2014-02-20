//
//  BUSLocationServiceSpec.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 11/6/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "Kiwi.h"
#import "BUSLocationService.h"

SPEC_BEGIN(BUSLocationServiceSpec)


describe(@"BusLocationService", ^{
  
  __block BUSLocationService *subject = nil;
  __block id locationDelegateMock = [KWMock mockForProtocol:@protocol(BUSLocationServiceDelegate)];
  subject.delegate = locationDelegateMock;
  
  beforeEach(^{
    subject = [BUSLocationService new];
  });
  
  afterEach(^{
    [subject stopUpdatingLocation];
    subject = nil;
  });
  
  
  describe(@"getCurrentLocation", ^{
    it(@"should get the current location within a timely manner", ^{
      __block CLLocation *_location;
      [subject getCurrentLocation:^(CLLocation *location) {
        _location = location;
      } withAccuracy:10.0 withTimeout:3.5];
      [[expectFutureValue(theValue(_location)) shouldEventuallyBeforeTimingOutAfter(3.5)] beNonNil];
    });
    
    it(@"should get the current location within a timely manner, even if not accurate enough", ^{
      __block CLLocation *_location;
      [subject getCurrentLocation:^(CLLocation *location) {
        _location = location;
      } withAccuracy:0.1 withTimeout:3.5];
      [[expectFutureValue(theValue(_location)) shouldEventuallyBeforeTimingOutAfter(3.0)] beNonNil];
    });
    
  });
  
  
});

SPEC_END
