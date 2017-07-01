//
//  MRRequest.h
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MRRequestManager.h"
#import "MRRequestParameter.h"
#import "MRRequestDelegate.h"

FOUNDATION_EXPORT NSErrorDomain const MRRequestErrorDomain;

/**
 MRRequest 错误码
 
 - MRRequestErrorCodeGlobalInvalidJSONSerializationFormat:      通用错误码, 不可用的JSON序列化格式
 - MRRequestErrorCodeGlobalInProcessingSameRequest:             通用错误码, 正在处理相同请求
 - MRRequestErrorCodeOAuthOrdinaryBusinessTolerableFailed:      OAuth错误码, 可容忍的普通业务失败, 不需要重新登录
 - MRRequestErrorCodeOAuthOrdinaryBusinessIntolerableFailed:    OAuth错误码, 不可容忍的普通业务失败, 需要重新登录
 - MRRequestErrorCodeOAuthRequestAccessTokenFailed:             OAuth错误码, 获取 access token 失败
 - MRRequestErrorCodeOAuthRefreshAccessTokenFailed:             OAuth错误码, 刷新 access token 失败
 */
typedef NS_ENUM(NSUInteger, MRRequestErrorCode) {
    
    MRRequestErrorCodeGlobalInvalidJSONSerializationFormat      = 7782000,
    MRRequestErrorCodeGlobalInProcessingSameRequest             = 7782001,
    
    MRRequestErrorCodeOAuthOrdinaryBusinessTolerableFailed      = 7782002,
    MRRequestErrorCodeOAuthOrdinaryBusinessIntolerableFailed    = 7782003,
    MRRequestErrorCodeOAuthRequestAccessTokenFailed             = 7782004,
    MRRequestErrorCodeOAuthRefreshAccessTokenFailed             = 7782005,
    
};

typedef void(^Progress)(MRRequest *request, CGFloat progress);
typedef void(^Success)(MRRequest *request, id receiveObject);
typedef void(^Failure)(MRRequest *request, id requestObject, NSData *data, NSError *error);

@interface MRRequest : NSMutableURLRequest

@property (nonatomic, copy) Progress progress;
@property (nonatomic, copy) Success success;
@property (nonatomic, copy) Failure failure;

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, strong, readonly) MRRequestParameter *parameter;
@property (nonatomic, weak, readonly) id <MRRequestDelegate> delegate;

#pragma mark - life cycle

- (instancetype)initWithPath:(NSString *)path parameter:(MRRequestParameter *)parameter delegate:(id <MRRequestDelegate>)delegate;

+ (void)requestWithPath:(NSString *)path
              parameter:(MRRequestParameter *)parameter
                success:(Success)success
                failure:(Failure)failure;

+ (void)requestWithPath:(NSString *)path
              parameter:(MRRequestParameter *)parameter
               progress:(Progress)progress
                success:(Success)success
                failure:(Failure)failure;

/**
 执行
 */
- (void)execute;

/**
 退出
 */
- (void)exit;

@end



#pragma mark - default config

@interface MRRequest (DefaultConfig)

+ (void)setOAuthEnabled:(BOOL)enabled;
+ (BOOL)oAuthEnabled;

@end
