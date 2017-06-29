//
//  MRRequest.h
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRRequestParameter;

@interface MRRequest : NSMutableURLRequest


@end



#pragma mark - default config

@class MRRequestManager;

@interface MRRequest (DefaultConfig)

+ (void)setOAuthEnabled:(BOOL)enabled;
+ (BOOL)getOAuthEnabled;

@end
