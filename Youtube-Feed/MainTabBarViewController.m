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

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view did Load Tabbar");
}

- (void)viewDidAppear:(BOOL)animated
{
    self.passValue = @"test";
     NSLog(@"view did appear Tabbar %lu",(unsigned long)[self.youtube.videoIdList count]);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
