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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
