//
//  BUSStopWidget.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSStopWidget.h"

@implementation BUSStopWidget

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setHighlightMode:(StopHighlightMode)highlightMode
{
  _highlightMode = highlightMode;
  [self setNeedsDisplay];
}

#define HIGHLIGHT_COLOR 0.0,0.615686275,0.862745098


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  

  float radius = rect.size.height * 0.25f;
  CGPoint center = CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f);
  

  // Top Line
  if (self.highlightMode == StopHighlightModeStopAndTop) {
    CGContextSetRGBStrokeColor(ctx,HIGHLIGHT_COLOR,1.0);
  }
  else {
    CGContextSetRGBStrokeColor(ctx,0.0,0.0,0.0,1.0);
  }
  CGContextSetLineWidth(ctx, 6);
  CGContextMoveToPoint(ctx, center.x, center.y - radius);
  CGContextAddLineToPoint(ctx, center.x, 0.0);
  CGContextStrokePath(ctx);
  
  // Bottom Line
  if (self.highlightMode == StopHighlightModeStopAndBottom) {
    CGContextSetRGBStrokeColor(ctx,HIGHLIGHT_COLOR,1.0);
  }
  else {
    CGContextSetRGBStrokeColor(ctx,0.0,0.0,0.0,1.0);
  }
  CGContextSetLineWidth(ctx, 6);
  CGContextMoveToPoint(ctx, center.x, center.y + radius);
  CGContextAddLineToPoint(ctx, center.x, rect.size.height);
  CGContextStrokePath(ctx);
  
  // Inner circle
  if (self.highlightMode != StopHighlightModeNone) {
    CGContextSetRGBStrokeColor(ctx,HIGHLIGHT_COLOR,1.0);
  }
  else {
    CGContextSetRGBStrokeColor(ctx,0.0,0.0,0.0,1.0);
  }
  CGContextSetLineWidth(ctx,4);
  
  CGContextAddArc(ctx,center.x,center.y,radius,0.0,M_PI*2,YES);
  CGContextStrokePath(ctx);
  
}

@end
