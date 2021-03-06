//
//  GenreTableViewController.h
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 3/22/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Youtube.h"
#import <UIEMultiAccess/UIEMultiAccess.h>
#import "Reachability.h"

@class Reachability;
@interface GenreTableViewController : UITableViewController
{
    UIAlertController *alert;
    Reachability *internetReachable;
    Reachability *hostReachable;
}

@property (weak, nonatomic) IBOutlet UIImageView *genreIconTitle;
@property (strong, nonatomic) Youtube *genreYoutube;
@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic, copy) NSString *genreTitle;

@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) BOOL genreListPlaying;
@property (nonatomic, copy) NSString *genreType;

@property (nonatomic, retain) NSMutableArray *genreList;
@property (nonatomic, retain) NSMutableArray *genreIdList;

@end
