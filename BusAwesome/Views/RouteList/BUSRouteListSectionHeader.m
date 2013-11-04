//
//  BUSRouteListSectionHeader.m
//  BusAwesome
//
//  Created by Itay Adler on 04/11/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSRouteListSectionHeader.h"

#define SECTION_HEADER_FRAME CGRectMake(0, 0, 320, 42)

@interface BUSRouteListSectionHeader ()
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet UILabel *agencyLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@end

@implementation BUSRouteListSectionHeader

- (id)initWithLineNumber:(NSString *)lineNumber withAgencyName:(NSString *)agencyName withBackgroundColor:(UIColor *)bgColor
{
  self = [super initWithFrame:SECTION_HEADER_FRAME];
  if (!self) return nil;
  
  self.lineLabel.text = lineNumber;
  self.agencyLabel.text = agencyName;
  self.containerView.backgroundColor = bgColor;
  
  return self;
}

- (NSString *)xibName
{
  // overridden.
  return @"RouteListSectionHeader";
}

@end
