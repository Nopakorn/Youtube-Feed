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
    self.tabBarItem.image = [[UIImage imageNamed:@"settingIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    self.youtube = [[Youtube alloc] init];
    self.genreSelected = [[NSMutableArray alloc] initWithCapacity:10];
    MainTabBarViewController *tabbar = (MainTabBarViewController *)self.tabBarController;
    self.genreSelected = tabbar.genreSelected;
    
    [self createGenre];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

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
    NSString *genreSelectedString = @"";
    for(int i = 0 ; i < [self.genreSelected count] ; i++){
        genreSelectedString = [NSString stringWithFormat:@"%@ %@", genreSelectedString, [self.genreSelected objectAtIndex:i]];
    }
    genreSelectedString = [genreSelectedString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    [[NSUserDefaults standardUserDefaults] setObject:genreSelectedString forKey:@"genreSelectedString"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"genreSelectedFact"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.youtube callRecommendSearch:self.genreSelected withNextPage:NO];
    
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
    MainTabBarViewController *tabbar = (MainTabBarViewController *)self.tabBarController;
    [tabbar.recommendYoutube.titleList removeAllObjects];
    [tabbar.recommendYoutube.videoIdList removeAllObjects];
    [tabbar.recommendYoutube.thumbnailList removeAllObjects];
    
    for (int i = 0 ; i < [self.youtube.videoIdList count] ; i++) {
        [tabbar.recommendYoutube.videoIdList addObject:[self.youtube.videoIdList objectAtIndex:i]];
        [tabbar.recommendYoutube.titleList addObject:[self.youtube.titleList objectAtIndex:i]];
        [tabbar.recommendYoutube.thumbnailList addObject:[self.youtube.thumbnailList objectAtIndex:i]];
    }
    
    tabbar.genreSelected = self.genreSelected;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        NSDictionary *userInfo = @{@"youtubeObj": self.youtube
                                   };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingDidSelected" object:self userInfo:userInfo];
        [self.tabBarController setSelectedIndex:0];
    });
    
    
}

@end
