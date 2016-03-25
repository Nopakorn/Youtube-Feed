//
//  Favorite.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Favorite : NSObject

@property (nonatomic, retain) NSString  *videoTitle;
@property (nonatomic, retain) NSString  *videoThumbnail;
@property (nonatomic, retain) NSString  *videoId;

- (void)setFavoriteWithTitle:(NSString *)videoTitle thumbnail:(NSString *)videoThumbnail andVideoId:(NSString *)videoId;

@end
