//
//  ViewController.h
//  Youtube-Feed
//
//  Created by guild on 2/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"
#import "YTPlayerView.h"
#import "YTViewController.h"


@interface ViewController : UIViewController<YTPlayerViewDelegate>

@property(strong, nonatomic) Youtube *youtube;
@property(strong, nonatomic) IBOutlet YTPlayerView *playerView;
@property(weak,nonatomic) IBOutlet UIButton  *playButton;
@property(weak,nonatomic) IBOutlet UIButton  *pauseButton;
@property(weak,nonatomic) IBOutlet UIButton  *nextButton;

- (IBAction)buttonPressed:(id)sender;

@end

