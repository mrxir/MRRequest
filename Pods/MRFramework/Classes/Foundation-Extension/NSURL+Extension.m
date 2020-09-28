//
//  NSURL+Extension.m
//  MRFramework
//
//  Created by MrXir on 2017/8/3.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "NSURL+Extension.h"

#import <UIKit/UIApplication.h>

@implementation NSURL (Extension)

+ (instancetype)URLWithString:(NSString *)URLString autoAddingPercentEscapesUsingEncoding:(NSStringEncoding)stringEncoding
{
    NSURL *url = [NSURL URLWithString:URLString];
    
    // 如果 URL 无效, 尝试将 URLString 进行编码
    if ([[UIApplication sharedApplication] canOpenURL:url] == NO) {
        
        stringEncoding = (stringEncoding == 0 ? NSUTF8StringEncoding : stringEncoding);
        
        NSString *encodedURLString = [URLString stringByAddingPercentEscapesUsingEncoding:stringEncoding];
        
        url = [NSURL URLWithString:encodedURLString];
        
    }
    
    return url;
}

@end
