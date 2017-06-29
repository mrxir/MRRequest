//
//  MRRequest.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "MRRequest.h"

#import "MRRequestParameter.h"

@implementation MRRequest

@end



#pragma mark - default config

#import "MRRequestManager.h"

@implementation MRRequest (DefaultConfig)

+ (void)setOAuthEnabled:(BOOL)enabled
{
    [MRRequestManager defaultManager].oauthEnabled = enabled;
}

+ (BOOL)getOAuthEnabled
{
    return [MRRequestManager defaultManager].isOAuthEnabled;
}

@end
