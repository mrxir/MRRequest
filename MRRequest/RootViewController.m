//
//  RootViewController.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "RootViewController.h"

#import <MRFramework/UIStoryboard+Extension.h>

@interface RootViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.rowHeight = 60.0f;
    
    NSMutableArray *controllers = [NSMutableArray array];
    
    [controllers addObject:@{@"identifier": @"DetailLoginSimulation",
                             @"description": @"OAuth2 详细登录模拟"}];
    
    [controllers addObject:@{@"identifier": @"BriefLoginSimulation",
                             @"description": @"OAuth2 简要登录模拟"}];
    
    self.viewControllers = [NSArray arrayWithArray:controllers];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    
    NSString *description = self.viewControllers[indexPath.row][@"description"];
    NSString *identifier = self.viewControllers[indexPath.row][@"identifier"];
    
    cell.textLabel.text = description;
    cell.detailTextLabel.text = identifier;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *identifier = self.viewControllers[indexPath.row][@"identifier"];
    
    UIViewController *controller = [UIStoryboard matchControllerForIdentifier:identifier];
    
    [self.navigationController pushViewController:controller animated:YES];
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
