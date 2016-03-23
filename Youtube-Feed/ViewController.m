//
//  ViewController.m
//  Youtube-Feed
//
//  Created by guild on 2/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "ViewController.h"
#import "MainTabBarViewController.h"


@interface ViewController ()

@end

@implementation ViewController
{
    Boolean recommendTableViewFlag;
    Boolean searchTableViewFlag;
    Boolean playlistDetailTableViewFlag;
    Boolean genreListTableViewFlag;
    BOOL outOfLengthAlert;
    NSInteger item;
    NSInteger queryIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;
    
    item = 0;
    queryIndex = -1;
    recommendTableViewFlag = false;
    searchTableViewFlag = false;
    playlistDetailTableViewFlag = false;
    genreListTableViewFlag = false;
    outOfLengthAlert = true;
    
    self.youtube = [[Youtube alloc] init];
    self.favorite = [[Favorite alloc] init];
    self.playlist = [[Playlist alloc] init];
    //play recommend video first time
    MainTabBarViewController *tabbar = (MainTabBarViewController *)self.tabBarController;
    self.youtube = tabbar.youtube;
    
    if([tabbar.youtube.videoIdList count] == 0){
        NSLog(@"object is nil");
    }
    
    //[self.navigationController setNavigationBarHidden:NO];
    self.playerView.delegate = self;
    NSDictionary *playerVers = @{
                                 @"playsinline" : @1,
                                 @"controls" : @0,
                                 @"showinfo" : @1,
                                 @"modestbranding" : @1,
    };
    
    [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPlayBackStartedNotification:)
                                                 name:@"Playback started" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPlaylistDetailNotification:)
                                                 name:@"PlaylistDetailDidSelected" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedGenreListNotification:)
                                                 name:@"PlayGenreListDidSelected" object:nil];
    
    self.addButton.hidden = YES;
    NSLog(@"View did load in youtube %@",[tabbar.recommendYoutube.titleList objectAtIndex:1]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    NSLog(@"View did appear in youtube");
    if (recommendTableViewFlag) {
        NSDictionary *playerVers = @{
                                     @"playsinline" : @1,
                                     @"controls" : @0,
                                     @"showinfo" : @1,
                                     @"modestbranding" : @1,
                                     };
        
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
        recommendTableViewFlag = false;
    }
    
    if (searchTableViewFlag) {
        NSDictionary *playerVers = @{
                                     @"playsinline" : @1,
                                     @"controls" : @0,
                                     @"showinfo" : @1,
                                     @"modestbranding" : @1,
                                     };
        
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
        searchTableViewFlag = false;
    }
    
    if (playlistDetailTableViewFlag) {
        NSDictionary *playerVers = @{
                                     @"playsinline" : @1,
                                     @"controls" : @0,
                                     @"showinfo" : @1,
                                     @"modestbranding" : @1,
                                     };
        
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
        playlistDetailTableViewFlag = false;
    }

    if (genreListTableViewFlag) {
        NSDictionary *playerVers = @{
                                     @"playsinline" : @1,
                                     @"controls" : @0,
                                     @"showinfo" : @1,
                                     @"modestbranding" : @1,
                                     };
        
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
        genreListTableViewFlag = false;

    }
    
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    [self.playerView playVideo];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    if (state == kYTPlayerStateEnded) {
        NSLog(@"Ended video");
        item+=1;
        [self.playerView pauseVideo];
        if(item == [self.youtube.videoIdList count]){
            NSLog(@"Out of length");
            outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
            outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
            [self presentViewController:outOflengthAlert animated:YES completion:nil];
            
        }else {
            NSDictionary *playerVers = @{
                                         @"playsinline" : @1,
                                         @"controls" : @0,
                                         @"showinfo" : @1,
                                         @"modestbranding" : @1,
                                         @"autoplay" : @0
                                         };
            [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
            
        }
        
    }else if (state == kYTPlayerErrorVideoNotFound) {
        
        NSLog(@"Video not found : %@", [self.youtube.videoIdList objectAtIndex:item]);
        
    }else if (state == kYTPlayerStateUnstarted) {
        
        NSLog(@"Video unstarted : %@", [self.youtube.videoIdList objectAtIndex:item]);
        item+=1;
        [self.playerView pauseVideo];
        if(item == [self.youtube.videoIdList count]) {
            
             NSLog(@"Out of length");
            outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
            outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
            [self presentViewController:outOflengthAlert animated:YES completion:nil];
             item-=1;
        }else {
            NSDictionary *playerVers = @{
                                         @"playsinline" : @1,
                                         @"controls" : @0,
                                         @"showinfo" : @1,
                                         @"modestbranding" : @1,
                                         @"autoplay" : @0
                                         };
            [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
            
        }

    }
}

- (void)buttonPressed:(id)sender
{
    if (sender == self.playButton) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback Started" object:self];
        [self.playerView playVideo];
        
    } else if (sender == self.pauseButton) {
        
        [self.playerView pauseVideo];
        
    } else if (sender == self.nextButton) {
        
        item+=1;
        [self.playerView pauseVideo];
        if (outOfLengthAlert) {
            
            if (item == [self.youtube.videoIdList count]) {
                NSLog(@"Out of length");
                outOfLengthAlert = false;
                outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
                outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
                [self presentViewController:outOflengthAlert animated:YES completion:nil];
                item-=1;
            }else {
                NSDictionary *playerVers = @{
                                             @"playsinline" : @1,
                                             @"controls" : @0,
                                             @"showinfo" : @1,
                                             @"modestbranding" : @1,
                                             @"autoplay" : @0
                                             };
                [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
                
            }

        }
        
    } else if (sender == self.prevButton) {
        
        item-=1;
        [self.playerView pauseVideo];
        if (outOfLengthAlert) {
            if (item < 0) {
                NSLog(@"Out of length");
                outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
                outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
                [self presentViewController:outOflengthAlert animated:YES completion:nil];
                item+=1;
            } else {
                NSDictionary *playerVers = @{
                                             @"playsinline" : @1,
                                             @"controls" : @0,
                                             @"showinfo" : @1,
                                             @"modestbranding" : @1,
                                             @"autoplay" : @0
                                             };
                [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
                
            }

        }
    }

}

- (void)favoritePressed:(id)sender
{
    if (queryIndex != item) {
        queryIndex = item;
        
        favoriteAlert = [UIAlertController alertControllerWithTitle:nil message:@"Adding to Favorite" preferredStyle:UIAlertControllerStyleAlert];
        favoriteAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissFavoriteAlert) userInfo:nil repeats:NO];
        [self presentViewController:favoriteAlert animated:YES completion:nil];
        
        NSString *videoId = [self.youtube.videoIdList objectAtIndex:queryIndex];
        NSString *videoTitle = [self.youtube.titleList objectAtIndex:queryIndex];
        NSString *videoThumbnail = [self.youtube.thumbnailList objectAtIndex:queryIndex];
        [self.favorite setFavoriteWithTitle:videoTitle thumbnail:videoThumbnail andVideoId:videoId];
        
    }else {
        
        favoriteAlert = [UIAlertController alertControllerWithTitle:nil message:@"Already in Favorite" preferredStyle:UIAlertControllerStyleAlert];
        favoriteAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissFavoriteAlert) userInfo:nil repeats:NO];
        [self presentViewController:favoriteAlert animated:YES completion:nil];
    }
    
}

