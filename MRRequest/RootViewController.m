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

@property (nonatomic, strong) NSArray *sections;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.rowHeight = 60.0f;
    
    NSString *sectionPlistFile = [[NSBundle mainBundle] pathForResource:@"Sections" ofType:@"plist"];
    
    NSDictionary *sectionPlistInfo = [NSDictionary dictionaryWithContentsOfFile:sectionPlistFile];
    
    self.sections = sectionPlistInfo[@"sections"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = self.sections[section][@"title"];
    return sectionTitle;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section][@"item"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    
    NSString *description = self.sections[indexPath.section][@"item"][indexPath.row][@"description"];
    NSString *identifier = self.sections[indexPath.section][@"item"][indexPath.row][@"identifier"];

    cell.textLabel.text = description;
    cell.detailTextLabel.text = identifier;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *identifier = self.sections[indexPath.section][@"item"][indexPath.row][@"identifier"];
    
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
