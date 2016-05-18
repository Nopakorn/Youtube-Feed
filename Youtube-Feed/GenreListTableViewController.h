//
//  GenreListTableViewController.h
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
@interface GenreListTableViewController : UITableViewController
{
     UIActivityIndicatorView *spinner;
     UIAlertController *alert;
     Reachability *internetReachable;
     Reachability *hostReachable;
}

@property (strong, nonatomic) Youtube *genreYoutube;
@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic, copy) NSString *genreTitle;

@property (nonatomic, retain) NSMutableArray *imageData;

@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic, copy) NSString *genreType;
@property (nonatomic) BOOL genreListPlaying;

@property (weak, nonatomic) IBOutlet UIButton *backGenreButton;
@end
