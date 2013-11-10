//
//  BUSStopWidget.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>

// An enum which defined how each stop in the list can be highlighted or dimmed (if visited)
typedef enum StopHighlightMode : NSUInteger {
  // Nothing special
  StopHighlightModeNone,
  // Highlight just the stop's circle
  StopHighlightModeStop,
  // Highlight the stop's circle and the line leading to it from the top
  StopHighlightModeStopAndTop,
  // Highlight the stop's circle and the line leading to it from the bottom
  StopHighlightModeStopAndBottom,
  // Don't highlight; instead, dim it to make it appear visited
  StopHighlightModeVisited
} StopHighlightMode;

typedef enum StopTerminusType : NSUInteger {
  StopTerminusTypeNone,
  StopTerminusTypeStart,
  StopTerminusTypeEnd
} StopTerminusType;
@interface BUSStopWidget : UIView

@property (nonatomic) StopHighlightMode highlightMode;
@property (nonatomic) StopTerminusType terminusType;

@end
