//
//  OAuthErrorCodeHandleController.m
//  MRRequest
//
//  Created by MrXir on 2017/7/7.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "OAuthErrorCodeHandleController.h"

#import <UIControl+Extension.h>

#import "MRRequest.h"

#import <SVProgressHUD.h>

#import <UIView+Toast.h>

#import <NSString+TangExtension.h>

#import <NSDictionary+Extension.h>

@interface OAuthErrorCodeHandleController ()

@property (nonatomic, strong) NSMutableDictionary *requestInfo;

@property (nonatomic, copy) NSString *path;

@end

@implementation OAuthErrorCodeHandleController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self handleUIAction];
    
    self.requestInfo = [NSMutableDictionary dictionary];
    
    NSDateFormatter *timestampDateFormatter = [[NSDateFormatter alloc] init];
    timestampDateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
    
#pragma mark - 授权
    
    // 生成获取授权请求
    [self.generateOAuthButton handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        
        [self.view makeToast:@"生成获取授权请求"];
        [self.requestInfo removeAllObjects];
        
        self.path = [MROAuthRequestManager defaultManager].server;
        self.requestInfo[@"client_id"] = [MROAuthRequestManager defaultManager].client_id;
        self.requestInfo[@"client_secret"] = [MROAuthRequestManager defaultManager].client_secret;
        self.requestInfo[@"username"] = @"abc123";
        self.requestInfo[@"password"] = @"123456";
        self.requestInfo[@"grant_type"] = @"password";
        self.requestInfo[@"format"] = @"json";
        self.requestInfo[@"timestamp"] = [timestampDateFormatter stringFromDate:[NSDate date]];
        self.requestInfo[@"sign"] = self.requestInfo.formattedIntoFormStyleString.md5Hash;
        
    }];
    
    // 执行获取授权请求
    [self.executeOAuthButton handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        
        [self sign];
        MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:self.requestInfo];
        parameter.oAuthIndependentSwitchState = YES;
        parameter.oAuthRequestScope = MRRequestParameterOAuthRequestScopeRequestAccessToken;
        parameter.formattedStyle = MRRequestParameterFormattedStyleForm;
        parameter.requestMethod = MRRequestParameterRequestMethodPost;
        
        [SVProgressHUD showWithStatus:@"正在执行获取授权请求"];
        [MRRequest requestWithPath:self.path parameter:parameter success:^(MRRequest *request, id receiveObject) {
            self.resultTextView.text = [receiveObject description];
            [SVProgressHUD showSuccessWithStatus:@"获取授权成功"];
        } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
            [MRRequest handleError:error];
            self.resultTextView.text = [error description];
        }];
        
    }];
    
#pragma mark - 续约
    
    // 生成续约授权请求
    [self.generateUpdateButton handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        
        [self.view makeToast:@"生成续约授权请求"];
        [self.requestInfo removeAllObjects];
        
        self.path = [MROAuthRequestManager defaultManager].server;
        self.requestInfo[@"client_id"] = [MROAuthRequestManager defaultManager].client_id;
        self.requestInfo[@"client_secret"] = [MROAuthRequestManager defaultManager].client_secret;
        self.requestInfo[@"grant_type"] = @"refresh_token";
        self.requestInfo[@"format"] = @"json";
        self.requestInfo[@"timestamp"] = [timestampDateFormatter stringFromDate:[NSDate date]];
        //self.requestInfo[@"sign"] = self.requestInfo.formattedIntoFormStyleString.md5Hash;
        
    }];
    
    // 执行续约授权请求
    [self.executeOAuthButton handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        
        [self sign];
        MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:self.requestInfo];
        parameter.oAuthIndependentSwitchState = YES;
        parameter.oAuthRequestScope = MRRequestParameterOAuthRequestScopeRequestAccessToken;
        parameter.formattedStyle = MRRequestParameterFormattedStyleForm;
        parameter.requestMethod = MRRequestParameterRequestMethodPost;
        
        [SVProgressHUD showWithStatus:@"正在执行续约授权请求"];
        [MRRequest requestWithPath:self.path parameter:parameter success:^(MRRequest *request, id receiveObject) {
            self.resultTextView.text = [receiveObject description];
            [SVProgressHUD showSuccessWithStatus:@"续约授权成功"];
        } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
            [MRRequest handleError:error];
            self.resultTextView.text = [error description];
        }];
        
    }];
    
