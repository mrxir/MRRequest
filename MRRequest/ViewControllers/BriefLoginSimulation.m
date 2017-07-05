//
//  BriefLoginSimulation.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "BriefLoginSimulation.h"

#import <MRFramework/UIStoryboard+Extension.h>
#import <MRFramework/UIControl+Extension.h>
#import <MRFramework/NSDictionary+Extension.h>

#import <SVProgressHUD.h>

#import "MRRequest.h"

@interface BriefLoginSimulation ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fillItem;

@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIButton *pressureTestButton;

@property (nonatomic, strong) NSMutableDictionary *loginInfo;


@end

@implementation BriefLoginSimulation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginInfo = [NSMutableDictionary dictionary];
    
    [self.resetItem setTarget:self];
    [self.resetItem setAction:@selector(didClickResetItem:)];
    
    [self.fillItem setTarget:self];
    [self.fillItem setAction:@selector(didClickFillItem:)];
    
    NSString *path = @"http://10.0.40.119:8080/oauth/token?";
    
    // 登录
    [self.loginButton handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        
        self.loginInfo[@"username"] = self.usernameField.text;
        self.loginInfo[@"password"] = self.passwordField.text;
        
        MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:self.loginInfo];
        
        parameter.oAuthIndependentSwitchState = YES;
        parameter.oAuthRequestScope = MRRequestParameterOAuthRequestScopeRequestAccessToken;
        parameter.requestMethod = MRRequestParameterRequestMethodPost;
        parameter.formattedStyle = MRRequestParameterFormattedStyleForm;
        
        [SVProgressHUD showWithStatus:@"正在登录..."];
        
        [MRRequest requestWithPath:path parameter:parameter success:^(MRRequest *request, id receiveObject) {
            
            [SVProgressHUD dismiss];
            
            NSLog(@"receiveObject %@", receiveObject);
            
        } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
            
            if (error.code == MRRequestErrorCodeOAuthRequestAccessTokenFailed) {
                
                [SVProgressHUD showErrorWithStatus:@"用户名或密码错误"];
                
            } else {
                
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                
            }
            
        }];
        
        
    }];
    
    
    [self.pressureTestButton handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
            
            self.loginInfo[@"username"] = self.usernameField.text;
            self.loginInfo[@"password"] = self.passwordField.text;
            
            MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:self.loginInfo];
            
            parameter.oAuthRequestScope = MRRequestParameterOAuthRequestScopeRequestAccessToken;
            parameter.requestMethod = MRRequestParameterRequestMethodPost;
            parameter.formattedStyle = MRRequestParameterFormattedStyleForm;
            
            [MRRequest requestWithPath:path parameter:parameter success:^(MRRequest *request, id receiveObject) {
                
                NSLog(@"%@", receiveObject);
                
            } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
                
                if (error.code == MRRequestErrorCodeOAuthRequestAccessTokenFailed) {
                    
                    [SVProgressHUD showErrorWithStatus:@"用户名或密码错误"];
                    
                }
                
            }];
            
        }];
        
        
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
    
    self.usernameField.text = @"abc123";
    self.passwordField.text = @"123456";
    
    [self.loginInfo removeAllObjects];
    
    // insert map
    
    self.loginInfo[@"username"]         = self.usernameField.text;
    self.loginInfo[@"password"]         = self.passwordField.text;
    
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
