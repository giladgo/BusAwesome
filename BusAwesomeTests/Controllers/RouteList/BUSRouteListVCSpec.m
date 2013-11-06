//
//  BUSRouteListViewControllerSpec.m
//  BusAwesome
//
//  Created by Itay Adler on 05/11/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "Kiwi.h"
#import "BUSRouteListVC.h"

SPEC_BEGIN(BUSRouteListVCSpec)

describe(@"BUSRouteListVC", ^{
  
  __block BUSRouteListVC *subject = nil;
  
  beforeEach(^{
    subject = [[UIStoryboard storyboardWithName:@"RouteList" bundle:nil] instantiateInitialViewController];
    UIView *aView = subject.view;
    aView = nil;
  });
  
  afterEach(^{
    subject = nil;
  });
  
  describe(@"TableViewDelegate Methods", ^{
    
    describe(@"heightForRowAtIndexPath", ^{
      it(@"should return CELL_ROW_HEIGHT", ^{
        [subject stub:NSSelectorFromString(@"hasLines") andReturn:@YES];
        CGFloat result = [subject tableView:nil heightForRowAtIndexPath:nil];
        [[theValue(result) should] equal:theValue(CELL_ROW_HEIGHT)];
      });
      
      it(@"should return tableView height", ^{
        [subject stub:NSSelectorFromString(@"tableViewHeight") andReturn:@480];
        CGFloat result = [subject tableView:nil heightForRowAtIndexPath:nil];
        [[theValue(result) should] equal:theValue(480)];
      });
    });
    
    describe(@"heightForHeaderInSection", ^{
      it(@"should return 0 when there are no lines", ^{
        CGFloat result = [subject tableView:nil heightForHeaderInSection:0];
        [[theValue(result) should] equal:theValue(0)];
      });
      
      it(@"should return SECTION_HEADER_HEIGHT when there are lines", ^{
        [subject stub:NSSelectorFromString(@"hasLines") andReturn:@YES];
        CGFloat result = [subject tableView:nil heightForHeaderInSection:0];
        [[theValue(result) should] equal:theValue(SECTION_HEADER_HEIGHT)];
      });
    });
    
  });
  
});

SPEC_END