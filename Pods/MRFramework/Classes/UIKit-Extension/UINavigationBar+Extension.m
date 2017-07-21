//
//  UINavigationBar+Extension.m
//  MRFramework
//
//  Created by MrXir on 2017/7/12.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "UINavigationBar+Extension.h"

#import "UIImage+Extension.h"

@implementation UINavigationBar (Extension)

@end



@implementation UINavigationBar (BackgruondAndShadowExtension)

- (void)setBackgroundAndShadowColor:(UIColor *)color
{
    UIImage *image = nil;
    
    if (color == nil) {
        image = nil;
    } else if ([color isEqual:[UIColor clearColor]]) {
        image = [UIImage new];
    } else {
        image = [UIImage imageWithColor:color];
    }
    
    [self setBackgroundImage:image
              forBarPosition:UIBarPositionAny
                  barMetrics:UIBarMetricsDefault];
    
    [self setShadowImage:image];

}

@end
