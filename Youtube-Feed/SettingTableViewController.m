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
#import "AppDelegate.h"

#import <UIEMultiAccess/UIEMultiAccess.h>
#import <UIEMultiAccess/DNApplicationManager.h>
#import <UIEMultiAccess/DNAppCatalog.h>
#import <UIEMultiAccess/UMAApplicationInfo.h>

typedef NS_ENUM(NSInteger, SectionType) {
    SECTION_TYPE_SETTINGS,
    SECTION_TYPE_LAST_CONNECTED_DEVICE,
    SECTION_TYPE_CONNECTED_DEVICE,
    SECTION_TYPE_DISCOVERED_DEVICES,
};

typedef NS_ENUM(NSInteger, AlertType) {
    ALERT_TYPE_FAIL_TO_CONNECT,
    ALERT_TYPE_DISCOVERY_TIMEOUT,
};

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface SettingTableViewController ()<UMAFocusManagerDelegate>

@property (nonatomic, strong) UMAFocusManager *focusManager;
@end


@implementation SettingTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarItem.image = [[UIImage imageNamed:@"settingIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    
    
    self.genreSelected = [[NSMutableArray alloc] initWithCapacity:10];
    self.genreIdSelected = [[NSMutableArray alloc] initWithCapacity:10];
    MainTabBarViewController *tabbar = (MainTabBarViewController *)self.tabBarController;
    self.genreSelected = tabbar.genreSelected;
    self.genreList = tabbar.genreTitles;
    self.genreIdList = tabbar.genreIds;
    self.genreIdSelected = tabbar.genreIdSelected;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Setting", nil)];
    [self.submitButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Save", nil)] forState:UIControlStateNormal];
    
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"in viewDidAppaer setting");
    [self.genreSelected removeAllObjects];
    NSString *saveGenreId = [[NSUserDefaults standardUserDefaults] stringForKey:@"genreIdSelectedString"];
    NSArray *stringSeparatedId = [saveGenreId componentsSeparatedByString:@"|"];
    self.genreIdSelected = [NSMutableArray arrayWithArray:stringSeparatedId];
    
    for (int i = 0; i < [self.genreIdSelected count]; i++) {
        for (int j = 0; j < [self.genreIdList count]; j++) {
           
            if ([[self.genreIdSelected objectAtIndex:i] isEqualToString:[self.genreIdList objectAtIndex:j]]) {
                [self.genreSelected addObject:[self.genreList objectAtIndex:j]];
                 NSLog(@"adding genreSelected i:%d, j:%d",i,j);
                break;
            }
        }
    }
    NSLog(@"save genre = %@", saveGenreId);
    NSLog(@"genre id selected = %@", saveGenreId);
    NSLog(@"reset genre = %@", self.genreSelected);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 5)];
    navBorder.tag = 99;
    [navBorder setBackgroundColor:UIColorFromRGB(0x4F6366)];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setHidden:YES];
    [self.tableView reloadData];
}

- (void)orientationChanged:(NSNotification *)notification
{
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if (subView.tag == 99) {
            [subView removeFromSuperview];
        }
    }
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 5)];
    navBorder.tag = 99;
    [navBorder setBackgroundColor:UIColorFromRGB(0x4F6366)];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    NSLog(@"View changing");

}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_focusManager setHidden:YES];
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if (subView.tag == 99) {
            [subView removeFromSuperview];
        }
    }
}


