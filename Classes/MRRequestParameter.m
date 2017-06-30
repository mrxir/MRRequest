//
//  MRRequestParameter.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "MRRequestParameter.h"

#import "MRRequestManager.h"

#import <MRFramework/NSObject+Extension.h>
#import <MRFramework/NSDictionary+Extension.h>
#import <MRFramework/NSString+Extension.h>
#import <MRFramework/NSJSONSerialization+Extension.h>

@interface MRRequestParameter ()
{
    NSDateFormatter *_timestampDateFormatter;
}

@end

@implementation MRRequestParameter

#pragma mark - life cycle

- (void)dealloc
{
    // 释放所有的强引用属性
}

- (instancetype)initWithObject:(id)obj
{
    if (self = [super init]) {
        
        _source = obj;
        
        _timestampDateFormatter = [[NSDateFormatter alloc] init];
        _timestampDateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
        
    }
    return self;
}

#pragma mark - rewrite setter

- (void)setOAuthEnabled:(BOOL)oAuthEnabled
{
    _oAuthEnabled = oAuthEnabled;
    
    _oAuthIndependentSwitchHasBeenSetted = YES;
}

#pragma mark - rewrite getter

- (id)result
{
    return [self constructResultWithSource:self.source];
}

- (NSString *)description
{
    NSMutableDictionary *description = [NSMutableDictionary dictionary];
    
    description[@"source"] = self.source;
    description[@"result"] = self.result;
    
    return description.stringWithUTF8;
}


#pragma mark - private tool method

