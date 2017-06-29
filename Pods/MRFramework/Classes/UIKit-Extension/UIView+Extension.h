//
//  UIView+Extension.h
//  MRFramework
//
//  Created by MrXir on 2017/6/27.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

@end



#pragma mark - gesture handler extension

#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, GestureOption) {
    GestureOptionSingleTap = 1,
    GestureOptionDoubleTap = 2,
    GestureOptionTripleTap = 3,
    GestureOptionLongPress = 9,
};

typedef void(^ViewGestureHandler)(__kindof UIView *view);

/**
 gesture handler extension
 */
@interface UIView (GestureHandler)

/**
 为该视图添加手势并在触发时执行 ViewGestureHandler, 不推荐 control 类及子类调用该方法.
 
 @param option 手势选项
 @param completion 事件block
 */
- (void)handleWithGestureOption:(GestureOption)option completion:(ViewGestureHandler)completion;

@end
