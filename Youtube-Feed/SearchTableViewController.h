//
//  SearchTableViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/16/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  "Youtube.h"

@interface SearchTableViewController : UITableViewController <UITextFieldDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIGestureRecognizerDelegate>
{
    UIActivityIndicatorView *spinner;
}

@property (strong, nonatomic) Youtube *youtube;
@property (nonatomic, retain) NSMutableArray  *imageData;
@property (nonatomic, retain) IBOutlet UISearchBar  *searchBar;

@end
