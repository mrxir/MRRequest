//
//  NSObject+Extension.h
//  MRFramework
//
//  Created by MrXir on 2017/6/27.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extension)

@end



#pragma mark - property extension

#import <objc/runtime.h>

/**
 property extension
 */
@interface NSObject (Property)

@property (nonatomic, strong) NSIndexPath *objectIndexPath;

- (NSIndexPath *)objectIndexPath;

- (void)setObjectIndexPath:(NSIndexPath *)objectIndexPath;

@end



#pragma mark - object to dictionary converter

/**
 object to dictionary converter
 */
@interface NSObject (ModelConverter)

/**
 返回该对象的属性和值的字典
 
 @return NSDictionary
 */

+ (NSDictionary *)propertyWithObject:(__kindof NSObject *)object;

@end



#pragma mark - desctiption extension

/**
 desctiption extension
 */
@interface NSObject (Description)

/**
 当UTF8编码字符被放入容器中,可以使用该方法将容器的 description 能够查看编码之前的原文,例如中文和表情符号.
 
 @return NSString
 */
- (NSString *)stringWithUTF8;

@end
