//
//  UIControl+Extension.h
//  MRFramework
//
//  Created by MrXir on 2017/6/27.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (Extension)

@end



#pragma mark - event handler extension

#import <objc/runtime.h>

typedef void(^ControlEventsHandler)(__kindof UIControl *control);

/**
 event handler extension
 */
@interface UIControl (EventsHandler)

/**
 添加事件并在触发时执行 ControlEventHandler
 
 @param events 事件类型
 @param completion 事件block
 */
- (void)handleWithEvents:(UIControlEvents)events completion:(ControlEventsHandler)completion;

@end
