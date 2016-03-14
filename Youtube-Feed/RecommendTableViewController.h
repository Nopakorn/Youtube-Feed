//
//  RecommendTableViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/11/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"

@protocol RecommendTableViewControllerDelegate;

@interface RecommendTableViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>
{
    id<RecommendTableViewControllerDelegate> delegate;
    NSInteger selectedIndex;

}

@property (strong, nonatomic) Youtube *youtube;
@property (nonatomic, retain) NSMutableArray  *videoTitle;
@property (nonatomic, retain) NSMutableArray  *videothumbnail;
@property (nonatomic, retain) NSMutableArray  *videoId;
@property (nonatomic, retain) NSMutableArray  *imageData;
@property (nonatomic) NSInteger selectedRow;

@end

@protocol RecommendTableViewControllerDelegate

- (void)recommendTableViewControllerDidSelected:(RecommendTableViewController *)recommendViewController;

@end