- (id)constructResultWithSource:(id)source
{
    
    // OAuth 开关状态
    BOOL oAuthEnabled = NO;
    if (self.isOAuthIndependentSwitchHasBeenSetted == YES) {
        oAuthEnabled = self.isOAuthEnabled;
    } else {
        oAuthEnabled = [MRRequestManager defaultManager].isOAuthEnabled;
    }
    
    
    // 处理 source 源对象, 可转JSON对象的保持不变, 不可转JSON对象的尝试将其属性转换为 NSDictionary
    id validJSONObjectOrString = nil;
    
    if ([NSJSONSerialization isValidJSONObject:source]) {
        validJSONObjectOrString = source;
    } else {
        if ([source superclass] == [NSObject class]) {
            validJSONObjectOrString = [NSObject propertyWithObject:source];
        } else {
            validJSONObjectOrString = [source description];
        }
    }
    
    id relativelyStableValidJSONObjectOrString = validJSONObjectOrString;
    
    // 根据 oAuth 开关状态插入参数
    if (oAuthEnabled == YES) {
        
        if (validJSONObjectOrString == nil) validJSONObjectOrString = [NSDictionary dictionary];
        
        if ([validJSONObjectOrString isKindOfClass:[NSDictionary class]]) {
            
            NSMutableDictionary *oAuthDynamicParameter = [NSMutableDictionary dictionaryWithDictionary:validJSONObjectOrString];
            
            // 根据 requestScope 判定应该增加哪些特定参数
            if (self.requestScope == MRRequestParameterRequestScopeNormal) {
                oAuthDynamicParameter[@"access_token"]   = @"-access_token-";
            }
            
            if (self.requestScope == MRRequestParameterRequestScopeRequestAccessToken) {
                oAuthDynamicParameter[@"client_id"]      = @"ff2ff059d245ae8cb378ab54a92e966d";
                oAuthDynamicParameter[@"client_secret"]  = @"01f32ac28d7b45e08932f11a958f1d9f";
                oAuthDynamicParameter[@"grant_type"]     = @"password";
            }
            
            if (self.requestScope == MRRequestParameterRequestScopeRefreshAccessToken) {
                oAuthDynamicParameter[@"client_id"]      = @"ff2ff059d245ae8cb378ab54a92e966d";
                oAuthDynamicParameter[@"client_secret"]  = @"01f32ac28d7b45e08932f11a958f1d9f";
                oAuthDynamicParameter[@"refresh_token"]  = @"-refresh_token-";
                oAuthDynamicParameter[@"grant_type"]     = @"refresh_token";
            }
            
            oAuthDynamicParameter[@"format"] = @"json";
            
            relativelyStableValidJSONObjectOrString = [NSDictionary dictionaryWithDictionary:oAuthDynamicParameter];
            
            oAuthDynamicParameter[@"timestamp"] = [_timestampDateFormatter stringFromDate:[NSDate date]];
            
            // 使用非空的键值对进行签名
            NSMutableDictionary *notEmptyKeyValueMap = [NSMutableDictionary dictionaryWithDictionary:oAuthDynamicParameter];
            [notEmptyKeyValueMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(length)]) {
                    if ([obj performSelector:@selector(length)] == 0) {
                        [notEmptyKeyValueMap removeObjectForKey:key];
                    }
                }
            }];
            oAuthDynamicParameter[@"sign"] = notEmptyKeyValueMap.formattedIntoFormStyleString.md5Hash;
            
            validJSONObjectOrString = oAuthDynamicParameter;
            
        }
        
    }
    
    // 若此时 validJSONObjectOrString 为空, 则直接返回 nil.
    if (validJSONObjectOrString == nil) return nil;
    
    // 参数格式化
    NSString *parameterFormattedString = nil;
    
    // 相对稳定对象格式化
    NSString *relativelyStableValidJSONObjectOrStringFormattedstring = nil;
    
    // 格式化为 JSON 字符串
    if (self.formattedStyle == MRRequestParameterFormattedStyleJSON) {
        
        parameterFormattedString = [NSJSONSerialization stringWithJSONObject:validJSONObjectOrString options:0 error:nil];
        
        relativelyStableValidJSONObjectOrStringFormattedstring = [NSJSONSerialization stringWithJSONObject:relativelyStableValidJSONObjectOrString options:0 error:nil];
        
    }
    
    // 格式化为 FORM 字符串
    if (self.formattedStyle == MRRequestParameterFormattedStyleForm) {
        
        if ([validJSONObjectOrString isKindOfClass:[NSDictionary class]]) {
            
            parameterFormattedString = [validJSONObjectOrString formattedIntoFormStyleString];
            
            relativelyStableValidJSONObjectOrStringFormattedstring = [relativelyStableValidJSONObjectOrString formattedIntoFormStyleString];
            
        } else {
            
            parameterFormattedString = [NSJSONSerialization stringWithJSONObject:validJSONObjectOrString options:0 error:nil];

            relativelyStableValidJSONObjectOrStringFormattedstring = [NSJSONSerialization stringWithJSONObject:relativelyStableValidJSONObjectOrString options:0 error:nil];

        }
        
        if (!parameterFormattedString) {
            parameterFormattedString = [validJSONObjectOrString description];
        }
        
        if (!relativelyStableValidJSONObjectOrStringFormattedstring) {
            relativelyStableValidJSONObjectOrStringFormattedstring = [relativelyStableValidJSONObjectOrString description];
        }
        
    }
    
    // 处理参数前缀
    if (self.sourcePrefix.length) {
        
        parameterFormattedString = [self.sourcePrefix stringByAppendingString:parameterFormattedString];
        
        relativelyStableValidJSONObjectOrStringFormattedstring = [self.sourcePrefix stringByAppendingString:relativelyStableValidJSONObjectOrStringFormattedstring];
    }
    
    _relativelyStableParameterString = relativelyStableValidJSONObjectOrStringFormattedstring;
    
    // 处理请求方式
    id returnObject = nil;
    
    if (self.requestMethod == MRRequestParameterRequestMethodGet) {
        returnObject = self.resultEncoding == 0 ? parameterFormattedString : [parameterFormattedString stringByAddingPercentEscapesUsingEncoding:self.resultEncoding];
    }
    
    if (self.requestMethod == MRRequestParameterRequestMethodPost) {
        NSLog(@"%@", parameterFormattedString);
        returnObject = [parameterFormattedString dataUsingEncoding:self.resultEncoding == 0 ? NSUTF8StringEncoding : self.resultEncoding];
    }
    
    return returnObject;
    
}

@end
