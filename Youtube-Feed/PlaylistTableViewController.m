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
#import "PlaylistDetailTableViewController.h"
#import "PlaylistEditTableViewController.h"

@interface PlaylistTableViewController ()

@end

@implementation PlaylistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playlist_List = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self createPlaylist];
}

- (void)createPlaylist
{
    NSString *title1 = @"Play List 1";
    Playlist *pav1 = [[Playlist alloc] init];
    [pav1 setTitle:title1];
    for (int i = 0; i < 10; i++) {
        [pav1 addPlaylistWithTitle:[self.youtube.titleList objectAtIndex:i] thumbnail:[self.youtube.thumbnailList objectAtIndex:i] andVideoId:[self.youtube.videoIdList objectAtIndex:i]];
    }
    [self.playlist_List addObject:pav1];
    
    NSString *title2 = @"Play List 2";
    Playlist *pav2 = [[Playlist alloc] init];
    [pav2 setTitle:title2];
    for (int i = 10; i < 20; i++) {
        [pav2 addPlaylistWithTitle:[self.youtube.titleList objectAtIndex:i] thumbnail:[self.youtube.thumbnailList objectAtIndex:i] andVideoId:[self.youtube.videoIdList objectAtIndex:i]];
    }
     [self.playlist_List addObject:pav2];
    
    NSString *title3 = @"Play List 3";
    Playlist *pav3 = [[Playlist alloc] init];
    [pav3 setTitle:title3];
    [self.playlist_List addObject:pav3];
    
    NSLog(@"index list %lu",(unsigned long)[self.playlist_List count]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 - (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"inside view will appear");
//    NSLog(@"check size of favorite %lu", (unsigned long)[self.playlist.favoriteList count]);
//    for (int i = 0; i < [self.playlist.favoriteList count]; i++) {
//        Favorite *fav = [self.playlist.favoriteList objectAtIndex:i];
//        NSLog(@"id:%@ title:%@ thumbnail:%@",fav.videoId,fav.videoTitle,fav.videothumbnail);
//    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.playlist_List count] == 0) {
        return 2;
        
    } else {
        //for favorite and . . . row
        return [self.playlist_List count]+2;

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
    
    if ([self.playlist_List count] == 0) {
        if(indexPath.row == 0) {
            cell.name.text = @"Favorite";
        }else {
            cell.name.text = @" . . . . ";
        }

    } else {
        
        if(indexPath.row == 0) {
            cell.name.text = @"Favorite";
            
        }else {
            if (indexPath.row <= [self.playlist_List count]) {
                
                Playlist *playlist = [self.playlist_List objectAtIndex:indexPath.row-1];
                cell.name.text = playlist.playTitle;
                
            }else {
                cell.name.text = @" . . . . ";
            }
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
        
    }else {
        NSLog(@"perfrom playlistdetail");
        self.playlist = [self.playlist_List objectAtIndex:indexPath.row-1];
        [self performSegueWithIdentifier:@"PlaylistDetailSegue" sender:nil];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)editButtonPressed:(id)sender
{
    NSLog(@"Edit buttonPressed");
    //[self performSegueWithIdentifier:@"EditSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FavoriteSegue"]){
        
        FavoriteTableViewController *dest = segue.destinationViewController;
        dest.playlist = self.playlist;
        dest.favorite = self.favorite;
        
    } else if ([segue.identifier isEqualToString:@"PlaylistDetailSegue"]) {
         NSLog(@"prepare playlistdetail");
        PlaylistDetailTableViewController *dest = segue.destinationViewController;
        dest.playlist = self.playlist;
        
    } else if ([segue.identifier isEqualToString:@"EditSegue"]) {
        NSLog(@"prepare playlistEdit");
        PlaylistEditTableViewController *dest = segue.destinationViewController;
        dest.playlist_List = self.playlist_List;
        dest.favorite = self.favorite;
    }
    
}

@end