//
//  BUSTripSectionHeader.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 2/18/14.
//  Copyright (c) 2014 Gilad Goldberg. All rights reserved.
//

#import "BUSTripSectionHeader.h"

@interface BUSTripSectionHeader()
@property (weak, nonatomic) IBOutlet UILabel *cityName;
@end

@implementation BUSTripSectionHeader

+ (CAGradientLayer*) blueGradient {
  
  UIColor *colorOne = [UIColor colorWithRed:(70/255.0) green:(180/255.0) blue:(255/255.0) alpha:1.0];
  UIColor *colorTwo = [UIColor whiteColor];
  
  NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
  NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
  NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
  
  NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
  
  CAGradientLayer *headerLayer = [CAGradientLayer layer];
  headerLayer.colors = colors;
  headerLayer.locations = locations;
  
  return headerLayer;
  
}

- (id) initWithCityName:(NSString *)cityName
{
  if (self = [super initWithFrame:CGRectMake(0, 0, 320, 21)]) {
    
    self.cityName.text = cityName;
    //[self.layer insertSublayer:[BUSTripSectionHeader blueGradient] atIndex:0];
    
    return self;
  } else {
    return nil;
  }
}

- (NSString *)xibName
{
  return @"TripSectionHeader";
}
@end
