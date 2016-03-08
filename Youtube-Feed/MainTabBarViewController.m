//
//  MainTabBarViewController.m
//  Youtube-Feed
//
//  Created by guild on 3/8/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
   NSLog(@"view did Load Tabbar");
}

- (void)viewDidAppear:(BOOL)animated
{
     NSLog(@"view did appear Tabbar");
//    UITabBarController *tab = self.tabBarController;
//    if(tab){
//        NSLog(@"I have a tab bar");
//        [self.tabBarController setSelectedIndex:3];
//    }else{
//        NSLog(@"I dont have");
//        //[(UITabBarController *)self.navigationController.topViewController setSelectedIndex:3];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
