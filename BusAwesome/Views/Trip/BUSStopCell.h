//
//  BUSStopCell.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BUSStopWidget.h"

@interface BUSStopCell : UITableViewCell

@property (nonatomic, strong) NSString *stopName;
@property (nonatomic) NSInteger minutesAway;
@property (nonatomic) StopHighlightMode highlightMode;

@end
