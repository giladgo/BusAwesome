//
//  BUSStopCell.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSStopCell.h"
#import "BUSStopWidget.h"
#import <HexColor.h>

@interface BUSStopCell()
@property (weak, nonatomic) IBOutlet BUSStopWidget *stopWidget;
@property (weak, nonatomic) IBOutlet UILabel *stopNameLabel;

@end

@implementation BUSStopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStopName:(NSString *)stopName
{
  _stopName = stopName;
  self.stopNameLabel.text = stopName;
}

- (void)setHighlightMode:(StopHighlightMode)highlightMode
{
  _highlightMode = highlightMode;
  self.stopWidget.highlightMode = highlightMode;
  
  if (_highlightMode != StopHighlightModeNone) {
    self.backgroundColor = [UIColor colorWithHexString:@"ddeeff" alpha:1.0];
  }
  else {
    self.backgroundColor = [UIColor whiteColor];
  }
}

- (void)setTerminusType:(StopTerminusType)terminusType
{
  _terminusType = terminusType;
  self.stopWidget.terminusType = terminusType;
}

@end
