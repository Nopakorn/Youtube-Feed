//
//  PlaylistEditDetailTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "PlaylistEditDetailTableViewController.h"
#import "PlaylistEditDetailFavoriteTableViewController.h"
#import "PlaylistCustomCell.h"
#import "PlaylistEditDetailCustomCell.h"

@interface PlaylistEditDetailTableViewController ()

@end

@implementation PlaylistEditDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setEditing:YES animated:YES];
    self.tableView.allowsSelectionDuringEditing = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view did appear playlisteditdetail");
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
     NSLog(@"view did Disappear playlisteditdetail");
//    for (int i =0 ; i < [self.playlist.videoTitle count]; i++) {
//        NSLog(@"reordering %@",[self.playlist.videoTitle objectAtIndex:i]);
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //plus 1 for header title playlist name
    return [self.playlist.videoId count]+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"PlaylistEditDetailCustomCell";
    PlaylistEditDetailCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaylistEditDetailCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    if (indexPath.row == 0) {
        cell.name.text = self.playlist.playTitle;
        
        
    }else {
        cell.name.text = [self.playlist.videoTitle objectAtIndex:indexPath.row-1];
        cell.addIcon.hidden = YES;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        [self performSegueWithIdentifier:@"AddPlaylistSegue" sender:nil];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    if ([segue.identifier isEqualToString:@"AddPlaylistSegue"]){
        
        PlaylistEditDetailFavoriteTableViewController *dest = segue.destinationViewController;
        dest.playlist = self.playlist;
        dest.favorite = self.favorite;
        dest.delegate = self;
        
    }
}

# pragma mark - editmode

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString *videoTitleToMove = [self.playlist.videoTitle objectAtIndex:sourceIndexPath.row-1];
    NSString *videoIdToMove = [self.playlist.videoId objectAtIndex:sourceIndexPath.row-1];
    NSString *videoThumbnailToMove = [self.playlist.videoThumbnail objectAtIndex:sourceIndexPath.row-1];
    
    [self.playlist.videoId removeObjectAtIndex:sourceIndexPath.row-1];
    [self.playlist.videoTitle removeObjectAtIndex:sourceIndexPath.row-1];
    [self.playlist.videoThumbnail removeObjectAtIndex:sourceIndexPath.row-1];
    
    [self.playlist.videoId insertObject:videoIdToMove atIndex:destinationIndexPath.row-1];
    [self.playlist.videoTitle insertObject:videoTitleToMove atIndex:destinationIndexPath.row-1];
    [self.playlist.videoThumbnail insertObject:videoThumbnailToMove atIndex:destinationIndexPath.row-1];
    
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    
    if( proposedDestinationIndexPath.row == 0 ) {
        return [NSIndexPath indexPathForRow:sourceIndexPath.row inSection:proposedDestinationIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}

#pragma mark - delegate PlaylistEditDetailFavoriteController

- (void)addingVideoFromPlayListEditDetailFavorite:(Playlist *)playlist
{
   
    //self.playlist = playlist;
    NSLog(@"Receive from delegate playlisteditdetailfavorite");
    
}

@end
