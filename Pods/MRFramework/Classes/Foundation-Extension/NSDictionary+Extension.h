//
//  NSDictionary+Extension.h
//  MRFramework
//
//  Created by MrXir on 2017/6/28.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extension)

@end



#pragma mark - dictionary formatter extension

/**
 dictionary formatter extension
 */
@interface NSDictionary (Formatter)

/**
 格式化为表单样式的字符串
 */
@property (nonatomic, copy, readonly) NSString *formattedIntoFormStyleString;

@end
