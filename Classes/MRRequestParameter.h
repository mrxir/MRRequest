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
 OAuth 请求范围

 - MRRequestParameterOAuthRequestScopeOrdinaryBusiness: 普通业务
 - MRRequestParameterOAuthRequestScopeRequestAccessToken: 获取 token
 - MRRequestParameterOAuthRequestScopeRefreshAccessToken: 刷新 token
 */
typedef NS_ENUM(NSUInteger, MRRequestParameterOAuthRequestScope) {
    MRRequestParameterOAuthRequestScopeOrdinaryBusiness,
    MRRequestParameterOAuthRequestScopeRequestAccessToken,
    MRRequestParameterOAuthRequestScopeRefreshAccessToken,
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
 本次请求是否开启 OAuth, 默认为不开启
 */
@property (nonatomic, assign, getter = isOAuthIndependentSwitchState) BOOL oAuthIndependentSwitchState;

/**
 OAuth 独立开关是否已被设置过
 */
@property (nonatomic, assign, getter = isOAuthIndependentSwitchHasBeenSetted) BOOL oAuthIndependentSwitchHasBeenSetted;

/**
 OAuth 请求范围
 */
@property (nonatomic) MRRequestParameterOAuthRequestScope oAuthRequestScope;

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

/**
 相对稳定的参数字符串, 不包括内部生成的随机数, 时间戳等不固定参数以及包含以上参数所生成的参数, 这个参数字符串串用来判定重复请求.
 
 @Instructions: 如果 identifier 有值, 则 identifier 将作为请求的标识符, 也作为重复请求的判断依据.
 *
 */
@property (nonatomic, copy, readonly) NSString *relativelyStableParameterString;

/**
 参数标识符, 可根据需求拓展用法.
 
 @Instructions: 如果 identifier 有值, 则 identifier 将作为请求的标识符, 如果请求队列中已经存在一个正在处理(还未返回成功或失败)的请求,
                那么此后相同标识符的请求将不会被 resume, 也不会挂起或插入队列等候, 而是会直接抛出一个类似于"请勿重复请求"的错误描述信息, 直到那个请求处理完成(返回成功或失败),
                下一个有着相同标识符的请求才会被 resume.
 *
 */
@property (nonatomic, copy) NSString *identifier;



#pragma mark - life cycle

- (instancetype)initWithObject:(id)obj;

- (void)dealloc;

#pragma mark - rewrite setter

- (void)setOAuthIndependentSwitchState:(BOOL)oAuthIndependentSwitchState;

#pragma mark - rewrite getter

- (id)result;

- (NSString *)description;

@end
