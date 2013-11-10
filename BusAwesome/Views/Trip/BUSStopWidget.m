//
//  BUSStopWidget.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <HexColor.h>

#import "BUSStopWidget.h"

@implementation BUSStopWidget

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.opaque = NO;
  }
  return self;
}

- (void)setHighlightMode:(StopHighlightMode)highlightMode
{
  _highlightMode = highlightMode;
  [self setNeedsDisplay];
}

#define HIGHLIGHT_COLOR 0.0,0.615686275,0.862745098
#define VISITED_COLOR 0.8,0.8,0.8


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  float radius = rect.size.height * 0.25f;
  CGPoint center = CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f);
  UIColor *highlightColor = [UIColor colorWithHexString:@"009ddc" alpha:1.0];
  UIColor *visitedColor = [UIColor colorWithHexString:@"ccc" alpha:1.0];

  // Top Line
  if (self.terminusType != StopTerminusTypeStart) {
    if (self.highlightMode == StopHighlightModeStopAndTop) {
      [highlightColor setStroke];
    }
    else if (self.highlightMode == StopHighlightModeVisited ||
             self.highlightMode == StopHighlightModeStopAndBottom ||
             self.highlightMode == StopHighlightModeStop){
      [visitedColor setStroke];
    }
    else {
      [[UIColor blackColor] setStroke];
    }
    CGContextSetLineWidth(ctx, 6);
    CGContextMoveToPoint(ctx, center.x, center.y - radius);giu
    CGContextAddLineToPoint(ctx, center.x, 0.0);
    CGContextStrokePath(ctx);
  }
  
  // Bottom Line
  if (self.terminusType != StopTerminusTypeEnd) {
    if (self.highlightMode == StopHighlightModeStopAndBottom) {
      [highlightColor setStroke];
    }
    else if (self.highlightMode == StopHighlightModeVisited){
      [visitedColor setStroke];
    }
    else {
      [[UIColor blackColor] setStroke];
    }
    CGContextSetLineWidth(ctx, 6);
    CGContextMoveToPoint(ctx, center.x, center.y + radius);
    CGContextAddLineToPoint(ctx, center.x, rect.size.height);
    CGContextStrokePath(ctx);
  }
  
  // Inner circle
  if (self.highlightMode == StopHighlightModeStopAndBottom ||
      self.highlightMode == StopHighlightModeStopAndTop ||
      self.highlightMode == StopHighlightModeStop) {
    [highlightColor setStroke];
  }
  else if (self.highlightMode == StopHighlightModeVisited){
    [visitedColor setStroke];
  }
  else {
    [[UIColor blackColor] setStroke];
  }
  CGContextSetLineWidth(ctx,4);
  
  CGContextAddArc(ctx,center.x,center.y,radius,0.0,M_PI*2,YES);
  CGContextStrokePath(ctx);
  
  
}

@end
