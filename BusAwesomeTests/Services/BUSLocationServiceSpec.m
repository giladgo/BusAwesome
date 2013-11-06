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
      } withAccuracy:10.0];
      [[expectFutureValue(theValue(_location)) shouldEventuallyBeforeTimingOutAfter(3.5)] beNonNil];
    });
    
    it(@"should get the current location within a timely manner, even if not accurate enough", ^{
      __block CLLocation *_location;
      [subject getCurrentLocation:^(CLLocation *location) {
        _location = location;
      } withAccuracy:0.1];
      [[expectFutureValue(theValue(_location)) shouldEventuallyBeforeTimingOutAfter(3.0)] beNonNil];
    });
    
  });

  describe(@"startUpdatingLocation", ^{
    
    __block NSArray *_locations;
    
    it(@"should get some locations and stop when asked", ^{
      
      id locationDelegateMock = [KWMock mockForProtocol:@protocol(BUSLocationServiceDelegate)];
      [locationDelegateMock stub:NSSelectorFromString(@"didUpdateLocations:") withBlock:^id(NSArray *params) {
        _locations = (NSArray*)params[0];
        return nil;
      }];
      
      [subject startUpdatingLocation];
      
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
      
      [[locationDelegateMock shouldEventuallyBeforeTimingOutAfter(3.0)] receive:NSSelectorFromString(@"didUpdateLocations:")];
      [[expectFutureValue(_locations) shouldEventually] beNonNil];
      [[expectFutureValue(@(_locations.count)) shouldEventually] beGreaterThanOrEqualTo:@2];
      
      [subject stopUpdatingLocation];
    });
    
    it (@"should stop getting locations on request", ^{
      __block BOOL fail = NO;

      [locationDelegateMock stub:NSSelectorFromString(@"didUpdateLocations:") withBlock:^id(NSArray *params) {
        fail = YES;
        return nil;
      }];
      
      [subject startUpdatingLocation];

      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
      
      fail = NO;
      [subject stopUpdatingLocation];


      [[theValue(fail) shouldNot] beTrue];
      

    });
    

  });
  
  
});

SPEC_END
