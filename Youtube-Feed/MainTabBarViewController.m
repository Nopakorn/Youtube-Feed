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
@synthesize genreSelected;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view did Load Tabbar");
}

- (void)viewDidAppear:(BOOL)animated
{
    self.passValue = @"test";
    NSLog(@"view did appear Tabbar %lu",(unsigned long)[self.youtube.videoIdList count]);
    NSLog(@"startAT %lu",(unsigned long)self.startAt);
    //NSMutableArray *tabs = [NSMutableArray arrayWithObjects:self.tabBarController.viewControllers, nil];
    //NSMutableArray *tabs = [NSMutableArray arrayWithArray:[self.tabBarController viewControllers]];
    //NSLog(@"tabs length %lu",(unsigned long)[tabs count]);
    //[tabs removeObjectAtIndex:1];
    //[self.tabBarController setViewControllers:tabs];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
