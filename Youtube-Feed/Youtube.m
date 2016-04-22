//
//  Youtube.m
//  Youtube-Feed
//
//  Created by guild on 2/19/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "Youtube.h"

@implementation Youtube
{
    NSString *checkResult;
    NSString *checkDurationEachVideo;
    NSInteger nextVideo;
    int indexNexPage;
}

- (id)init
{
    if(self = [super init]){
        //will change later
        self.siteURLString = [NSString stringWithFormat:@"http://www.googleapis.com/youtube/v3/"];
        self.videoIdList = [[NSMutableArray alloc] initWithCapacity:10];
        self.thumbnailList = [[NSMutableArray alloc] initWithCapacity:10];
        self.titleList = [[NSMutableArray alloc] initWithCapacity:10];
        self.durationList = [[NSMutableArray alloc] initWithCapacity:10];
        self.search = @"search?";
        self.video = @"video?";
        //self.youtube_api_key = @"AIzaSyBpRHVLAcM9oTm9hvgXfe1f0ydH9Pv5sug";
        self.youtube_api_key = @"AIzaSyAPT3PRTZdTQDdoOtwviiC0FQPpJvfQlWE";
        self.videoIdListForGetDuration = @"";
        nextVideo = 0;
        indexNexPage = 0;
        NSLocale *currentLocale = [NSLocale currentLocale];
        self.regionCode = [currentLocale objectForKey:NSLocaleCountryCode];
    }
    return self;
}


- (void)callRecommendSearch:(NSMutableArray *)genreSelected withNextPage:(BOOL)nextPage
{
    self.searchTerm = @"";
    for(int i = 0 ; i < [genreSelected count] ; i++){
        self.searchTerm = [NSString stringWithFormat:@"%@ %@", self.searchTerm, [genreSelected objectAtIndex:i]];
    }
    self.searchTerm = [self.searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSLog(@"calling youtube services with searchTerm:%@",self.searchTerm);
    [self getRecommendSearchYoutube:self.searchTerm withNextPage:nextPage];
    
}

- (void)getGenreSearchYoutube:(NSString *)searchTerm withNextPage:(BOOL)nextPage
{
    NSLog(@"regionCode %@",self.regionCode);
    searchTerm = [searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *escapedString = [searchTerm stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString* urlString;
    if (nextPage) {
        urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&pageToken=%@&q=%@+music&type=video&key=%@&maxResults=25&regionCode=%@", self.nextPageToken, escapedString, self.youtube_api_key, self.regionCode];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        [req setHTTPMethod:@"GET"];
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(!error)
            {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                self.searchResults = json;
                checkResult = @"LoadGenreVideoIdNextPage";
                [self fetchVideos:nextPage];
                
            }else{
                
                NSLog(@"%@",error);
            }
            
        }] resume];

        
    } else {
        
        urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&q=%@+music&type=video&key=%@&maxResults=25&regionCode=%@", escapedString , self.youtube_api_key, self.regionCode];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        [req setHTTPMethod:@"GET"];
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(!error)
            {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                self.searchResults = json;
                checkResult = @"LoadGenreVideoId";
                [self fetchVideos:nextPage];
                
            }else{
                NSLog(@"%@",error);
                
            }
            
        }] resume];

    }
    
}

- (void)getRecommendSearchYoutube:(NSString *)searchTerm withNextPage:(BOOL)nextPage
{
    
    NSString *escapedString = [searchTerm stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if (nextPage) {
    
        NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&pageToken=%@&q=%@+music&type=video&key=%@&maxResults=25&regionCode=%@", self.nextPageToken, escapedString, self.youtube_api_key, self.regionCode];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        [req setHTTPMethod:@"GET"];
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(!error)
            {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                self.searchResults = json;
                checkResult = @"LoadVideoIdNextPage";
                [self fetchVideos:nextPage];
                
            }else{
                NSLog(@"%@",error);
                
            }
            
        }] resume];
        
    } else {
        
        NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&q=%@+music&type=video&key=%@&maxResults=25&regionCode=%@", escapedString, self.youtube_api_key, self.regionCode];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        [req setHTTPMethod:@"GET"];
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(!error)
            {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                self.searchResults = json;
                checkResult = @"LoadVideoId";
                [self fetchVideos:nextPage];
            }else{
                NSLog(@"%@",error);
            }
        
        }] resume];
    }
    

}


