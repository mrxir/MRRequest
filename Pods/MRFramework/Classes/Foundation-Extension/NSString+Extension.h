//
//  NSString+Extension.h
//  MRFramework
//
//  Created by MrXir on 2017/6/27.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

@end



#pragma mark - verify extension

/**
 verify extension
 */
@interface NSString (Verify)

/**
 返回这个对象是否是一个有效的字符串, 如果字符串等于 "null" 或 "(null)" 或 "<null>" 则判定为无效字符串.
 
 @return BOOL
 */
+ (BOOL)isValidString:(id)obj;

@end



#pragma mark - cipher extension

// dependent file <CommonCrypto/CommonDigest.h>

/**
 cipher extension
 */
@interface NSString (Cipher)

#pragma mark - cipher - MD5

/**
 返回该字符串的MD5Hash值
 
 @return NSString
 */
- (NSString *)md5Hash;

/**
 返回该文件的MD5Hash值
 
 @param filePath 文件路径
 @return NSString
 */
+ (NSString *)md5HashWithFile:(NSString *)filePath;

@end



#pragma mark - drawing extension

#import <UIKit/NSStringDrawing.h>
#import <UIKit/NSParagraphStyle.h>
#import <UIKit/UIFont.h>

/**
 drawing extension
 */
@interface NSString (Drawing)

typedef NS_ENUM(NSUInteger, CalculateOption) {
    CalculateOptionWidth,
    CalculateOptionHeight,
};

/**
 返回字符串的边界
 
 @param font 当前字符串使用的字体
 @param frame 当前字符串的显示范围
 @param option 计算宽度或者高度选项
 @return CGRect
 */
- (CGRect)boundingRectWithFont:(UIFont *)font frame:(CGRect)frame CalculateOption:(CalculateOption)option;

@end
