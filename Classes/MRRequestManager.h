//
//  MRRequestManager.h
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRRequestManager : NSObject

@property (nonatomic, strong, readonly) NSMutableSet *processingRequestIdentifierSet;

@property (nonatomic, assign, getter = isOAuthEnabled) BOOL oAuthEnabled;

+ (instancetype)defaultManager;

@end
