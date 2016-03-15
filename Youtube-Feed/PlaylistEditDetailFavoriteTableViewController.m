//
//  PlaylistEditDetailFavoriteTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "PlaylistEditDetailFavoriteTableViewController.h"
#import "FavoriteCustomCell.h"

@interface PlaylistEditDetailFavoriteTableViewController ()

@end

@implementation PlaylistEditDetailFavoriteTableViewController
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"reload table view");
    [self.tableView reloadData];
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
    return [self.favorite.videoId count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"FavoriteCustomCell";
    FavoriteCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FavoriteCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.name.text = [self.favorite.videoTitle objectAtIndex:indexPath.row];
    cell.favoriteIcon.hidden = YES;
    cell.tag = indexPath.row;
    cell.thumnail.image = nil;
    
    if([self.favorite.videothumbnail objectAtIndex:indexPath.row] != nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.favorite.videothumbnail objectAtIndex:indexPath.row]]];
            
            if(data){
                [self.imageData addObject:data];
                UIImage* image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(cell.tag == indexPath.row){
                            cell.thumnail.image = image;
                            [cell setNeedsLayout];
                        }
                    });
                }
            }
        });
    }
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    alert = [UIAlertController alertControllerWithTitle:@"Adding Video"
                                                message:@"Are you sure to adding this video to playlist"
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
                                                   
                                                   [self saveVideotoPlaylist:indexPath.row];
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                               }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"CANCEL"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
                                                   
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

}


- (void)saveVideotoPlaylist:(NSInteger )index
{
    NSString *videoId = [self.favorite.videoId objectAtIndex:index];
    NSString *videoTitle = [self.favorite.videoTitle objectAtIndex:index];
    NSString *videoThumbnail = [self.favorite.videothumbnail objectAtIndex:index];
    
    [self.playlist addPlaylistWithTitle:videoTitle thumbnail:videoThumbnail andVideoId:videoId];
    [self.delegate addingVideoFromPlayListEditDetailFavorite:self.playlist];
    
    NSLog(@"ADDING VIDEO");
}

@end
