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

#pragma mark - <自动填写>
- (void)didClickFillItem:(UIBarButtonItem *)item
{
    NSDateFormatter *timestampDateFormatter = [[NSDateFormatter alloc] init];
    timestampDateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
    
    self.oauth_server.text = [MROAuthRequestManager defaultManager].server;
    self.oauth_autodestruct.text = [@([MROAuthRequestManager defaultManager].oAuthInfoAutodestructTimeInterval) stringValue];
    
    self.oauth_client_id.text = [MROAuthRequestManager defaultManager].client_id;
    self.oauth_client_secret.text = [MROAuthRequestManager defaultManager].client_secret;
    self.oauth_grant_type.text = @"password";
    
    self.oauth_username.text = @"15201118210";
    self.oauth_password.text = @"123456";
    
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
    
    self.oauthInfo[@"username"]         = self.oauth_username.text;
    self.oauthInfo[@"password"]         = self.oauth_password.text;
    
    self.oauthInfo[@"format"]           = self.oauth_format.text;
    self.oauthInfo[@"timestamp"]        = self.oauth_timestamp.text;
    self.oauthInfo[@"client_type"]      = @"1";
    
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
    
    [SVProgressHUD showWithStatus:@"正在获取..."];
    
    [MRRequest requestWithPath:self.oauth_server.text parameter:parameter success:^(MRRequest *request, id receiveObject) {
        
        [SVProgressHUD dismissWithDelay:1];
        
        self.resultTextView.text = [NSString stringWithFormat:@"%@", [receiveObject stringWithUTF8]];
        
    } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
        
        self.resultTextView.text = error.description;
        
        [MRRequest handleError:error];
        
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
