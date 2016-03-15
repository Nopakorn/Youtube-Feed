//
//  Favorite.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Favorite : NSObject

@property (nonatomic, retain) NSMutableArray  *videoTitle;
@property (nonatomic, retain) NSMutableArray  *videothumbnail;
@property (nonatomic, retain) NSMutableArray  *videoId;

- (void)setFavoriteWithTitle:(NSString *)videoTitle thumbnail:(NSString *)videothumbnail andVideoId:(NSString *)videoId;

@end
