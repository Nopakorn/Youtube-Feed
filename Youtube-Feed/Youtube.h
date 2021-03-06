//
//  Youtube.h
//  Youtube-Feed
//
//  Created by guild on 2/19/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Youtube : NSObject
{
    NSMutableData* receivedData;
}

@property (nonatomic, copy) NSString *siteURLString;
@property (nonatomic, copy) NSString *search;
@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic, copy) NSString *video;
@property (nonatomic, copy) NSString *youtube_api_key;
@property (nonatomic, copy) NSString *part;
@property (nonatomic, copy) NSString *nextPageToken;
@property (nonatomic, copy) NSString *prevPageToken;
@property (nonatomic, copy) NSString *regionCode;
@property (nonatomic, copy) NSString *hl;
@property (nonatomic, copy) NSString *videoIdListForGetDuration;


@property (nonatomic, retain) NSMutableArray *videoIdList;
@property (nonatomic, retain) NSMutableArray *titleList;
@property (nonatomic, retain) NSMutableArray *thumbnailList;
@property (nonatomic, retain) NSMutableArray *durationList;

@property (nonatomic, retain) NSMutableArray *selectedType;

@property (nonatomic, retain) NSDictionary *searchResults;




- (id)init;
- (void)callRecommendSearch:(NSMutableArray *)genreSelected withNextPage:(BOOL)nextPage;
- (void)callSearchByText:(NSString *)text withNextPage:(BOOL)nextPage;
- (void)getGenreSearchYoutube:(NSString *)searchTerm withNextPage:(BOOL)nextPage;
- (void)getRecommendSearchYoutube:(NSString *)searchTerm withNextPage:(BOOL)nextPage;
- (void)changeIndexNextPage:(int )newIndexNextPage;

@end
