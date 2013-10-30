//
//  BUSStopWidget.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum StopHighlightMode : NSUInteger {
  StopHighlightModeNone,
  StopHighlightModeStop,
  StopHighlightModeStopAndTop,
  StopHighlightModeStopAndBottom
} StopHighlightMode;

@interface BUSStopWidget : UIView

@property StopHighlightMode highlightMode;

@end
