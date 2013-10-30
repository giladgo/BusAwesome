//
//  BUSTripVC.m
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "BUSTripVC.h"
#import "BUSStopCell.h"

@interface BUSTripVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BUSTripVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"BusStop";
  id cell =[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  if ([cell isKindOfClass:[BUSStopCell class]]) {
    BUSStopCell *stopCell = cell;
    
    stopCell.stopName = @"moo";
    
    if (indexPath.row == 0) {
      stopCell.highlightMode = StopHighlightModeStopAndBottom;
    }

    else if (indexPath.row == 1) {
      stopCell.highlightMode = StopHighlightModeStopAndTop;
    }
    
    return stopCell;
  }
  
  return nil;
}

@end