- (void)dismissFavoriteAlert
{
    [favoriteAlert dismissViewControllerAnimated:YES completion:nil];
    [favoriteAlertTimer invalidate];
}

- (void)dismissOutOflengthAlert
{
    outOfLengthAlert = true;
    [outOflengthAlert dismissViewControllerAnimated:YES completion:nil];
    [outOflengthAlertTimer invalidate];
}

- (void)receivedPlayBackStartedNotification:(NSNotification *) notification {
    if ([notification.name isEqual:@"Playback Started"] && notification.object != self) {
        NSLog(@"pause video");
        [self.playerView pauseVideo];
    }

}

- (void)receivedPlaylistDetailNotification:(NSNotification *)notification
{
    playlistDetailTableViewFlag = true;
    self.youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    item = [[notification.userInfo objectForKey:@"selectedIndex"] integerValue];
    NSLog(@"Received playlistDetail");
}

- (void)receivedGenreListNotification:(NSNotification *)notification
{
    genreListTableViewFlag = true;
    self.youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    item = [[notification.userInfo objectForKey:@"selectedIndex"] integerValue];
    NSLog(@"Received playGenreList");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *newVC = segue.destinationViewController;
    
    [ViewController setPresentationStyleForSelfController:self presentingController:newVC];
}

+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        //iOS 8.0 and above
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 2) {
    
        UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:2];
        PlaylistTableViewController *playlistView = [nav.viewControllers objectAtIndex:0];
        playlistView.playlist = self.playlist;
        playlistView.favorite = self.favorite;
        playlistView.youtube = self.youtube;
        NSLog(@"select playlist");
    }
    
    if (tabBarController.selectedIndex == 1) {
       
        UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:1];
        RecommendTableViewController *rec = [nav.viewControllers objectAtIndex:0];
        rec.delegate = self;
         NSLog(@"select rocommend");
    }
    
    if (tabBarController.selectedIndex == 3) {
        
        UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:3];
        SearchTableViewController *seachView = [nav.viewControllers objectAtIndex:0];
        seachView.delegate = self;
        NSLog(@"select search");
    }
}

#pragma mark - delegate RecommendTableViewController

- (void)recommendTableViewControllerDidSelected:(RecommendTableViewController *)recommendViewController
{
    recommendTableViewFlag = true;
    self.youtube = recommendViewController.recommendYoutube;
    item = recommendViewController.selectedRow;
    NSLog(@"recommend did selected");
}

- (void)recommendTableViewControllerNextPage:(RecommendTableViewController *)recommendViewController
{
    self.youtube = recommendViewController.recommendYoutube;
    NSLog(@"recommend next page");
}

#pragma mark - delegate SearchTableViewController

- (void)searchTableViewControllerDidSelected:(SearchTableViewController *)searchViewController
{
    searchTableViewFlag = true;
    self.youtube = searchViewController.searchYoutube;
    item = searchViewController.selectedRow;
     NSLog(@"Received Search");
}

@end
