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
}

- (id)init
{
    if(self = [super init]){
        //will change later
        self.siteURLString = [NSString stringWithFormat:@"http://www.googleapis.com/youtube/v3/"];
        self.videoIdList = [[NSMutableArray alloc] initWithCapacity:10];
        self.thumbnailList = [[NSMutableArray alloc] initWithCapacity:10];
        self.titleList = [[NSMutableArray alloc] initWithCapacity:10];
        self.search = @"search?";
        self.video = @"video?";
        self.youtube_api_key = @"AIzaSyBpRHVLAcM9oTm9hvgXfe1f0ydH9Pv5sug";
    }
    return self;
}


- (void)callSearch:(NSMutableArray *)genreSelected
{
    self.searchTerm = @"";
    for(int i = 0 ; i < [genreSelected count] ; i++){
        self.searchTerm = [NSString stringWithFormat:@"%@ %@", self.searchTerm, [genreSelected objectAtIndex:i]];
    }
    self.searchTerm = [self.searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSLog(@"calling youtube services with searchTerm:%@",self.searchTerm);
    [self getSearchYoutube:self.searchTerm];
    
}

- (void)callSearchRecommendNextPage:(NSMutableArray *)genreSelected
{
    self.searchTerm = @"";
    for(int i = 0 ; i < [genreSelected count] ; i++){
        self.searchTerm = [NSString stringWithFormat:@"%@ %@", self.searchTerm, [genreSelected objectAtIndex:i]];
    }
    self.searchTerm = [self.searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [self getSearchYoutubeNextPage:self.searchTerm];

}


- (void)getSearchYoutube:(NSString *)searchTerm
{

    NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&q=%@+music&type=video&key=AIzaSyBpRHVLAcM9oTm9hvgXfe1f0ydH9Pv5sug&maxResults=25", searchTerm];
    
    
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
            [self fetchVideos];
        }else{
            NSLog(@"%@",error);
        }
        
        
        
    }] resume];

}

- (void)getSearchYoutubeNextPage:(NSString *)searchTerm
{
    
    NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&pageToken=%@&q=%@+music&type=video&key=AIzaSyBpRHVLAcM9oTm9hvgXfe1f0ydH9Pv5sug&maxResults=25", self.nextPageToken, searchTerm];
    
    
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
            [self fetchVideos];
        }else{
            NSLog(@"%@",error);
        }
        
        
        
    }] resume];
    
}

- (void)callSearchByText:(NSString *)text
{
    NSString *setText = [text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&q=%@&type=video&key=AIzaSyBpRHVLAcM9oTm9hvgXfe1f0ydH9Pv5sug&maxResults=25", setText];
    
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

            [self fetchVideos];
        }else{
            NSLog(@"%@",error);
        }
        
        
        
    }] resume];
}

- (void)callSearchNextPage:(NSString *)text
{
    NSString *setText = [text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&pageToken=%@&q=%@&type=video&key=AIzaSyBpRHVLAcM9oTm9hvgXfe1f0ydH9Pv5sug&maxResults=25", self.nextPageToken, setText];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [req setHTTPMethod:@"GET"];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if(!error)
        {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.searchResults = json;
            checkResult = @"LoadVideoIdFromSearchNextPage";
            [self fetchVideos];
        }else{
            NSLog(@"%@",error);
        }
        
        
        
    }] resume];
}



-(void)fetchVideos
{
    NSArray* items = self.searchResults[@"items"];
    self.nextPageToken = self.searchResults[@"nextPageToken"];
    self.prevPageToken = self.searchResults[@"prevPageToken"];
    for (NSDictionary* q in items) {
        [self.videoIdList addObject:q[@"id"][@"videoId"]];
        [self.titleList addObject:q[@"snippet"][@"title"]];
        [self.thumbnailList addObject:q[@"snippet"][@"thumbnails"][@"default"][@"url"]];
    }
    
    if ([checkResult isEqualToString:@"LoadVideoIdFromSearchNextPage"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoIdFromSearchNextPage" object:self];
        
    } else if ([checkResult isEqualToString:@"LoadVideoIdFromSearch"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoIdFromSearch" object:self];
        
    } else if ([checkResult isEqualToString:@"LoadVideoId"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoId" object:self];
        
    } else if ([checkResult isEqualToString:@"LoadVideoIdNextPage"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoIdNextPage" object:self];
    }
    
}

@end
