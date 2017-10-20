//
//  LoginSimulateViewController.m
//  MRRequest
//
//  Created by MrXir on 2017/10/18.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "LoginSimulateViewController.h"

#import "MRRequest.h"

@interface LoginSimulateViewController ()<UIAlertViewDelegate>
{
    BOOL _needSmsCheck;
}

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *captchaField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captchaWidth;

@property (nonatomic, strong) NSMutableDictionary *oauthInfo;

@end

@implementation LoginSimulateViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.usernameField.text = @"15201118210";
    self.passwordField.text = @"123456";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.oauthInfo = [NSMutableDictionary dictionary];
    
    [self.loginButton addTarget:self action:@selector(userPasswordLoginAction:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)userPasswordLoginAction:(id)sender
{
    // insert map
    self.oauthInfo[@"client_id"]        = [MROAuthRequestManager defaultManager].client_id;
    self.oauthInfo[@"client_secret"]    = [MROAuthRequestManager defaultManager].client_secret;
    
    if (_needSmsCheck == YES) {
        self.oauthInfo[@"grant_type"]       = @"smscheck";
    } else {
        self.oauthInfo[@"grant_type"]       = @"password";
    }
    
    self.oauthInfo[@"username"]             = self.usernameField.text;
    
    if (_needSmsCheck == YES) {
        self.oauthInfo[@"password"]         = self.captchaField.text;
    } else {
        self.oauthInfo[@"password"]         = self.passwordField.text;
    }
    
    self.oauthInfo[@"format"]               = @"json";
    
    NSDateFormatter *timestampDateFormatter = [[NSDateFormatter alloc] init];
    timestampDateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";

    self.oauthInfo[@"timestamp"]            = [timestampDateFormatter stringFromDate:[NSDate date]];
    self.oauthInfo[@"client_type"]          = @"1";
    
    // 签名
    NSString *sign = self.oauthInfo.formattedIntoFormStyleString.md5Hash;
    
    self.oauthInfo[@"sign"]                 = sign;
    
    NSLog(@"%@", self.oauthInfo.stringWithUTF8);
    
    NSString *path = [MROAuthRequestManager defaultManager].server;
    
    MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:self.oauthInfo];
    
    parameter.oAuthIndependentSwitchState = YES;
    parameter.oAuthRequestScope = MRRequestParameterOAuthRequestScopeRequestAccessToken;
    parameter.requestMethod = MRRequestParameterRequestMethodPost;
    parameter.formattedStyle = MRRequestParameterFormattedStyleForm;
    
    [SVProgressHUD showWithStatus:@"正在获取..."];
    
    [MRRequest requestWithPath:path parameter:parameter success:^(MRRequest *request, id receiveObject) {
        
        [SVProgressHUD showSuccessWithStatus:@"登录成功"];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        NSLog(@"receiveObject %@", [receiveObject stringWithUTF8]);
        
    } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
        
        NSString *oAuthErrorCode = error.userInfo[@"oAuthErrorCode"];
        
        if ([oAuthErrorCode isEqualToString:@"new_device"]) {
            
            [SVProgressHUD dismiss];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新设备验证"
                                                            message:@"为了您的账户安全，我们已向您绑定的手机[188****5228]发送登录验证码，请注意查收。\n如需帮助请拨打客服热线。"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
            [alert show];
            
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
        
    }];
    
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.captchaWidth.constant = 110.0f;
        [self.view layoutIfNeeded];
    }];
    
    _needSmsCheck = YES;
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
