//
//  MRRequestManager.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "MRRequestManager.h"

@implementation MRRequestManager

+ (instancetype)defaultManager
{
    static MRRequestManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[MRRequestManager alloc] init];
    });
    return s_manager;
}

@end
