//
//  RecommendTableViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/11/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"
#import "Reachability.h"

#import <UIEMultiAccess/UIEMultiAccess.h>


@protocol RecommendTableViewControllerDelegate;
@class Reachability;

@interface RecommendTableViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>
{
    //id<RecommendTableViewControllerDelegate> delegate;
    //NSInteger selectedRow;    
    UIActivityIndicatorView *spinner;
    Reachability *internetReachable;
    Reachability *hostReachable;
}

@property (weak, nonatomic) IBOutlet UIImageView *recommendedIconTitle;
@property (weak, nonatomic) IBOutlet UILabel *recommendedTitle;

@property (strong, nonatomic) Youtube *youtube;
@property (strong, nonatomic) Youtube *recommendYoutube;
@property (nonatomic, retain) NSMutableArray *videoTitle;
@property (nonatomic, retain) NSMutableArray *videothumbnail;
@property (nonatomic, retain) NSMutableArray *videoId;
@property (nonatomic, retain) NSMutableArray *imageData;
@property (nonatomic, retain) NSMutableArray *genreSelected;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@property (nonatomic, assign) id<RecommendTableViewControllerDelegate> delegate;
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic) BOOL recommendPlaying;
@end

@protocol RecommendTableViewControllerDelegate <NSObject>

- (void)recommendTableViewControllerDidSelected:(RecommendTableViewController *)recommendViewController;
- (void)recommendTableViewControllerNextPage:(RecommendTableViewController *)recommendViewController;

@end