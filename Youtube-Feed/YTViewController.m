//
//  YTViewController.m
//  Youtube-Feed
//
//  Created by guild on 3/3/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "YTViewController.h"

@interface YTViewController ()

@end

@implementation YTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //[self.playerView loadWithVideoId:videoId];
    //[self.playerView loadWithVideoId:@"odBhPKeZuf8"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"calling view didappear");
    [super viewDidAppear:animated];
    
    NSString *videoId = [self.youtube.videoIdList objectAtIndex:2];
    NSLog(@"get video Id: %@",videoId);
    [self.playerView loadWithVideoId:videoId];
}



@end
