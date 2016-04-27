//
//  SearchTableViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/16/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  "Youtube.h"

#import <UIEMultiAccess/UIEMultiAccess.h>

@protocol SearchTableViewControllerDelegate;

@interface SearchTableViewController : UITableViewController <UITextFieldDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIGestureRecognizerDelegate>
{
    UIActivityIndicatorView *spinner;
}
@property (weak, nonatomic) IBOutlet UIImageView *searchIconTitle;

@property (weak, nonatomic) IBOutlet UILabel *searchTitle;
@property (strong, nonatomic) Youtube *youtube;
@property (strong, nonatomic) Youtube *searchYoutube;
@property (nonatomic, retain) NSMutableArray  *imageData;
@property (nonatomic, retain) IBOutlet UISearchBar  *searchBar;
@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic) BOOL searchPlaying;

@property (nonatomic, assign) id<SearchTableViewControllerDelegate> delegate;
@property (nonatomic) NSInteger selectedRow;
@end

@protocol SearchTableViewControllerDelegate <NSObject>

- (void)searchTableViewControllerDidSelected:(SearchTableViewController *)searchViewController;

@end