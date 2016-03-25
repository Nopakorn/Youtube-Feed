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
@property (nonatomic, retain) NSString *playlistTitle;
@property (nonatomic, retain) NSMutableArray  *videoTitleList;
@property (nonatomic, retain) NSMutableArray  *videoThumbnail;
@property (nonatomic, retain) NSMutableArray  *videoIdList;


- (void)setTitle:(NSString *) title;

- (void)addPlaylistWithTitle:(NSString *)videoTitle thumbnail:(NSString *)videoTshumbnail andVideoId:(NSString *)videoId;

@end
