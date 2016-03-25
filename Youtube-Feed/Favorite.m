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
    
    }
    return self;
}

- (void)setFavoriteWithTitle:(NSString *)videoTitle thumbnail:(NSString *)videoThumbnail andVideoId:(NSString *)videoId
{
    self.videoId = [NSString stringWithFormat:@"%@", videoId];
    self.videoTitle = [NSString stringWithFormat:@"%@", videoTitle];
    self.videoThumbnail = [NSString stringWithFormat:@"%@", videoThumbnail];

}

@end
