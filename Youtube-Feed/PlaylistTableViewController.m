//
//  PlaylistTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "PlaylistTableViewController.h"
#import "PlaylistCustomCell.h"
#import "FavoriteTableViewController.h"

@interface PlaylistTableViewController ()

@end

@implementation PlaylistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    NSLog(@"in playlist viewdidload");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 - (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"inside view will appear");
    NSLog(@"check size of favorite %lu", (unsigned long)[self.playlist.favoriteList count]);
    for (int i = 0; i < [self.playlist.favoriteList count]; i++) {
        Favorite *fav = [self.playlist.favoriteList objectAtIndex:i];
        NSLog(@"id:%@ title:%@ thumbnail:%@",fav.videoId,fav.videoTitle,fav.videothumbnail);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.playlist.playlistTitle count] == 0) {
        return 2;
        
    } else {
        return [self.playlist.playlistTitle count];

    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"PlaylistCustomCell";
    PlaylistCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaylistCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    if ([self.playlist.playlistTitle count] == 0) {
        if(indexPath.row == 0) {
            cell.name.text = @"Favorite";
        }else {
            cell.name.text = @" . . . . ";
        }

    } else {
        if(indexPath.row == 0) {
            cell.name.text = @"Favorite";
        }else {
            cell.name.text = [self.playlist.playlistTitle objectAtIndex:indexPath.row];
        }
    }
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 ) {
        [self performSegueWithIdentifier:@"FavoriteSegue" sender:nil];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"FavoriteSegue"]){
        
        FavoriteTableViewController *dest = segue.destinationViewController;
        dest.playlist = self.playlist;
        
    }
    
}

@end
