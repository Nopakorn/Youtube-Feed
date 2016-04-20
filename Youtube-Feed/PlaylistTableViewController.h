//
//  PlaylistTableViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "Favorite.h"
#import "Youtube.h"

#import <UIEMultiAccess/UIEMultiAccess.h>

@interface PlaylistTableViewController : UITableViewController <UIAlertViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>
{
    UIAlertController *alert;
}

@property (weak, nonatomic) IBOutlet UIImageView *playlistsIconTitle;
@property (weak, nonatomic) IBOutlet UILabel *playlistTitle;
@property (strong, nonatomic) Playlist *playlist;
@property (strong, nonatomic) Favorite *favorite;

@property (nonatomic) NSInteger selectedRow;
@property (nonatomic) BOOL favoritePlaying;
@property (nonatomic) BOOL playlistDetailPlaying;
@property (nonatomic, retain) NSString *playlistTitleCheck;

@property(strong, nonatomic) Youtube *youtube;
@property (nonatomic, retain) NSMutableArray *playlist_List;

@property(weak,nonatomic) IBOutlet UIButton  *editButton;
- (IBAction)editButtonPressed:(id)sender;


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