- (void)callSearchByText:(NSString *)text withNextPage:(BOOL)nextPage;
{
    NSString *setText = [text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    //encode for other languages
    NSString *escapedString = [setText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if (nextPage) {
        
        NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&pageToken=%@&q=%@&type=video&key=%@&maxResults=25&regionCode=%@", self.nextPageToken, escapedString, self.youtube_api_key, self.regionCode];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
       NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [req setHTTPMethod:@"GET"];
        
        NSLog(@"URLRequest %@",req);
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(!error)
            {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                self.searchResults = json;
                checkResult = @"LoadVideoIdFromSearchNextPage";
                
                [self fetchVideos:nextPage];
            }else{
                NSLog(@"%@",error);
            }
            
            
            
        }] resume];

    } else {
        
        NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&q=%@&type=video&key=%@&maxResults=25&regionCode=%@", escapedString, self.youtube_api_key, self.regionCode];
       
        NSLog(@"URL %@",urlString);
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        [req setHTTPMethod:@"GET"];
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(!error)
            {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                self.searchResults = json;
                checkResult = @"LoadVideoIdFromSearch";
                
                [self fetchVideos:nextPage];
            }else{
                NSLog(@"%@",error);
            }
            
            
            
        }] resume];

    }
}

- (void)getVideoDurations:(NSString *)videoId
{
            NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=%@&key=%@", videoId, self.youtube_api_key];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        [req setHTTPMethod:@"GET"];
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if(!error)
            {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                self.searchResults = json;
                checkDurationEachVideo = @"done";
                nextVideo++;
                //NSLog(@"%@",self.searchResults);
                [self fetchVideosDuration];
            }else{
                NSLog(@"%@",error);
            }
            
        }] resume];
}

- (void)fetchVideosDuration
{
    NSArray *items = self.searchResults[@"items"];
    for (NSDictionary* q in items) {
        [self.durationList addObject:q[@"contentDetails"][@"duration"]];
    }
  
        if ([checkResult isEqualToString:@"LoadVideoId"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoId" object:self];
        } else if ([checkResult isEqualToString:@"LoadVideoIdFromSearchNextPage"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoIdFromSearchNextPage" object:self];
            
        } else if ([checkResult isEqualToString:@"LoadVideoIdFromSearch"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoIdFromSearch" object:self];
            
        }  else if ([checkResult isEqualToString:@"LoadVideoIdNextPage"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoIdNextPage" object:self];
            
        } else if ([checkResult isEqualToString:@"LoadGenreVideoId"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadGenreVideoId" object:self];
            
        } else if ([checkResult isEqualToString:@"LoadGenreVideoIdNextPage"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadGenreVideoIdNextPage" object:self];
        }

}

-(void)fetchVideos:(BOOL)nextPage
{
    NSArray* items = self.searchResults[@"items"];
    self.nextPageToken = self.searchResults[@"nextPageToken"];
    self.prevPageToken = self.searchResults[@"prevPageToken"];
    for (NSDictionary* q in items) {
        [self.videoIdList addObject:q[@"id"][@"videoId"]];
        [self.titleList addObject:q[@"snippet"][@"title"]];
        [self.thumbnailList addObject:q[@"snippet"][@"thumbnails"][@"default"][@"url"]];
        //[self getVideoDurations:q[@"id"][@"videoId"]];
    }
    
    if (nextPage) {
        indexNexPage += 25;
        self.videoIdListForGetDuration = @"";
        for (int i = indexNexPage; i < [self.videoIdList count]; i++) {
            self.videoIdListForGetDuration = [NSString stringWithFormat:@"%@,%@", self.videoIdListForGetDuration, [self.videoIdList objectAtIndex:i]];
        }
        
    } else {
        
        for (int i = 0; i < [self.videoIdList count]; i++) {
            self.videoIdListForGetDuration = [NSString stringWithFormat:@"%@,%@", self.videoIdListForGetDuration, [self.videoIdList objectAtIndex:i]];
        }

    }
    
    [self getVideoDurations:self.videoIdListForGetDuration];
}

@end
