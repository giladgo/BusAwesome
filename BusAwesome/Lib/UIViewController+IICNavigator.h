//
//  UIViewController+Navigator.h
//  goblet-native
//
//  Created by Adam Farhi on 4/22/13.
//  Copyright (c) 2013 eBay IIC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (IICNavigator)

typedef void(^BootstrapHandler)(id);

- (void)navigateToStoryboard:(NSString *)storyboard;

- (void)navigateToStoryboard:(NSString *)storyboard withBootstrapBlock:(BootstrapHandler)bootstrapBlock;

- (void)navigateToStoryboard:(NSString *)storyboard animated:(BOOL)animated bootstrapBlock:(BootstrapHandler)bootstrapBlock;

- (UIViewController *)viewFrom:(NSString *)storyboard;

@end
