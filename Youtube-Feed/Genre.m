//
//  Genre.m
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 4/21/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "Genre.h"

@implementation Genre
{
    NSString *checkResult;
    NSMutableArray *resetGenreResult;
}

- (id)init
{
    if(self = [super init]){
        self.genreTitles = [[NSMutableArray alloc] initWithCapacity:10];
        self.genreIds = [[NSMutableArray alloc] initWithCapacity:10];
        resetGenreResult = [[NSMutableArray alloc] initWithCapacity:10];
        self.youtube_api_key = @"AIzaSyAPT3PRTZdTQDdoOtwviiC0FQPpJvfQlWE";
        NSLocale *currentLocale = [NSLocale currentLocale];
        self.regionCode = [currentLocale objectForKey:NSLocaleCountryCode];
        //self.language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        checkResult = @"";
        
        if ([self.regionCode isEqualToString:@"JP"]) {
            self.hl = @"ja-JP";
        } else {
            self.hl = @"en-US";
        }
        
    }
    return self;
}


- (void)getGenreFromYoutube
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videoCategories?part=id%%2C+snippet&hl=%@&regionCode=%@&key=%@", self.hl, self.regionCode, self.youtube_api_key ];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [req setHTTPMethod:@"GET"];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if(!error)
        {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.searchResults = json;
            checkResult = @"LoadGenreTitle";
            [self fetchGenreData];
            
        }else{
            
            NSLog(@"%@",error);
        }
        
    }] resume];
    

    
}

- (void)fetchGenreData
{
    NSArray *items = self.searchResults[@"items"];
    for (NSDictionary* q in items) {
        [self.genreTitles addObject:q[@"snippet"][@"title"]];
        [self.genreIds addObject:q[@"id"]];
    }

    NSLog(@"genre titles %@ %@ genre Language %@",self.genreTitles, self.genreIds, self.language);
    NSLog(@"----------genre count %lu %lu",(unsigned long)[self.genreTitles  count], (unsigned long)[self.genreIds count]);
    if ([checkResult isEqualToString:@"LoadGenreTitle"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadGenreTitle" object:self];
    }
}

@end
