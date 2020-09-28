//
//  AccountLoginController.m
//  MRRequest
//
//  Created by MrXir on 2017/7/6.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "AccountLoginController.h"

#import "MRRequest.h"

#import <MRFramework/NSString+TangExtension.h>
#import <MRFramework/NSObject+Extension.h>

#import <SVProgressHUD.h>

#import <UIView+Toast.h>

@interface AccountLoginController ()

@property (nonatomic, strong) NSMutableDictionary *loginInfo;

@end

@implementation AccountLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginInfo = [NSMutableDictionary dictionary];
    
    self.resetItem.target = self;
    self.resetItem.action = @selector(didClickResetItem:);
    
    self.fillItem.target = self;
    self.fillItem.action = @selector(didClickFillItem:);
    
    [self.loginButton addTarget:self action:@selector(didClickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)didClickResetItem:(UIBarButtonItem *)item
{
    for (UITextField *field in self.tableViewHeaderView.subviews) {
        
        if ([field isKindOfClass:[UITextField class]]) {
            
            field.text = nil;
            
        }
        
    }
    
    [self.view endEditing:YES];
}

- (void)didClickFillItem:(UIBarButtonItem *)item
{
    self.username.text = @"15201118210";
    self.password.text = @"123456";
}

- (void)updateMapAndUI
{
    // insert map
    self.loginInfo[@"username"]         = self.username.text;
    self.loginInfo[@"password"]         = self.password.text;
    //self.loginInfo[@"login_type"]       = @"0",
    self.loginInfo[@"client_type"]      = @"1";
    
}

- (void)didClickLoginButton:(UIButton *)button
{
    [self updateMapAndUI];
    
    NSString *path = [MROAuthRequestManager defaultManager].server;
    
    MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:self.loginInfo];
    
    parameter.oAuthIndependentSwitchState = YES;
    parameter.oAuthRequestScope = MRRequestParameterOAuthRequestScopeRequestAccessToken;
    parameter.requestMethod = MRRequestParameterRequestMethodPost;
    parameter.formattedStyle = MRRequestParameterFormattedStyleForm;    
    
    [SVProgressHUD showWithStatus:@"正在登录"];
    
    [MRRequest requestWithPath:path parameter:parameter success:^(MRRequest *request, id receiveObject) {
        
        [SVProgressHUD showWithStatus:@"登录成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"3秒后返回"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD showWithStatus:@"2秒后返回"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD showWithStatus:@"1秒后返回"];
                });
            });
            [SVProgressHUD dismissWithDelay:3 completion:^{
                //[self.navigationController popViewControllerAnimated:YES];
            }];
        });
        
        self.resultTextView.text = [NSString stringWithFormat:@"%@", [receiveObject stringWithUTF8]];
        
        
    } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
        
        self.resultTextView.text = error.description;
        
        if (error.code == MRRequestErrorCodeEqualRequestError) {
            [self.view makeToast:error.localizedDescription];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
        
    }];

}


@end
