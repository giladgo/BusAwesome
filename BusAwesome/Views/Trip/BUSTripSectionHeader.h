//
//  BUSTripSectionHeader.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 2/18/14.
//  Copyright (c) 2014 Gilad Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXibView.h"

#define TRIP_SECTION_HEADER_HEIGHT 21

@interface BUSTripSectionHeader : UIXibView

- (id) initWithCityName:(NSString *)cityName;

@end
