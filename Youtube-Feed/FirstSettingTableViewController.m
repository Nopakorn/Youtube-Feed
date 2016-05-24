//
//  FirstSettingTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/9/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "FirstSettingTableViewController.h"
#import "SettingCustomCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface FirstSettingTableViewController ()

@end

@implementation FirstSettingTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.youtube = [[Youtube alloc] init];
    
    self.genreSelected = [[NSMutableArray alloc] initWithCapacity:10];
    self.genreIdSelected = [[NSMutableArray alloc] initWithCapacity:10];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.submitButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Save", nil)] forState:UIControlStateNormal];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Initial Setting", nil)];
    //self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Initial Setting", nil)];
    
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 5)];
    navBorder.tag = 99;
    [navBorder setBackgroundColor:UIColorFromRGB(0x4F6366)];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x4F6366);
    
    [self.genreIdSelected addObject:[self.genreIdList objectAtIndex:0]];
    [self.genreSelected addObject:[self.genreList objectAtIndex:0]];
}

- (void)viewDidAppear:(BOOL)animated
{
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 5)];
    navBorder.tag = 99;
    [navBorder setBackgroundColor:UIColorFromRGB(0x4F6366)];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if (subView.tag == 99) {
            [subView removeFromSuperview];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
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
    
}



- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)createGerne
{
    self.genreList = [[NSMutableArray alloc] initWithObjects:@"Pop", @"Rock", @"Alternative Rock", @"Classical", @"Country", @"Dance", @"Folk", @"Indie", @"Jazz", @"Hip-hop", nil];
    //add initial genre
    [self.genreSelected addObject:[self.genreList objectAtIndex:0]];
    
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
        //[alert addAction:cancel];
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

        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
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
        [self.delegate firstSettingTableViewControllerDidSelected:self];
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
    
}

@end
