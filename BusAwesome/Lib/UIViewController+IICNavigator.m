//
//  UIViewController+Navigator.m
//  goblet-native
//
//  Created by Adam Farhi on 4/22/13.
//  Copyright (c) 2013 eBay IIC. All rights reserved.
//

#import "UIViewController+IICNavigator.h"

@implementation UIViewController (IICNavigator)

- (void)navigateToStoryboard:(NSString *)storyboard {
    [self navigateToStoryboard:storyboard withBootstrapBlock:nil];
}


- (void)navigateToStoryboard:(NSString *)storyboard withBootstrapBlock:(BootstrapHandler)bootstrapBlock{
    [self navigateToStoryboard:storyboard animated:YES bootstrapBlock:bootstrapBlock];
}

- (void)navigateToStoryboard:(NSString *)storyboard animated:(BOOL)animated bootstrapBlock:(BootstrapHandler)bootstrapBlock {
    UIViewController *vc = [self viewFrom:storyboard];
    
    if (bootstrapBlock) {
        bootstrapBlock(vc);
    }
    
    [self.navigationController pushViewController:vc animated:animated];
}

- (UIViewController *)viewFrom:(NSString *)storyboard {
    return [[UIStoryboard storyboardWithName:storyboard bundle:nil] instantiateInitialViewController];
}

@end
