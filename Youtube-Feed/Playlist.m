//
//  Playlist.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "Playlist.h"

@implementation Playlist

-(id)init
{
    if(self = [super init]){
        self.playlistTitle = [[NSMutableArray alloc] initWithCapacity:10];
        self.favoriteList = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)addFavorite:(Favorite *)favorite;
{
    [self.favoriteList addObject:favorite];
}

- (void)setTitle:(NSString *)title
{
    [self.playlistTitle addObject:title];
}
@end
