//
//  PlaylistDetailTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "PlaylistDetailTableViewController.h"
#import "RecommendCustomCell.h"
#import "MainTabBarViewController.h"

@interface PlaylistDetailTableViewController ()

@end

@implementation PlaylistDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addingDataToYoutubeObject];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)addingDataToYoutubeObject
{
    self.youtube = [[Youtube alloc] init];
    if(self.playlist.videoIdList != 0) {
        NSLog(@"save to youtube obj");
        for (int i = 0; i < [self.playlist.videoIdList count]; i++) {
            [self.youtube.videoIdList addObject:[self.playlist.videoIdList objectAtIndex:i]];
            [self.youtube.titleList addObject:[self.playlist.videoTitleList objectAtIndex:i]];
            [self.youtube.thumbnailList addObject:[self.playlist.videoThumbnail objectAtIndex:i]];
        }
    }else {
        NSLog(@"Have no video in the playlist");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
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
    return [self.playlist.videoIdList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"RecommendCustomCell";
    RecommendCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecommendCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.name.text = [self.playlist.videoTitleList objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
    cell.thumnail.image = nil;
    
    if([self.playlist.videoThumbnail objectAtIndex:indexPath.row] != [NSNull null]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.playlist.videoThumbnail objectAtIndex:indexPath.row]]];
            
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
    self.selectedRow = indexPath.row;
    NSString *selected = [NSString stringWithFormat:@"%lu",self.selectedRow];
    NSDictionary *userInfo = @{@"youtubeObj": self.youtube,
                               @"selectedIndex": selected};
     NSLog(@"post playlistdetail");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaylistDetailDidSelected" object:self userInfo:userInfo];
    [self.tabBarController setSelectedIndex:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
