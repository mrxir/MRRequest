//
//  UIApplication+Extension.m
//  MRFramework
//
//  Created by MrXir on 2017/7/8.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "UIApplication+Extension.h"

@implementation UIApplication (Extension)

@end



@implementation UIApplication (ControllerExtension)

- (UIWindow *)rootWindow
{
    return self.delegate.window;
}

- (UIViewController *)rootWindowViewController
{
    return self.rootWindow.rootViewController;
}

- (UIViewController *)rootWindowTopViewController
{
    UIViewController *rootWindowTopViewController = nil;
    
    rootWindowTopViewController = [self displayingViewControllerWithPresentedViewController:self.rootWindowViewController];
    
    while (rootWindowTopViewController.presentedViewController != nil) {
        rootWindowTopViewController = [self displayingViewControllerWithPresentedViewController:rootWindowTopViewController.presentedViewController];
    }
    
    return rootWindowTopViewController;
}

- (UIViewController *)keyWindowViewController
{
    return self.keyWindow.rootViewController;
}

- (UIViewController *)keyWindowTopViewController
{
    UIViewController *keyWindowTopViewController = nil;
    
    keyWindowTopViewController = [self displayingViewControllerWithPresentedViewController:self.rootWindowViewController];
    
    while (keyWindowTopViewController.presentedViewController != nil) {
        keyWindowTopViewController = [self displayingViewControllerWithPresentedViewController:keyWindowTopViewController.presentedViewController];
    }
    
    return keyWindowTopViewController;
}

- (UIViewController *)displayingViewControllerWithPresentedViewController:(UIViewController *)presentedViewController
{
    if ([presentedViewController isKindOfClass:[UITabBarController class]]) {
        return [self displayingViewControllerWithPresentedViewController:[(UITabBarController *)presentedViewController selectedViewController]];
    } else if ([presentedViewController isKindOfClass:[UINavigationController class]]) {
        return [self displayingViewControllerWithPresentedViewController:[(UINavigationController *)presentedViewController topViewController]];
    } else {
        return presentedViewController;
    }
}

@end
