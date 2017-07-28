//
//  QueryVehicleIdentifierController.m
//  MRRequest
//
//  Created by MrXir on 2017/7/6.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "QueryVehicleIdentifierController.h"

#import "MRRequest.h"

#import <SVProgressHUD.h>

#import <MRFramework/NSObject+Extension.h>

#import <UIView+Toast.h>

@interface QueryVehicleIdentifierController ()

@property (nonatomic, strong) NSMutableDictionary *queryInfo;

@end

@implementation QueryVehicleIdentifierController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.queryInfo = [NSMutableDictionary dictionary];
    
    self.resetItem.target = self;
    self.resetItem.action = @selector(didClickResetItem:);
    
    self.fillItem.target = self;
    self.fillItem.action = @selector(didClickFillItem:);
    
    [self.queryButton addTarget:self action:@selector(didClickQueryButton:) forControlEvents:UIControlEventTouchUpInside];
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
    self.vehicleIdentifier.text = @"LE4GF4BB6AL108989";
    
    [self updateMapAndUI];
    
}

- (void)updateMapAndUI
{
    // insert map
    self.queryInfo[@"vin"] = self.vehicleIdentifier.text;
    self.queryInfo[@"vinSource"] = @"1";
    
}

- (void)didClickQueryButton:(UIButton *)button
{
    [self updateMapAndUI];
    
    NSString *path = @"https://test-appif.chejianding.com:10000/api/home/homeIndex?";
    
    MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:nil];
    
    parameter.oAuthIndependentSwitchState = YES;
    parameter.oAuthRequestScope = MRRequestParameterOAuthRequestScopeOrdinaryBusiness;
    parameter.formattedStyle = MRRequestParameterFormattedStyleForm;
    parameter.requestMethod = MRRequestParameterRequestMethodPost;
    
    [SVProgressHUD showWithStatus:@"查询中..."];
    
    [MRRequest requestWithPath:path parameter:parameter success:^(MRRequest *request, id receiveObject) {
        
        [SVProgressHUD dismissWithDelay:1];
        
        self.resultTextView.text = [NSString stringWithFormat:@"%@", [receiveObject stringWithUTF8]];
        
    } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
        
        NSLog(@"%@", data.stringWithUTF8);
        
        self.resultTextView.text = error.description;
        
        if (error.code == MRRequestErrorCodeEqualRequestError) {
            [self.view makeToast:error.localizedDescription];
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
