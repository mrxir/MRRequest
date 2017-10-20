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

#import "NSString+URLEncode.h"

@interface MRRequestParameter ()
{
    NSDateFormatter *_timestampDateFormatter;
}

@end

@implementation MRRequestParameter

@synthesize structure = _structure;

#pragma mark - life cycle

- (void)dealloc
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[OAUTH] ▫️ %s", __FUNCTION__);
    }
}

- (instancetype)initWithObject:(id)obj
{
    if (self = [super init]) {
        
        _object = obj;
        
        _timestampDateFormatter = [[NSDateFormatter alloc] init];
        _timestampDateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
        
    }
    return self;
}

#pragma mark - rewrite setter

- (void)setOAuthIndependentSwitchState:(BOOL)oAuthIndependentSwitchState
{
    _oAuthIndependentSwitchState = oAuthIndependentSwitchState;
    
    _oAuthIndependentSwitchHasBeenSetted = YES;
}

#pragma mark - rewrite getter

- (id)structure
{
    if (!_structure) {
        id dynamicParameter = nil;
        _structure = [self constructResultWithSource:self.object dynamicParameter:&dynamicParameter];
        _dynamicParameter = dynamicParameter;
    }
    
    return _structure;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"<%@: %p>", self.class, self];
    
    NSMutableDictionary *property = [NSMutableDictionary dictionary];
    property[@"source"] = self.object;
    property[@"structure"] = self.structure;
    property[@"dynamicParameter"] = self.dynamicParameter;
    property[@"isOAuthIndependentSwitchState"] = @(self.isOAuthIndependentSwitchState);
    property[@"isOAuthIndependentSwitchHasBeenSetted"] = @(self.isOAuthIndependentSwitchHasBeenSetted);
    property[@"oAuthRequestScope"] = @(self.oAuthRequestScope);
    property[@"requestMethod"] = @(self.requestMethod);
    property[@"formattedStyle"] = @(self.formattedStyle);
    property[@"resultEncoding"] = @(self.resultEncoding);
    property[@"sourcePrefix"] = self.sourcePrefix;
    property[@"relativelyStableParameterString"] = self.relativelyStableParameterString;
    property[@"identifier"] = self.identifier;
    
    [description appendFormat:@" "];
    [description appendFormat:@"%@", property];
    
    return description;
}


#pragma mark - private tool method

- (NSString *)encryptWithSHA1:(NSString *)sha1Source
{
    sha1Source = [sha1Source stringByAppendingString:@"SHA"];
    
    sha1Source = sha1Source.md5Hash;
    
    return sha1Source;
}

