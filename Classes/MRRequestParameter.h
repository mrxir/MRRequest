//
//  MRRequestParameter.h
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 枚举 网络请求范围

/**
 网络请求范围

 - MRRequestParameterRequestScopeNormal: 普通请求
 - MRRequestParameterRequestScopeRequestAccessToken: 获取 access token 请求
 - MRRequestParameterRequestScopeRefreshAccessToken: 刷新 access token 请求
 */
typedef NS_ENUM(NSUInteger, MRRequestParameterRequestScope) {
    MRRequestParameterRequestScopeNormal,
    MRRequestParameterRequestScopeRequestAccessToken,
    MRRequestParameterRequestScopeRefreshAccessToken,
};



#pragma mark - 枚举 网络请求方式

/**
 网络请求方式

 - MRRequestParameterRequestMethodGet: GET 请求
 - MRRequestParameterRequestMethodPost: POST 请求
 */
typedef NS_ENUM(NSUInteger, MRRequestParameterRequestMethod) {
    MRRequestParameterRequestMethodGet,
    MRRequestParameterRequestMethodPost,
};



#pragma mark - 枚举 参数格式化样式

/**
 参数格式化样式

 - MRRequestParameterFormattedStyleJSON: 标准的JSON样式, 像 {"key1":"value1","key2":"value2"}
 - MRRequestParameterFormattedStyleForm: 常用的Form表单样式, 像 {key1=value1&key2=value2}
 */
typedef NS_ENUM(NSUInteger, MRRequestParameterFormattedStyle) {
    MRRequestParameterFormattedStyleJSON,
    MRRequestParameterFormattedStyleForm,
};

@interface MRRequestParameter : NSObject

/**
 请求范围
 */
@property (nonatomic) MRRequestParameterRequestScope requestScope;

/**
 请求方法
 */
@property (nonatomic) MRRequestParameterRequestMethod requestMethod;

/**
 格式化样式
 */
@property (nonatomic) MRRequestParameterFormattedStyle formattedStyle;

/**
 result 编码方式
 @Instructions: 如果 NSStringEncoding 不设置或设置为 0, POST 请求时 NSData 采用 NSUTF8StringEncoding 方式编码, GET 请求不对字符串进行编码操作, 
                否则统一使用 resultEncoding 作为 POST 和 GET 请求时的编码参数.
 *
 */
@property (nonatomic) NSStringEncoding resultEncoding;

/**
 source 前缀
 
 @Instructions: 如果设置了前缀为 "loginPar=", 则会插入到 source 之前并影响最终的 result, 但不会影响 source, 例如 loginPar={"key1":"value1","key2":"value2"}
 *
 */
@property (nonatomic, copy) NSString *sourcePrefix;

/**
 initWith 方法初始化时使用的构造源对象
 */
@property (nonatomic, strong, readonly) id source;

/**
 根据 requestMethod, formattedStyle, 以及其他附加参数将 source 构造成想要的结果
 
 @Instructions: 如果 requestMethod 为 MRRequestParameterRequestMethodGet, 则 result 将是 NSString 类型,
                如果 requestMethod 为 MRRequestParameterRequestMethodPost, 则 result 将是 NSData 类型.
 *
 */
@property (nonatomic, strong, readonly) id result;



#pragma mark - life cycle

- (instancetype)initWithObject:(id)obj;

- (void)dealloc;

#pragma mark - rewrite setter

- (void)setRequestMethod:(MRRequestParameterRequestMethod)requestMethod;

- (void)setFormattedStyle:(MRRequestParameterFormattedStyle)formattedStyle;

#pragma mark - rewrite getter

- (NSString *)description;

@end
