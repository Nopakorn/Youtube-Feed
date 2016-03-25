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
        self.videoTitleList = [[NSMutableArray alloc] initWithCapacity:10];
        self.videoIdList = [[NSMutableArray alloc] initWithCapacity:10];
        self.videoThumbnail = [[NSMutableArray alloc] initWithCapacity:10];

    }
    return self;
}



- (void)setTitle:(NSString *)title
{
    self.playlistTitle = [NSString stringWithFormat:@"%@",title];
}

- (void)addPlaylistWithTitle:(NSString *)videoTitle thumbnail:(NSString *)videoThumbnail andVideoId:(NSString *)videoId
{
    [self.videoIdList addObject:videoId];
    [self.videoTitleList addObject:videoTitle];
    [self.videoThumbnail addObject:videoThumbnail];

}


@end