- (id)constructResultWithSource:(id)source dynamicParameter:(id *)dynamicParameter
{
    
    // OAuth 开关状态
    BOOL oAuthEnabled = NO;
    if (self.isOAuthIndependentSwitchHasBeenSetted == YES) {
        oAuthEnabled = self.isOAuthIndependentSwitchState;
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
            if (self.oAuthRequestScope == MRRequestParameterOAuthRequestScopeOrdinaryBusiness) {
                
                NSString *access_token = oAuthDynamicParameter[@"access_token"];
                if (![NSString isValidString:access_token]) access_token = [MROAuthRequestManager defaultManager].access_token;
                oAuthDynamicParameter[@"access_token"] = access_token;
                
            }
            
            if (self.oAuthRequestScope == MRRequestParameterOAuthRequestScopeRequestAccessToken) {
                
                NSString *client_id = oAuthDynamicParameter[@"client_id"];
                NSString *client_secret = oAuthDynamicParameter[@"client_secret"];
                NSString *grant_type = oAuthDynamicParameter[@"grant_type"];
                
                if (![NSString isValidString:client_id]) client_id = [MROAuthRequestManager defaultManager].client_id;
                if (![NSString isValidString:client_secret]) client_secret = [MROAuthRequestManager defaultManager].client_secret;
                if (![NSString isValidString:grant_type]) grant_type = @"password";
                
                oAuthDynamicParameter[@"client_id"]      = client_id;
                oAuthDynamicParameter[@"client_secret"]  = client_secret;
                oAuthDynamicParameter[@"grant_type"]     = grant_type;
                
            }
            
            if (self.oAuthRequestScope == MRRequestParameterOAuthRequestScopeRefreshAccessToken) {
                
                NSString *client_id = oAuthDynamicParameter[@"client_id"];
                NSString *client_secret = oAuthDynamicParameter[@"client_secret"];
                NSString *grant_type = oAuthDynamicParameter[@"grant_type"];
                NSString *refresh_token = oAuthDynamicParameter[@"refresh_token"];
                
                if (![NSString isValidString:client_id]) client_id = [MROAuthRequestManager defaultManager].client_id;
                if (![NSString isValidString:client_secret]) client_secret = [MROAuthRequestManager defaultManager].client_secret;
                if (![NSString isValidString:refresh_token]) refresh_token = [MROAuthRequestManager defaultManager].refresh_token;
                if (![NSString isValidString:grant_type]) grant_type = @"refresh_token";
                
                oAuthDynamicParameter[@"client_id"]      = client_id;
                oAuthDynamicParameter[@"client_secret"]  = client_secret;
                oAuthDynamicParameter[@"grant_type"]     = grant_type;
                oAuthDynamicParameter[@"refresh_token"]  = refresh_token;
                
            }
            
            NSString *format = oAuthDynamicParameter[@"format"];
            if (![NSString isValidString:format]) format = @"json";
            oAuthDynamicParameter[@"format"] = format;
            
            relativelyStableValidJSONObjectOrString = [NSDictionary dictionaryWithDictionary:oAuthDynamicParameter];
            
            NSString *timestamp = oAuthDynamicParameter[@"timestamp"];
            if (![NSString isValidString:timestamp]) timestamp = [_timestampDateFormatter stringFromDate:[NSDate date]];
            oAuthDynamicParameter[@"timestamp"] = timestamp;
            
            // 使用非空的键值对进行签名
            NSMutableDictionary *notEmptyKeyValueMap = [NSMutableDictionary dictionaryWithDictionary:oAuthDynamicParameter];
            [notEmptyKeyValueMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(length)]) {
                    if ([obj performSelector:@selector(length)] == 0) {
                        [notEmptyKeyValueMap removeObjectForKey:key];
                    }
                }
            }];
            
            NSString *sign = oAuthDynamicParameter[@"sign"];
            if (![NSString isValidString:sign]) sign = notEmptyKeyValueMap.formattedIntoFormStyleString.md5Hash;
            
            // SHA 加密
            sign = [self encryptWithSHA1:sign];
            
            oAuthDynamicParameter[@"sign"] = sign;
            
            validJSONObjectOrString = oAuthDynamicParameter;
            
        }
        
    }
    
    // 若此时 validJSONObjectOrString 为空, 则直接返回 nil.
    if (validJSONObjectOrString == nil) return nil;
    
    // 如果 validJSONObjectOrString 可以追加参数， 那么如果有自定义附加参数就往内部追加。
    // 追加默认参数之后, 需要重新执行sign处理: 去空值的键值对; 移除旧的签名键值对;
    
    if ([validJSONObjectOrString isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *customAdditionalParameter = [MRRequestManager defaultManager].customAdditionalParameter;
        
        if ([customAdditionalParameter isKindOfClass:[NSDictionary class]]) {
            
            validJSONObjectOrString = [NSMutableDictionary dictionaryWithDictionary:validJSONObjectOrString];
            [validJSONObjectOrString setValuesForKeysWithDictionary:customAdditionalParameter];
            
            // 使用非空的键值对进行签名
            NSMutableDictionary *notEmptyKeyValueMap = [NSMutableDictionary dictionaryWithDictionary:validJSONObjectOrString];
            [notEmptyKeyValueMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(length)]) {
                    if ([obj performSelector:@selector(length)] == 0) {
                        [notEmptyKeyValueMap removeObjectForKey:key];
                    }
                }
            }];
            
            // 如果有默认参数，则加入默认参数后重新加签
            [notEmptyKeyValueMap removeObjectForKey:@"sign"];
            
            // SHA 加密
            NSString *sign = notEmptyKeyValueMap.formattedIntoFormStyleString.md5Hash;
            
            validJSONObjectOrString[@"sign"] = [self encryptWithSHA1:sign];
            
            NSMutableDictionary *encodeParam = [NSMutableDictionary dictionary];
            
            [validJSONObjectOrString enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                encodeParam[key] = [[NSString stringWithFormat:@"%@", obj] URLEncode];
            }];
            
            validJSONObjectOrString = encodeParam;
        }
        
    }
    
    if (dynamicParameter != nil) {
        
        *dynamicParameter = validJSONObjectOrString;
        
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
            NSLog(@"[OAUTH] ▫️ DynamicParameter <%@: %p> %@", [validJSONObjectOrString superclass], validJSONObjectOrString, validJSONObjectOrString);
        }
        
    }
    
    
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
        returnObject = [parameterFormattedString dataUsingEncoding:self.resultEncoding == 0 ? NSUTF8StringEncoding : self.resultEncoding];
    }
    
    return returnObject;
    
}

@end
