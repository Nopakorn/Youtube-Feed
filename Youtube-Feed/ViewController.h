//
//  ViewController.h
//  Youtube-Feed
//
//  Created by guild on 2/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"
#import "Playlist.h"
#import "Favorite.h"
#import "YTPlayerView.h"
#import "AddPlaylistPopUpViewController.h"
#import "RecommendTableViewController.h"


@interface ViewController : UIViewController <YTPlayerViewDelegate, RecommendTableViewControllerDelegate>

@property(strong, nonatomic) Youtube *youtube;
@property (strong, nonatomic) Favorite *favorite;
@property (strong, nonatomic) Playlist *playlist;

@property(strong, nonatomic) IBOutlet YTPlayerView *playerView;
@property(weak,nonatomic) IBOutlet UIButton  *playButton;
@property(weak,nonatomic) IBOutlet UIButton  *pauseButton;
@property(weak,nonatomic) IBOutlet UIButton  *nextButton;
@property(weak,nonatomic) IBOutlet UIButton  *addButton;
@property(weak,nonatomic) IBOutlet UIButton  *favoriteButton;

- (IBAction)buttonPressed:(id)sender;
- (IBAction)favoritePressed:(id)sender;

@end

