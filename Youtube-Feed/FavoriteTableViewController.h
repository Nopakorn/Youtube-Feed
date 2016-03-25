//
//  FavoriteTableViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "Favorite.h"
#import "Youtube.h"

@interface FavoriteTableViewController : UITableViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate>
{
    UIAlertController *alert;
}

@property (strong, nonatomic) Playlist *playlist;
@property (strong, nonatomic) Favorite *favorite;

@property (nonatomic, retain) NSMutableArray  *imageData;
@property (nonatomic) NSInteger selectedRow;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
