//
//  UIApplication+Extension.h
//  MRFramework
//
//  Created by MrXir on 2017/7/8.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Extension)

@end



@interface UIApplication (ControllerExtension)

- (UIWindow *)rootWindow;

- (__kindof UIViewController *)rootWindowViewController;

- (__kindof UIViewController *)rootWindowTopViewController;

- (__kindof UIViewController *)keyWindowViewController;

- (__kindof UIViewController *)keyWindowTopViewController;

@end
