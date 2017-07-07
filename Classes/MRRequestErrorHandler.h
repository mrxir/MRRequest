//
//  MRRequestErrorHandler.h
//  MRRequest
//
//  Created by MrXir on 2017/7/7.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 MRRequest 错误码
 
 - MRRequestErrorCodeEqualRequestError:                 重复请求
 
 - MRRequestErrorCodeOAuthRequestError:                 OAuth授权获取时发生错误
 - MRRequestErrorCodeOAuthRenewalError:                 OAuth授权续约时发生错误
 
 - MRRequestErrorCodeOAuthCommonRequestLightlyError:    OAuth普通请求时发生轻微错误
 - MRRequestErrorCodeOAuthCommonRequestHeavilyError:    OAuth普通请求时发生严重错误
 
 - MRRequestErrorCodeDynamicError:                      除上述错误外其他可能出现的动态错误码, 这个错误码不会被本框架返回, 它用来对错误处理block进行通配设置.
 
 */
typedef NS_ENUM(NSUInteger, MRRequestErrorCode) {
    
    MRRequestErrorCodeEqualRequestError                 = 7782222,
    
    MRRequestErrorCodeOAuthRequestError                 = 7782400,
    MRRequestErrorCodeOAuthRenewalError                 = 7782401,
    
    MRRequestErrorCodeOAuthCommonRequestLightlyError    = 7782500,
    MRRequestErrorCodeOAuthCommonRequestHeavilyError    = 7782501,
    
    MRRequestErrorCodeDynamicError                      = 9999999,
    
};

@interface MRRequestErrorHandler : NSObject

+ (instancetype)defaultManager;

/**
 设置MRRequest错误码处理block
 */
- (void)setHandleBlock:(dispatch_block_t)block forErrorCode:(MRRequestErrorCode)code;
- (dispatch_block_t)handleBlockForErrorCode:(MRRequestErrorCode)code;

/**
 当前被MRRequest抛出的错误
 */
- (NSError *)currentError;

/**
 处理MRRequest错误
 */
- (void)handleError:(NSError *)error;

@end
