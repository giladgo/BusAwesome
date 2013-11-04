//
//  UIXibView.m
//  BusAwesome
//
//  Created by Itay Adler on 04/11/2013.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import "UIXibView.h"

@implementation UIXibView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self bootstrap];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
  self = [super initWithCoder:decoder];
  if (self) {
    [self bootstrap];
  }
  return self;
}

- (void)bootstrap {
  UIView* view = [[NSBundle mainBundle] loadNibNamed:[self xibName] owner:self options:nil][0];
  [self addSubview:view];
  [self setup];
}

- (void)setup {
  // overridden.
}

- (NSString *)xibName {
  // overridden.
  return nil;
}
@end
