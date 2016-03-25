//
//  PlaylistEditDetailFavoriteTableViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Favorite.h"
#import "Playlist.h"

@protocol PlaylistEditDetailFavoriteControllerDelegate;

@interface PlaylistEditDetailFavoriteTableViewController : UITableViewController <UIAlertViewDelegate, NSFetchedResultsControllerDelegate>
{
    UIAlertController *alert;
}

@property (strong, nonatomic) Playlist *playlist;
@property (strong, nonatomic) Favorite *favorite;
@property (nonatomic, retain) NSMutableArray  *imageData;

@property (nonatomic, assign) id<PlaylistEditDetailFavoriteControllerDelegate> delegate;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@protocol PlaylistEditDetailFavoriteControllerDelegate <NSObject>

- (void)addingVideoFromPlayListEditDetailFavorite:(Favorite *)favorite;

@end