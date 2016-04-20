//
//  PlaylistDetailTableViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "Youtube.h"
#import "YoutubeVideo.h"

#import <UIEMultiAccess/UIEMultiAccess.h>

@interface PlaylistDetailTableViewController : UITableViewController

@property (strong, nonatomic) Youtube *youtube;
@property (strong, nonatomic) Playlist *playlist;
@property (strong, nonatomic) YoutubeVideo *youtubeVideo;
@property (strong, nonatomic) NSArray *youtubeVideoList;
@property (nonatomic, retain) NSString *playlistTitleCheck;
@property (nonatomic, retain) NSMutableArray  *imageData;

@property (nonatomic) BOOL playlistDetailPlaying;
@property (nonatomic) NSInteger selectedRow;

@end

