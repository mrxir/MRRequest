//
//  DetailLoginSimulation.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "DetailLoginSimulation.h"

#import <MRFramework/UIStoryboard+Extension.h>
#import <MRFramework/UIControl+Extension.h>
#import <MRFramework/NSDictionary+Extension.h>
#import <MRFramework/NSString+Extension.h>

#import <SVProgressHUD.h>

#import "MRRequestParameter.h"

@interface DetailLoginSimulation ()
{
    NSDateFormatter *_timestampDateFormatter;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fillItem;

@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;

@property (weak, nonatomic) IBOutlet UITextField *serverAddressField;
@property (weak, nonatomic) IBOutlet UITextField *authValidDurationField;

@property (weak, nonatomic) IBOutlet UITextField *client_id_field;
@property (weak, nonatomic) IBOutlet UITextField *client_secret_field;
@property (weak, nonatomic) IBOutlet UITextField *grant_type_field;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UITextField *formatField;
@property (weak, nonatomic) IBOutlet UITextField *timestampField;
@property (weak, nonatomic) IBOutlet UITextField *signField;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, strong) NSMutableDictionary *loginInfo;

@end

@implementation DetailLoginSimulation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginInfo = [NSMutableDictionary dictionary];
    
    _timestampDateFormatter = [[NSDateFormatter alloc] init];
    _timestampDateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
    
    [self.resetItem setTarget:self];
    [self.resetItem setAction:@selector(didClickResetItem:)];
    
    [self.fillItem setTarget:self];
    [self.fillItem setAction:@selector(didClickFillItem:)];
    
    // 登录
    [self.loginButton handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        
        MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:self.loginInfo];
        
        parameter.requestScope = MRRequestParameterRequestScopeRequestAccessToken;
        
        NSLog(@"result %@", parameter.result);
        
        [SVProgressHUD showWithStatus:@"正在登录..."];
        
        [SVProgressHUD dismissWithDelay:3];
        
        
    }];
}

- (void)didClickResetItem:(UIBarButtonItem *)item
{
    
    for (UITextField *field in self.tableHeaderView.subviews) {
        
        if ([field isKindOfClass:[UITextField class]]) {
            
            field.text = nil;
            
        }
        
    }
    
    [self.view endEditing:YES];
}

- (void)didClickFillItem:(UIBarButtonItem *)item
{
    // fill field
    self.serverAddressField.text = @"http://10.0.40.119:8080/oauth/token?";
    self.authValidDurationField.text = @"40";
    
    self.client_id_field.text = @"ff2ff059d245ae8cb378ab54a92e966d";
    self.client_secret_field.text = @"01f32ac28d7b45e08932f11a958f1d9f";
    self.grant_type_field.text = @"password";
    
    self.usernameField.text = @"abc123";
    self.passwordField.text = @"123456";
    
    self.formatField.text = @"json";
    self.timestampField.text = [_timestampDateFormatter stringFromDate:[NSDate date]];
    
    [self.loginInfo removeAllObjects];
    
    // insert map
    self.loginInfo[@"client_id"]        = self.client_id_field.text;
    self.loginInfo[@"client_secret"]    = self.client_secret_field.text;
    self.loginInfo[@"grant_type"]       = self.grant_type_field.text;
    
    self.loginInfo[@"username"]         = self.usernameField.text;
    self.loginInfo[@"password"]         = self.passwordField.text;
    
    self.loginInfo[@"format"]           = self.formatField.text;
    self.loginInfo[@"timestamp"]        = self.timestampField.text;
    
    // 签名
    NSString *sign = self.loginInfo.formattedIntoFormStyleString.md5Hash;
    
    self.loginInfo[@"sign"]             = sign;
    
    self.signField.text                 = sign;
    
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
