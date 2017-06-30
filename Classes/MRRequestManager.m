//
//  MRRequestManager.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "MRRequestManager.h"

@implementation MRRequestManager

@synthesize processingRequestIdentifierSet = _processingRequestIdentifierSet;

+ (instancetype)defaultManager
{
    static MRRequestManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[MRRequestManager alloc] init];
    });
    return s_manager;
}

- (NSMutableSet *)processingRequestIdentifierSet
{
    if (!_processingRequestIdentifierSet) {
        _processingRequestIdentifierSet = [NSMutableSet set];
    }
    return _processingRequestIdentifierSet;
}

@end
