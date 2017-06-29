//
//  UIStoryboard+Extension.h
//  MRFramework
//
//  Created by MrXir on 2017/6/27.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (Extension)

@end



#pragma mark - controller manager extension

#import <objc/runtime.h>

/**
 controller manager extension
 */
@interface UIStoryboard (ControllerManager)

@property (nonatomic, strong, readonly) NSArray<__kindof NSString *> *controllerIdentifierList;

/**
 After application launch, set all storyboard names you can find in this project.

 @param names the names of storyboard file, don't need contains Extend of suffix.
 */
+ (void)setStoryboardNames:(NSArray<__kindof NSString *> *)names;

@end



#pragma mark - controller identifier matcher extension

/**
 controller identifier matcher extension
 */
@interface UIStoryboard (IdentifierMatcher)

+ (__kindof UIViewController *)matchControllerForIdentifier:(NSString *)identifier;

@end



#pragma mark - controller class name matcher extension

/**
 controller class name matcher extension
 */
@interface UIViewController (ClassNameMatcher)

+ (__kindof UIViewController *)matchControllerForMyself;

@end
