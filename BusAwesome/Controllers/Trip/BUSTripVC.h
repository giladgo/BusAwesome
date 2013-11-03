//
//  BUSTripVC.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 10/30/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BUSLocationService.h"

@interface BUSTripVC : UIViewController <UITableViewDataSource, UITableViewDelegate, BUSLocationServiceDelegate>

@property (strong, nonatomic) NSString *tripId;

@end
