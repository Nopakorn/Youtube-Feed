//
//  SettingTableViewController.h
//  Youtube-Feed
//
//  Created by guild on 3/8/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"
#import "Genre.h"
#import "Reachability.h"

@class Reachability;
@interface SettingTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate>
{
    NSInteger selectedRow;
    UIAlertController *alert;
    Reachability *internetReachable;
    Reachability *hostReachable;
}

@property (strong, nonatomic) Youtube *youtube;
@property (strong, nonatomic) Genre *genre;
@property (nonatomic, retain) NSMutableArray *selectedType;
@property (nonatomic, retain) NSMutableArray *genreList;
@property (nonatomic, retain) NSMutableArray *genreIdList;
@property (nonatomic, retain) NSMutableArray *genreSelected;
@property (nonatomic, retain) NSMutableArray *genreIdSelected;

@property(weak,nonatomic) IBOutlet UIButton  *submitButton;

- (IBAction)submitButtonPressed:(id)sender;
@end
