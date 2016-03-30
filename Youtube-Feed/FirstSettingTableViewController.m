//
//  FirstSettingTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/9/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "FirstSettingTableViewController.h"
#import "SettingCustomCell.h"


@interface FirstSettingTableViewController ()

@end

@implementation FirstSettingTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.youtube = [[Youtube alloc] init];
    
    self.genreSelected = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self createGerne];

}



- (void)createGerne
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
    [self.delegate firstSettingTableViewControllerDidSelected:self];
    [self dismissViewControllerAnimated:YES completion:Nil];

}






@end
