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
@property (nonatomic, retain) NSString *playTitle;

@property (nonatomic, retain) NSMutableArray *playlistTitle;
@property (nonatomic, retain) NSMutableArray  *favoriteList;

@property (nonatomic, retain) NSMutableArray  *videoTitle;
@property (nonatomic, retain) NSMutableArray  *videoThumbnail;
@property (nonatomic, retain) NSMutableArray  *videoId;

- (void)addFavorite:(Favorite *) favorite;
- (void)setTitle:(NSString *) title;

- (void)addPlaylistWithTitle:(NSString *)videoTitle thumbnail:(NSString *)videoTshumbnail andVideoId:(NSString *)videoId;
- (void)deleteVideo:(NSString *)videoId fromPlaylist:(NSString *)playlistTitle;

@end
