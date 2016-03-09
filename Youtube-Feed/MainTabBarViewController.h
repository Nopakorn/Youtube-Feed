//
//  MainTabBarViewController.h
//  Youtube-Feed
//
//  Created by guild on 3/8/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"


@interface MainTabBarViewController : UITabBarController


@property(strong, nonatomic) Youtube *youtube;
@property (nonatomic, retain) NSString *passValue;

@end
