//
//  YTViewController.h
//  Youtube-Feed
//
//  Created by guild on 3/3/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"
#import "YTPlayerView.h"
#import "ViewController.h"

@interface YTViewController : UIViewController<YTPlayerViewDelegate>

@property(strong, nonatomic) Youtube *youtube;
@property(strong, nonatomic) IBOutlet YTPlayerView *playerView;


@end
