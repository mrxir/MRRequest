//
//  NSJSONSerialization+Extension.h
//  MRFramework
//
//  Created by MrXir on 2017/6/27.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (Extension)

@end



#pragma mark - string serialization extension

/**
 string serialization extension
 */
@interface NSJSONSerialization (String)

/**
 Generate JSON data from a Foundation object, then encoding with NSUTF8StringEncoding to NSString. If the object will not produce valid JSON then an exception will be thrown. Setting the NSJSONWritingPrettyPrinted option will generate JSON with whitespace designed to make the output more readable. If that option is not set, the most compact possible JSON will be generated. If an error occurs, the error parameter will be set and the return value will be nil. The resulting data is a encoded in UTF-8.

 @param obj 想要序列化的对象
 @param opt 序列化参数
 @param error 序列化为 NSdata 时的错误
 @return NSString
 */
+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;

@end