#pragma mark - 业务
    
    // 生成OAuth普通业务请求
    [self.generateCommonButton handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        
        [self.view makeToast:@"生成OAuth普通业务请求"];
        [self.requestInfo removeAllObjects];
        
        self.path = @"http://10.0.40.101:8080/api/test?";
        self.requestInfo[@"vin"] = @"LE4GF4BB6AL108989";
        self.requestInfo[@"access_token"] = [MROAuthRequestManager defaultManager].access_token;
        self.requestInfo[@"format"] = @"json";
        self.requestInfo[@"timestamp"] = [timestampDateFormatter stringFromDate:[NSDate date]];
        self.requestInfo[@"sign"] = self.requestInfo.formattedIntoFormStyleString.md5Hash;
        
    }];
    
    // 执行OAuth普通业务请求
    [self.executeCommonButton handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        
        [self sign];
        MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:self.requestInfo];
        parameter.oAuthIndependentSwitchState = YES;
        parameter.oAuthRequestScope = MRRequestParameterOAuthRequestScopeOrdinaryBusiness;
        parameter.formattedStyle = MRRequestParameterFormattedStyleForm;
        parameter.requestMethod = MRRequestParameterRequestMethodPost;
        
        [SVProgressHUD showWithStatus:@"正在执行OAuth普通业务请求"];
        [MRRequest requestWithPath:self.path parameter:parameter success:^(MRRequest *request, id receiveObject) {
            self.resultTextView.text = [receiveObject description];
            [SVProgressHUD showSuccessWithStatus:@"OAuth普通业务请求成功"];
        } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
            [MRRequest handleError:error];
            self.resultTextView.text = [error description];
        }];
        
    }];
    
    
    
    
    
    
    
    
}

- (void)handleUIAction
{
    [self.invalidate_client_id handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        if (self.requestInfo[@"client_id"] != nil) {
            self.requestInfo[@"client_id"] = @"invalid_client_id";
            [self sign];
            [self.view makeToast:@"invalid_client_id"];
        } else {
            [self.view makeToast:@"没有该参数"];
        }
    }];
    
    [self.invalidate_client_secret handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        if (self.requestInfo[@"client_secret"] != nil) {
            self.requestInfo[@"client_secret"] = @"invalid_client_secret";
            [self sign];
            [self.view makeToast:@"invalid_client_secret"];
        } else {
            [self.view makeToast:@"没有该参数"];
        }
    }];
    
    [self.invalidate_username handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        if (self.requestInfo[@"username"] != nil) {
            self.requestInfo[@"username"] = @"invalid_username";
            [self sign];
            [self.view makeToast:@"invalid_username"];
        } else {
            [self.view makeToast:@"没有该参数"];
        }
    }];
    
    [self.invalidate_password handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        if (self.requestInfo[@"password"] != nil) {
            self.requestInfo[@"password"] = @"invalid_password";
            [self sign];
            [self.view makeToast:@"invalid_password"];
        } else {
            [self.view makeToast:@"没有该参数"];
        }
    }];
    
    [self.invalidate_grant_type handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        if (self.requestInfo[@"grant_type"] != nil) {
            self.requestInfo[@"grant_type"] = @"invalid_grant_type";
            [self sign];
            [self.view makeToast:@"invalid_grant_type"];
        } else {
            [self.view makeToast:@"没有该参数"];
        }
    }];
    
    [self.invalidate_format handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        if (self.requestInfo[@"format"] != nil) {
            self.requestInfo[@"format"] = @"invalid_format";
            [self sign];
            [self.view makeToast:@"invalid_format"];
        } else {
            [self.view makeToast:@"没有该参数"];
        }
    }];
    
    [self.invalidate_sign handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        if (self.requestInfo[@"sign"] != nil) {
            self.requestInfo[@"sign"] = @"invalid_sign";
            [self.view makeToast:@"invalid_sign"];
        } else {
            [self.view makeToast:@"没有该参数"];
        }
    }];
    
    [self.invalidate_access_token handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        if (self.requestInfo[@"access_token"] != nil) {
            self.requestInfo[@"access_token"] = @"invalid_access_token";
            [self sign];
            [self.view makeToast:@"invalid_access_token"];
        } else {
            [self.view makeToast:@"没有该参数"];
        }
    }];
    
    [self.invalidate_refresh_token handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        if (self.requestInfo[@"refresh_token"] != nil) {
            self.requestInfo[@"refresh_token"] = @"invalid_refresh_token";
            [self sign];
            [self.view makeToast:@"invalid_refresh_token"];
        } else {
            [self.view makeToast:@"没有该参数"];
        }
    }];
    
    [self.invalidate_parameter handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        [self.view makeToast:@"inserted a key in request info"];
        self.requestInfo[@"INSERTED KEY"] = @"INSERTED VALUE";
        [self sign];
    }];
}

- (void)sign
{
    NSString *sign = self.requestInfo[@"sign"];
    
    if ([sign isEqualToString:@"invalid_sign"] == NO) {
        [self.requestInfo removeObjectForKey:@"sign"];
        self.requestInfo[@"sign"] = self.requestInfo.formattedIntoFormStyleString.md5Hash;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
