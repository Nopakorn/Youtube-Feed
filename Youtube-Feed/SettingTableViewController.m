//
//  SettingTableViewController.m
//  Youtube-Feed
//
//  Created by guild on 3/8/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "SettingTableViewController.h"
#import "MainTabBarViewController.h"
#import "SettingCustomCell.h"


@interface SettingTableViewController ()

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.youtube = [[Youtube alloc] init];
    NSLog(@"ViewDidload SettingTableViewController");
    self.genreSelected = [[NSMutableArray alloc] initWithCapacity:10];
    MainTabBarViewController *tabbar = (MainTabBarViewController *)self.tabBarController;
    self.genreSelected = tabbar.genreSelected;
    NSLog(@"gern scale %lu",(unsigned long)[tabbar.genreSelected count]);
    [self createGenre];
    //self.settingTableView.delegate = self;
    self.settingTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}
- (void)createGenre
{
    self.genreList = [[NSMutableArray alloc] initWithObjects:@"Pop", @"Rock", @"Alternative Rock", @"Classical", @"Country", @"Dance", @"Folk", @"Indie", @"Jazz", @"Hip-hop", nil];
    NSLog(@"count in create %lu",(unsigned long)[self.genreList count]);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.genreList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"SettingCustomCell";
    //[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    SettingCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SettingCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSInteger row = indexPath.row;
    if ([self checkmark:row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.type.text = [self.genreList objectAtIndex:indexPath.row];
    return cell;
}

- (BOOL)checkmark:(NSInteger )row
{
    NSString *item = [self.genreList objectAtIndex:row];
    if(self.genreSelected != 0){
        for (int i = 0; i < [self.genreSelected count]; i++) {
            if([[self.genreSelected objectAtIndex:i] isEqualToString:item]){
                return true;
                
            }
        }
    }
    return false;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *item = [self.genreList objectAtIndex:indexPath.row];
    if([self.genreSelected count] != 0 ){
        for (int i=0; i < [self.genreSelected count]; i++) {
            if([[self.genreSelected objectAtIndex:i] isEqualToString:item]){
                [self.genreSelected removeObjectAtIndex:i];
                break;
                
            }else if(i == [self.genreSelected count] - 1){
                
                [self.genreSelected addObject:[self.genreList objectAtIndex:indexPath.row]];
                break;
            }
        }
    }else{
        [self.genreSelected addObject:[self.genreList objectAtIndex:indexPath.row]];
    }
    [tableView reloadData];

}

- (IBAction)submitButtonPressed:(id)sender
{
    [self.youtube callSearch:self.genreSelected];
    
    alert = [UIAlertController alertControllerWithTitle:nil message:@"Loading\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(130.5, 65.5);
    spinner.color = [UIColor blackColor];
    [alert.view addSubview:spinner];
    [spinner startAnimating];
    [self presentViewController:alert animated:NO completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoId)
                                                 name:@"LoadVideoId" object:nil];
    //[self performSegueWithIdentifier:@"SubmitSetting" sender:nil];
    
    
}

- (void)receivedLoadVideoId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [alert dismissViewControllerAnimated:YES completion:nil];
        //[self.tabBarController setSelectedIndex:0];
    });
    //NSDictionary *userInfo = self.youtube;
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"SelectedFromRecommend" object:self userInfo:userInfo];
    
}

@end
