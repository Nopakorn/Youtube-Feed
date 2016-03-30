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
//    if(self.playlist.videoIdList != 0) {
//        NSLog(@"save to youtube obj");
//        for (int i = 0; i < [self.playlist.videoIdList count]; i++) {
//            [self.youtube.videoIdList addObject:[self.playlist.videoIdList objectAtIndex:i]];
//            [self.youtube.titleList addObject:[self.playlist.videoTitleList objectAtIndex:i]];
//            [self.youtube.thumbnailList addObject:[self.playlist.videoThumbnail objectAtIndex:i]];
//        }
//    }else {
//        NSLog(@"Have no video in the playlist");
//    }
    for (int i = 0; i < [self.youtubeVideoList count]; i++) {
        YoutubeVideo *youtubeVideo = [self.youtubeVideoList objectAtIndex:i];
        [self.youtube.videoIdList addObject:youtubeVideo.videoId];
        [self.youtube.titleList addObject:youtubeVideo.videoTitle];
        [self.youtube.thumbnailList addObject:youtubeVideo.videoThumbnail];
        [self.youtube.durationList addObject:youtubeVideo.videoDuration];
    }
}

- (NSArray *)youtubeVideoList
{
    if (_youtubeVideoList == nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        _youtubeVideoList = [self.playlist.youtubeVideos.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
        return _youtubeVideoList;
    } else {
        return _youtubeVideoList;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = self.playlist.title;
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
    //return [self.playlist.videoIdList count];
    return [self.youtubeVideoList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"RecommendCustomCell";
    RecommendCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecommendCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    YoutubeVideo *youtubeVideoForRow = [self.youtubeVideoList objectAtIndex:indexPath.row];
    cell.name.text = youtubeVideoForRow.videoTitle;
    cell.durationLabel.text = [self durationText:youtubeVideoForRow.videoDuration];
    cell.tag = indexPath.row;
    cell.thumnail.image = nil;
    
    if(youtubeVideoForRow.videoThumbnail != nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:youtubeVideoForRow.videoThumbnail]];
            
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
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;
    NSString *selected = [NSString stringWithFormat:@"%lu",self.selectedRow];
    [self addingDataToYoutubeObject];
    NSDictionary *userInfo = @{@"youtubeObj": self.youtube,
                               @"selectedIndex": selected};
     NSLog(@"post playlistdetail");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaylistDetailDidSelected" object:self userInfo:userInfo];
    [self.tabBarController setSelectedIndex:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)durationText:(NSString *)duration
{
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    duration = [duration substringFromIndex:[duration rangeOfString:@"T"].location];
    
    while ([duration length] > 1) { //only one letter remains after parsing
        duration = [duration substringFromIndex:1];
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:duration];
        
        NSString *durationPart = [[NSString alloc] init];
        [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] intoString:&durationPart];
        
        NSRange rangeOfDurationPart = [duration rangeOfString:durationPart];
        
        duration = [duration substringFromIndex:rangeOfDurationPart.location + rangeOfDurationPart.length];
        
        if ([[duration substringToIndex:1] isEqualToString:@"H"]) {
            hours = [durationPart intValue];
            
        }
        if ([[duration substringToIndex:1] isEqualToString:@"M"]) {
            minutes = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"S"]) {
            seconds = [durationPart intValue];
        }
    }
    if (hours != 0) {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
}

@end
