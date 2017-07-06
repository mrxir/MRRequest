//
//  RefreshAccessTokenController.m
//  MRRequest
//
//  Created by MrXir on 2017/7/6.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "RefreshAccessTokenController.h"

#import "MRRequest.h"

@interface RefreshAccessTokenController ()

@property (nonatomic, strong) NSMutableDictionary *oauthInfo;

@end

@implementation RefreshAccessTokenController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.oauthInfo = [NSMutableDictionary dictionary];
    
    self.resetItem.target = self;
    self.resetItem.action = @selector(didClickResetItem:);
    
    self.fillItem.target = self;
    self.fillItem.action = @selector(didClickFillItem:);
    
    [self.refreshButton addTarget:self action:@selector(didClickRequestButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    NSDateFormatter *timestampDateFormatter = [[NSDateFormatter alloc] init];
    timestampDateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
    
    self.oauth_server.text = @"http://10.0.40.119:8080/oauth/token?";
    self.oauth_autodestruct.text = @"40";
    
    self.oauth_client_id.text = [MROAuthRequestManager defaultManager].client_id;
    self.oauth_client_secret.text = [MROAuthRequestManager defaultManager].client_secret;
    self.oauth_grant_type.text = @"refresh_token";
    
    //self.oauth_access_token.text = @"";
    self.oauth_refresh_token.text = [MROAuthRequestManager defaultManager].refresh_token;
    
    self.oauth_format.text = @"json";
    self.oauth_timestamp.text = [timestampDateFormatter stringFromDate:[NSDate date]];
    
    [self updateMapAndUI];
    
}

- (void)updateMapAndUI
{
    [self.oauthInfo removeObjectForKey:@"sign"];

    // insert map
    self.oauthInfo[@"client_id"]        = self.oauth_client_id.text;
    self.oauthInfo[@"client_secret"]    = self.oauth_client_secret.text;
    self.oauthInfo[@"grant_type"]       = self.oauth_grant_type.text;
    
    //self.oauthInfo[@"access_token"]     = self.oauth_access_token.text;
    self.oauthInfo[@"refresh_token"]    = self.oauth_refresh_token.text;
    
    self.oauthInfo[@"format"]           = self.oauth_format.text;
    self.oauthInfo[@"timestamp"]        = self.oauth_timestamp.text;
    
    // 签名
    NSString *sign = self.oauthInfo.formattedIntoFormStyleString.md5Hash;
        
    self.oauthInfo[@"sign"]             = sign;
    self.oauth_sign.text                = sign;
    
}

- (void)didClickRequestButton:(UIButton *)button
{
    [self updateMapAndUI];
    
    MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:self.oauthInfo];
    
    parameter.oAuthIndependentSwitchState = YES;
    parameter.oAuthRequestScope = MRRequestParameterOAuthRequestScopeRefreshAccessToken;
    parameter.requestMethod = MRRequestParameterRequestMethodPost;
    parameter.formattedStyle = MRRequestParameterFormattedStyleForm;
    
    [SVProgressHUD showWithStatus:@"正在刷新..."];
    
    [MRRequest requestWithPath:self.oauth_server.text parameter:parameter success:^(MRRequest *request, id receiveObject) {
        
        [SVProgressHUD dismissWithDelay:1];
        
        self.resultTextView.text = [NSString stringWithFormat:@"%@", [receiveObject stringWithUTF8]];
        
    } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
        
        self.resultTextView.text = error.description;
        
        [SVProgressHUD showErrorWithStatus:@"刷新访问令牌失败"];
        
    }];
    
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
