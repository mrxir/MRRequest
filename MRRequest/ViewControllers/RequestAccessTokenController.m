//
//  RequestAccessTokenController.m
//  MRRequest
//
//  Created by MrXir on 2017/7/6.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "RequestAccessTokenController.h"

#import "MRRequest.h"

@interface RequestAccessTokenController ()

@property (nonatomic, strong) NSMutableDictionary *oauthInfo;

@end

@implementation RequestAccessTokenController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.oauthInfo = [NSMutableDictionary dictionary];
    
    self.resetItem.target = self;
    self.resetItem.action = @selector(didClickResetItem:);
    
    self.fillItem.target = self;
    self.fillItem.action = @selector(didClickFillItem:);
    
    [self.requestButton addTarget:self action:@selector(didClickRequestButton:) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.oauth_client_id.text = @"ff2ff059d245ae8cb378ab54a92e966d";
    self.oauth_client_secret.text = @"01f32ac28d7b45e08932f11a958f1d9f";
    self.oauth_grant_type.text = @"password";
    
    self.oauth_username.text = @"abc123";
    self.oauth_password.text = @"123456";
    
    self.oauth_format.text = @"json";
    self.oauth_timestamp.text = [timestampDateFormatter stringFromDate:[NSDate date]];
    
    [self updateMapAndUI];
    
}

- (void)updateMapAndUI
{
    // insert map
    self.oauthInfo[@"client_id"]        = self.oauth_client_id.text;
    self.oauthInfo[@"client_secret"]    = self.oauth_client_secret.text;
    self.oauthInfo[@"grant_type"]       = self.oauth_grant_type.text;
    
    self.oauthInfo[@"username"]         = self.oauth_username.text;
    self.oauthInfo[@"password"]         = self.oauth_password.text;
    
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
    parameter.oAuthRequestScope = MRRequestParameterOAuthRequestScopeRequestAccessToken;
    parameter.requestMethod = MRRequestParameterRequestMethodPost;
    parameter.formattedStyle = MRRequestParameterFormattedStyleForm;
    
    [SVProgressHUD showWithStatus:@"正在登录..."];
    
    [MRRequest requestWithPath:self.oauth_server.text parameter:parameter success:^(MRRequest *request, id receiveObject) {
        
        [SVProgressHUD dismiss];
        
        self.resultTextView.text = [NSString stringWithFormat:@"%@", [receiveObject stringWithUTF8]];
        
    } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
        
        self.resultTextView.text = error.description;
        
        if (error.code == MRRequestErrorCodeOAuthRequestAccessTokenFailed) {
            
            [SVProgressHUD showErrorWithStatus:@"用户名或密码错误"];
            
        } else {
            
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            
        }
        
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
