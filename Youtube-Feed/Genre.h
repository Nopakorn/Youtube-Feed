//
//  Genre.h
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 4/21/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Genre : NSObject
{
    NSMutableData* receivedData;
}
@property (nonatomic, copy) NSString *youtube_api_key;
@property (nonatomic, copy) NSString *regionCode;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *hl;
@property (nonatomic, retain) NSMutableArray *genreTitles;
@property (nonatomic, retain) NSMutableArray *genreIds;
@property (nonatomic, retain) NSDictionary *searchResults;

- (id)init;
- (void)getGenreFromYoutube;

@end
