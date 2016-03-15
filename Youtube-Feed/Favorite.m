//
//  Favorite.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "Favorite.h"

@implementation Favorite

-(id)init
{
    if(self = [super init]){
        self.videoTitle = [[NSMutableArray alloc] initWithCapacity:10];
        self.videoId = [[NSMutableArray alloc] initWithCapacity:10];
        self.videothumbnail = [[NSMutableArray alloc] initWithCapacity:10];
    
    }
    return self;
}

- (void)setFavoriteWithTitle:(NSString *)videoTitle thumbnail:(NSString *)videothumbnail andVideoId:(NSString *)videoId
{
//    self.videoId = [NSString stringWithFormat:@"%@", videoId];
//    self.videoTitle = [NSString stringWithFormat:@"%@", videoTitle];
//    self.videothumbnail = [NSString stringWithFormat:@"%@", videothumbnail];
    [self.videoId addObject:videoId];
    [self.videoTitle addObject:videoTitle];
    [self.videothumbnail addObject:videothumbnail];
}

@end