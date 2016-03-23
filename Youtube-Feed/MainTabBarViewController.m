//
//  MainTabBarViewController.m
//  Youtube-Feed
//
//  Created by guild on 3/8/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "ViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController
@synthesize youtube;
@synthesize recommendYoutube;
@synthesize searchYoutube;
@synthesize genreSelected;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view did Load Tabbar");
    self.customizableViewControllers = nil;
    UITableView *view = (UITableView *)self.moreNavigationController.topViewController.view;
    view.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidAppear:(BOOL)animated
{
    //self.passValue = @"test";

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveYoutubeObj:(Youtube *)yt
{
    if(yt.videoIdList != 0) {
        for (int i = 0; i < [yt.videoIdList count]; i++) {
            [self.youtube.videoIdList addObject:[yt.videoIdList objectAtIndex:i]];
            [self.youtube.titleList addObject:[yt.titleList objectAtIndex:i]];
            [self.youtube.thumbnailList addObject:[yt.thumbnailList objectAtIndex:i]];
        }
        
    }
}

@end
