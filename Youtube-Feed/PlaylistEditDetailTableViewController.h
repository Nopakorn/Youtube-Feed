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

@interface PlaylistEditDetailTableViewController : UITableViewController

@property (strong, nonatomic) Playlist *playlist;

@end
