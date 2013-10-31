//
//  BUSRouteListVCViewController.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/29/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BUSRouteListVC : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
