//
//  Playlist+CoreDataProperties.h
//  KKP-Movie
//
//  Created by guild on 3/26/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Playlist.h"

NS_ASSUME_NONNULL_BEGIN

@interface Playlist (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDate *timeStamp;
@property (nullable, nonatomic, retain) NSSet<YoutubeVideo *> *youtubeVideos;

@end

@interface Playlist (CoreDataGeneratedAccessors)

- (void)addYoutubeVideosObject:(YoutubeVideo *)value;
- (void)removeYoutubeVideosObject:(YoutubeVideo *)value;
- (void)addYoutubeVideos:(NSSet<YoutubeVideo *> *)values;
- (void)removeYoutubeVideos:(NSSet<YoutubeVideo *> *)values;

@end

NS_ASSUME_NONNULL_END
