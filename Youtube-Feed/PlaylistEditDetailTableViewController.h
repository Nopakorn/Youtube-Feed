//
//  PlaylistEditDetailTableViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "Favorite.h"
#import "Youtube.h"
#import "YoutubeVideo.h"
#import "PlaylistEditDetailFavoriteTableViewController.h"

@interface PlaylistEditDetailTableViewController : UITableViewController <PlaylistEditDetailFavoriteControllerDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>
{
    UIAlertController *alert;
}
@property (strong, nonatomic) Playlist *playlist;
@property (strong, nonatomic) Favorite *favorite;
@property (nonatomic, retain) NSMutableArray *youtubeVideoList;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
