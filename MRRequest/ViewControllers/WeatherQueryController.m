//
//  WeatherQueryController.m
//  MRRequest
//
//  Created by MrXir on 2017/6/30.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "WeatherQueryController.h"

#import <MRFramework/UIControl+Extension.h>

#import "MRRequest.h"

@interface WeatherQueryController ()<MRRequestDelegate>

@property (nonatomic, weak) IBOutlet UITextField *cityField;

@property (nonatomic, weak) IBOutlet UIButton *queryButton;

@property (nonatomic, weak) IBOutlet UITextView *resultTextView;

@end

@interface MRDD : NSObject

@property (nonatomic, copy) NSString *myName;
@property (nonatomic, copy) NSString *myAge;

@end

@implementation MRDD

@end

@implementation WeatherQueryController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.cityField.text = @"101010100";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *path = @"http://wthrcdn.etouch.cn/weather_mini?";
    
    [self.queryButton handleWithEvents:UIControlEventTouchUpInside completion:^(__kindof UIControl *control) {
        
        id object = nil;
        object = @{@"citykey": self.cityField.text};
        
        MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:object];

        parameter.oAuthEnabled = NO;
        parameter.formattedStyle = MRRequestParameterFormattedStyleForm;
        
        [MRRequest requestWithPath:path parameter:parameter success:^(MRRequest *request, id receiveObject) {
            
            NSLog(@"%@", receiveObject);
            
        } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
            
            NSLog(@"%@", error);
            
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
