//
//  BUSRouteListSectionHeader.h
//  BusAwesome
//
//  Created by Itay Adler on 04/11/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXibView.h"

@interface BUSRouteListSectionHeader : UIXibView
-(id)initWithLineNumber:(NSString *)lineNumber withAgencyName:(NSString *)agencyName withBackgroundColor:(UIColor *)bgColor;
@end
