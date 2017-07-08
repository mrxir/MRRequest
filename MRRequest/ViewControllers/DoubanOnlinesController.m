//
//  DoubanOnlinesController.m
//  MRRequest
//
//  Created by MrXir on 2017/7/8.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "DoubanOnlinesController.h"

#import "MRRequest.h"

#import <NSObject+Extension.h>

#import <SVProgressHUD.h>

#import <UIControl+Extension.h>

#import <UIView+Toast.h>


@interface DoubanOnlinesController ()

@property (weak, nonatomic) IBOutlet UIButton *queryButton;

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@end

@implementation DoubanOnlinesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [MRRequest deactiveOAuth];
    
    [self.queryButton handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        
        [SVProgressHUD show];
        
        NSString *path = @"https://api.douban.com/v2/onlines?cate=latest";
        
        [MRRequest requestWithPath:path parameter:nil success:^(MRRequest *request, id receiveObject) {
            
            self.resultTextView.text = [receiveObject stringWithUTF8];
            
            [SVProgressHUD dismiss];
            
        } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
            
            [MRRequest handleError:error];
            
        }];
        
    }];
    
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
