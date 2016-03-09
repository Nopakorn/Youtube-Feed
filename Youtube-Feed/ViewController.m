//
//  ViewController.m
//  Youtube-Feed
//
//  Created by guild on 2/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    Boolean flag;
    int item;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    item = 0;
    self.youtube = [[Youtube alloc] init];
    //self.youtube.videoIdList = [[NSMutableArray alloc] initWithCapacity:10];
    [self.youtube.videoIdList  addObject:@"kBgkcuJ12k8"];
    [self.youtube.videoIdList  addObject:@"OHXjxWaQs9o"];
    [self.youtube.videoIdList  addObject:@"f_h7o4yLldY"];
    [self.youtube.videoIdList  addObject:@"OHXjxWaQs9o"];
    
    //NSLog(@"object %@",[self.youtube.videoIdList objectAtIndex:0]);
    //[self.youtube callSearch];
    //[self getVideoId];
    [self.navigationController setNavigationBarHidden:YES];
    self.playerView.delegate = self;
    NSDictionary *playerVers = @{
                                 @"playsinline" : @1,
                                 @"controls" : @1,
                                 @"showinfo" : @1,
                                 @"modestbranding" : @1,
    };
    
    [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:0] playerVars:playerVers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPlayBackStartedNotification:)
                                                 name:@"Playback started" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getVideoId)
                                                 name:@"LoadVideoId" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"calling view didappear");
    [super viewDidAppear:animated];
    
}

- (void)getVideoId
{
    NSLog(@"wait notification");
    [self videoView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([[segue identifier]isEqualToString:@"PlayYoutube" ])
    {
        NSLog(@"in prepare");
        YTViewController *dest = [segue destinationViewController];
        dest.youtube = self.youtube;
        
    }
}



- (void)videoView
{
    //[self performSegueWithIdentifier:@"PlayYoutube" sender:self];
    NSLog(@"loading player view from %lu",(unsigned long)[self.youtube.videoIdList count]);
//    NSDictionary *playerVers = @{
//                                 @"playsinline" : @1,
//                                 @"controls" : @1,
//                                 @"showinfo" : @1,
//                                 @"modestbranding" : @1,
//                                 };
//    
//    [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:10] playerVars:playerVers];
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
        //[self videoView];
    }
}

- (void)receivedPlayBackStartedNotification:(NSNotification *) notification {
    if ([notification.name isEqual:@"Playback Started"] && notification.object != self) {
        [self.playerView pauseVideo];
    }

}

@end
