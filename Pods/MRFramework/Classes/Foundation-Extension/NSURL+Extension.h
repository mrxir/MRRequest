//
//  NSURL+Extension.h
//  MRFramework
//
//  Created by MrXir on 2017/8/3.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Extension)

+ (instancetype)URLWithString:(NSString *)URLString autoAddingPercentEscapesUsingEncoding:(NSStringEncoding)stringEncoding;

@end
