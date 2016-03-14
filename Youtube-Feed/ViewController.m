//
//  ViewController.m
//  Youtube-Feed
//
//  Created by guild on 2/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "ViewController.h"
#import "MainTabBarViewController.h"
#import "PlaylistTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    Boolean flag;
    NSInteger item;
    NSInteger queryIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    item = 0;
    queryIndex = -1;
    flag = false;
    
    self.youtube = [[Youtube alloc] init];
    self.favorite = [[Favorite alloc] init];
    self.playlist = [[Playlist alloc] init];
    
    MainTabBarViewController *tabbar = (MainTabBarViewController *)self.tabBarController;
    self.youtube = tabbar.youtube;
    
    if([tabbar.youtube.videoIdList count] == 0){
        NSLog(@"object is nil");
    }
    
    [self.navigationController setNavigationBarHidden:YES];
    self.playerView.delegate = self;
    NSDictionary *playerVers = @{
                                 @"playsinline" : @1,
                                 @"controls" : @1,
                                 @"showinfo" : @1,
                                 @"modestbranding" : @1,
    };
    
    [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPlayBackStartedNotification:)
                                                 name:@"Playback started" object:nil];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"calling view didappear");
    [super viewDidAppear:animated];
    
    if(flag){
        NSDictionary *playerVers = @{
                                     @"playsinline" : @1,
                                     @"controls" : @1,
                                     @"showinfo" : @1,
                                     @"modestbranding" : @1,
                                     };
        
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
        flag = false;
    }
    
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    [self.playerView playVideo];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    if(state == kYTPlayerStateEnded){
        NSLog(@"Ended video");
        item+=1;
        [self.playerView pauseVideo];
        NSDictionary *playerVers = @{
                                     @"playsinline" : @1,
                                     @"controls" : @0,
                                     @"showinfo" : @1,
                                     @"modestbranding" : @1,
                                     @"autoplay" : @0
                                     };
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];

    }else if(state == kYTPlayerErrorVideoNotFound){
        
        NSLog(@"Video not found : %@", [self.youtube.videoIdList objectAtIndex:item]);
        
    }else if(state == kYTPlayerStateUnstarted){
        
        NSLog(@"Video unstarted : %@", [self.youtube.videoIdList objectAtIndex:item]);
        item+=1;
        [self.playerView pauseVideo];
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

- (void)buttonPressed:(id)sender
{
    if(sender == self.playButton){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback Started" object:self];
        [self.playerView playVideo];
        
    } else if(sender == self.pauseButton){
        
        [self.playerView pauseVideo];
        
    } else if(sender == self.nextButton){
        item+=1;
        [self.playerView pauseVideo];
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

- (void)favoritePressed:(id)sender
{
    if (queryIndex != item) {
        queryIndex = item;
        NSLog(@"playlist item %lu", (unsigned long)item);
        NSString *videoId = [self.youtube.videoIdList objectAtIndex:queryIndex];
        NSString *videoTitle = [self.youtube.titleList objectAtIndex:queryIndex];
        NSString *videoThumbnail = [self.youtube.thumbnailList objectAtIndex:queryIndex];
        
        Favorite *fav = [[Favorite alloc] init];
        [fav setFavoriteWithTitle:videoTitle thumbnail:videoThumbnail andVideoId:videoId];
        [self.playlist.favoriteList addObject:fav];
        NSLog(@"playlist fav size %lu", (unsigned long)[self.playlist.favoriteList  count]);
        
        
    }else {
         NSLog(@"same index item %lu", (unsigned long)item);
    }
    
}

- (void)receivedPlayBackStartedNotification:(NSNotification *) notification {
    if ([notification.name isEqual:@"Playback Started"] && notification.object != self) {
        [self.playerView pauseVideo];
    }

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
         NSLog(@"Select Playlist view tab");
        UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:2];
        //PlaylistTableViewController *playlistView = (PlaylistTableViewController *)viewController;
        PlaylistTableViewController *playlistView = [nav.viewControllers objectAtIndex:0];
        playlistView.playlist = self.playlist;
        playlistView.youtube = self.youtube;
        
    }
    if (tabBarController.selectedIndex == 1) {
        NSLog(@"Select recommend view tab");
        UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:1];
        RecommendTableViewController *rec = [nav.viewControllers objectAtIndex:0];
        rec.delegate = self;
        
    }

    
}

#pragma mark - delegate RecommendTableViewController

- (void)recommendTableViewControllerDidSelected:(RecommendTableViewController *)recommendViewController
{
    flag = true;
    item = recommendViewController.selectedRow;
    NSLog(@"Receive from delegate");
    
}

@end
