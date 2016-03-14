//
//  Playlist.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Favorite.h"

@interface Playlist : NSObject

@property (strong, nonatomic) Favorite *favorite;
@property (nonatomic, retain) NSMutableArray  *playlistTitle;
@property (nonatomic, retain) NSMutableArray  *favoriteList;

- (void)addFavorite:(Favorite *) favorite;
- (void)setTitle:(NSString *) title;

@end
