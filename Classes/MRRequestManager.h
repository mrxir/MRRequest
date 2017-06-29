//
//  MRRequestManager.h
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRRequestParameter;

@interface MRRequestManager : NSObject

@property (nonatomic, strong, readonly) MRRequestParameter *previousRequestParameter;

@property (nonatomic, strong, readonly) MRRequestParameter *currentRequestParameter;

@property (nonatomic, assign, getter = isOAuthEnabled) BOOL oauthEnabled;

+ (instancetype)defaultManager;

@end
