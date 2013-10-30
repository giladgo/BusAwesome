//
//  BUSViewController.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/29/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSTopViewController.h"

#import "UIViewController+IICNavigator.h"

@interface BUSTopViewController ()
@property (nonatomic, getter = didAppearOnceAlready) BOOL appearedOnceAlready;
@end

@implementation BUSTopViewController

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!self.didAppearOnceAlready) {
    [self goToLineList];
    
    self.appearedOnceAlready = YES;
  }
}

- (UIViewController*)navigateTo:(NSString*)storyboardName {
  [self dismissViewControllerAnimated:NO completion:nil];
  UIViewController *vc = [self viewFrom:storyboardName];
 
  [self pushViewController:vc animated:NO];
  return vc;
}

- (void) goToLineList
{
  [self navigateTo:@"Trip"];
}

@end
