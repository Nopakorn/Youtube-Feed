//
//  YoutubeVideo+CoreDataProperties.h
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 3/28/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YoutubeVideo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YoutubeVideo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSDate *timeStamp;
@property (nullable, nonatomic, retain) NSString *videoId;
@property (nullable, nonatomic, retain) NSString *videoThumbnail;
@property (nullable, nonatomic, retain) NSString *videoTitle;
@property (nullable, nonatomic, retain) NSString *videoDuration;
@property (nullable, nonatomic, retain) Playlist *playlist;

@end

NS_ASSUME_NONNULL_END
