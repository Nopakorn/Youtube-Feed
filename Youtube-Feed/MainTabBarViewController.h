//
//  MainTabBarViewController.h
//  Youtube-Feed
//
//  Created by guild on 3/8/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"
#import "Playlist.h"
#import "Genre.h"

#import <UIEMultiAccess/UIEMultiAccess.h>

@interface MainTabBarViewController : UITabBarController


@property(strong, nonatomic) Youtube *youtube;
@property (strong, nonatomic) Genre *genre;

@property(strong, nonatomic) Youtube *recommendYoutube;
@property(strong, nonatomic) Youtube *searchYoutube;
@property (strong, nonatomic) Playlist *playlist;
@property (nonatomic, retain) NSString *passValue;
@property (nonatomic, retain) NSMutableArray *genreSelected;
@property (nonatomic, retain) NSMutableArray *genreIdSelected;

@property (nonatomic, retain) NSMutableArray *genreTitles;
@property (nonatomic, retain) NSMutableArray *genreIds;
@property (nonatomic) NSInteger startAt;

- (void)saveYoutubeObj:(Youtube *)yt;

@end