- (void)callGenre
{
    [self.genre getGenreFromYoutube];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedGenre)
                                                 name:@"LoadGenreTitle" object:nil];
}
- (void)receivedGenre
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.genreList = self.genre.genreTitles;
        self.genreIdList = self.genre.genreIds;
        [self.genreSelected removeAllObjects];
        
        NSString *saveGenreId = [[NSUserDefaults standardUserDefaults] stringForKey:@"genreIdSelectedString"];
        NSLog(@"saveGenreId = %@", saveGenreId);
        NSArray *stringSeparatedId = [saveGenreId componentsSeparatedByString:@"|"];
        self.genreIdSelected = [NSMutableArray arrayWithArray:stringSeparatedId];
        
        for (int i = 0; i < [self.genreIdSelected count]; i++) {
            for (int j = 0; j < [self.genreIdList count]; j++) {
                
                if ([[self.genreIdSelected objectAtIndex:i] isEqualToString:[self.genreIdList objectAtIndex:j]]) {
                    [self.genreSelected addObject:[self.genreList objectAtIndex:j]];
                }
            }
        }
        NSLog(@"reset genre = %@", self.genreSelected);
        [alert dismissViewControllerAnimated:YES completion:nil];
        [self.tableView reloadData];

    });

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
//    NSString *item = [self.genreList objectAtIndex:row];
//    if(self.genreSelected != 0){
//        for (int i = 0; i < [self.genreSelected count]; i++) {
//            if([[self.genreSelected objectAtIndex:i] isEqualToString:item]){
//                return true;
//                
//            }
//        }
//    }
//    return false;
    NSString *itemId = [self.genreIdList objectAtIndex:row];
    
    if(self.genreIdSelected != 0){
        for (int i = 0; i < [self.genreIdSelected count]; i++) {
            if([[self.genreIdSelected objectAtIndex:i] isEqualToString:itemId]){
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
    //
    NSString *itemId = [self.genreIdList objectAtIndex:indexPath.row];
    if([self.genreIdSelected count] != 0 ){
        for (int i=0; i < [self.genreIdSelected count]; i++) {
            if([[self.genreIdSelected objectAtIndex:i] isEqualToString:itemId]){
                [self.genreIdSelected removeObjectAtIndex:i];
                break;
                
            }else if(i == [self.genreIdSelected count] - 1){
                [self.genreIdSelected addObject:[self.genreIdList objectAtIndex:indexPath.row]];
                break;
            }
        }
    }else{
        [self.genreIdSelected addObject:[self.genreIdList objectAtIndex:indexPath.row]];
    }

    //clear
    for (int i=0; i < [self.genreSelected count]; i++) {
        
        if ([[self.genreSelected objectAtIndex:i] isEqualToString:@""]) {
            [self.genreSelected removeObjectAtIndex:i];
            //break;
        }
    }
    for (int i=0; i < [self.genreIdSelected count]; i++) {
        
        if ([[self.genreIdSelected objectAtIndex:i] isEqualToString:@""]) {
            [self.genreIdSelected removeObjectAtIndex:i];
            //break;
        }
    }
    
    NSLog(@"check genre selected %@, %@",self.genreSelected, self.genreIdSelected);
    
    if ([self.genreIdSelected count] == 0) {
        NSString * description = [NSString stringWithFormat:NSLocalizedString(@"Please select at least one genre", nil)];
        alert = [UIAlertController alertControllerWithTitle:@""
                                                    message:description
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       
                                                       
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        [self.genreIdSelected addObject:itemId];
        [self.genreSelected addObject:item];
    }
    [tableView reloadData];

}

- (IBAction)submitButtonPressed:(id)sender
{
    //clear
    for (int i=0; i < [self.genreSelected count]; i++) {
        
        if ([[self.genreSelected objectAtIndex:i] isEqualToString:@""]) {
            [self.genreSelected removeObjectAtIndex:i];
            //break;
        }
    }
    NSLog(@"genreSelected %lu",(unsigned long)[self.genreSelected count]);
    if ([self.genreSelected count] == 0) {
        NSString * description = [NSString stringWithFormat:NSLocalizedString(@"Please select at least one genre", nil)];
        alert = [UIAlertController alertControllerWithTitle:@""
                                                    message:description
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       
                                                       
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        [alert addAction:ok];
        //[alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        NSLog(@"not zero");
        self.youtube = [[Youtube alloc] init];
        NSString *genreSelectedString = @"";
         NSString *genreIdSelectedString = @"";
        for(int i = 0 ; i < [self.genreSelected count] ; i++){
            genreSelectedString = [NSString stringWithFormat:@"%@ %@", genreSelectedString, [self.genreSelected objectAtIndex:i]];
            genreIdSelectedString = [NSString stringWithFormat:@"%@ %@", genreIdSelectedString, [self.genreIdSelected objectAtIndex:i]];

        }
        genreSelectedString = [genreSelectedString stringByReplacingOccurrencesOfString:@" " withString:@"|"];
        genreIdSelectedString = [genreIdSelectedString stringByReplacingOccurrencesOfString:@" " withString:@"|"];

        [[NSUserDefaults standardUserDefaults] setObject:genreSelectedString forKey:@"genreSelectedString"];
        [[NSUserDefaults standardUserDefaults] setObject:genreIdSelectedString forKey:@"genreIdSelectedString"];
        
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
    }
   
    //[self performSegueWithIdentifier:@"SubmitSetting" sender:nil];
    
    
}

- (void)receivedLoadVideoId
{
    NSLog(@"receive load video");
    MainTabBarViewController *tabbar = (MainTabBarViewController *)self.tabBarController;
    [tabbar.recommendYoutube.titleList removeAllObjects];
    [tabbar.recommendYoutube.videoIdList removeAllObjects];
    [tabbar.recommendYoutube.thumbnailList removeAllObjects];
    [tabbar.recommendYoutube.durationList removeAllObjects];
    [tabbar.recommendYoutube changeIndexNextPage:0];
    NSLog(@"before adding to recommennd %lu",(unsigned long)[self.youtube.titleList count]);

    for (int i = 0 ; i < [self.youtube.videoIdList count] ; i++) {
        [tabbar.recommendYoutube.videoIdList addObject:[self.youtube.videoIdList objectAtIndex:i]];
        [tabbar.recommendYoutube.titleList addObject:[self.youtube.titleList objectAtIndex:i]];
        [tabbar.recommendYoutube.thumbnailList addObject:[self.youtube.thumbnailList objectAtIndex:i]];
        [tabbar.recommendYoutube.durationList addObject:[self.youtube.durationList objectAtIndex:i]];

    }
    tabbar.genreSelected = self.genreSelected;
    tabbar.genreIdSelected = self.genreIdSelected;
    NSLog(@"before sending %lu",(unsigned long)[self.youtube.titleList count]);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        NSDictionary *userInfo = @{@"youtubeObj": self.youtube
                                   };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingDidSelected" object:self userInfo:userInfo];
        [self.tabBarController setSelectedIndex:0];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoId" object:nil];
    });
    
    
}

@end
