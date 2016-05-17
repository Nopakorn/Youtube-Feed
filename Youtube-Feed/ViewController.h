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
#import "PlaylistTableViewController.h"
#import "RecommendTableViewController.h"
#import "SearchTableViewController.h"
#import <UIEMultiAccess/UIEMultiAccess.h>

#import <MediaPlayer/MediaPlayer.h>
#import "Reachability.h"
@class Reachability;

@interface ViewController : UIViewController <YTPlayerViewDelegate, RecommendTableViewControllerDelegate, UITabBarControllerDelegate, UIAlertViewDelegate, SearchTableViewControllerDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UMAFocusManagerDelegate>
{
    UIAlertController *favoriteAlert;
    NSTimer *favoriteAlertTimer;
    UIAlertController *outOflengthAlert;
    NSTimer *outOflengthAlertTimer;
    NSTimer *hideNavigation;
    BOOL shouldHideStatusBar;
    UIAlertController *alert;
    
    Reachability *internetReachable;
    Reachability *hostReachable;
}
@property (nonatomic) UMAApplication *umaApp;
@property (nonatomic, strong) UMAFocusManager *focusManager;

@property (strong, nonatomic) Youtube *youtube;
@property (strong, nonatomic) Youtube *youtubeUpdate;

@property (strong, nonatomic) Favorite *favorite;
@property (strong, nonatomic) Playlist *playlist;

@property (nonatomic, retain) NSMutableArray *genreSelected;

@property (strong, nonatomic) IBOutlet YTPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIButton  *playButton;
@property (weak, nonatomic) IBOutlet UIButton  *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton  *nextButton;
@property (weak, nonatomic) IBOutlet UIButton  *prevButton;
@property (weak, nonatomic) IBOutlet UIButton  *addButton;
@property (weak, nonatomic) IBOutlet UIButton  *favoriteButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightPlayerViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacingPlayerViewConstraint;

@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UILabel *currentTimePlay;

@property (weak, nonatomic) IBOutlet UISlider *ProgressSlider;

@property (strong, nonatomic) NSTimer *timerProgress;
@property (nonatomic) NSTimeInterval playerTotalTime;

@property (nonatomic, retain) NSMutableArray  *favoriteList;
@property (nonatomic, retain) NSArray  *resultFovorite;
@property (nonatomic, retain) NSDictionary *playerVers;

- (IBAction)buttonPressed:(id)sender;
- (IBAction)favoritePressed:(id)sender;

- (IBAction)sliderValueChanged:(id)sender;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalTimeWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentTimeWidthConstraint;

@property (strong, nonatomic) IBOutlet UIView *containerView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerViewTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerViewBottomConstraint;
@end

