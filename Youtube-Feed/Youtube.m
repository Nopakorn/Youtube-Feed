//
//  Youtube.m
//  Youtube-Feed
//
//  Created by guild on 2/19/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "Youtube.h"

@implementation Youtube

-(id)init
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


-(void) callSearch:(NSMutableArray *)genreSelected
{
    self.searchTerm = @"";
    for(int i = 0 ; i < [genreSelected count] ; i++){
        
        self.searchTerm = [NSString stringWithFormat:@"%@ %@", self.searchTerm, [genreSelected objectAtIndex:i]];
    }
    self.searchTerm = [self.searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    //self.searchTerm = [NSString stringWithFormat:@"%@+music",self.searchTerm];
    
    NSLog(@"calling youtube services with searchTerm:%@",self.searchTerm);
    [self getSearchYoutube:self.searchTerm];
}

-(void) getSearchYoutube:(NSString *)searchTerm
{

    NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&q=%@+music&type=video&key=AIzaSyBpRHVLAcM9oTm9hvgXfe1f0ydH9Pv5sug&maxResults=25", searchTerm];
    
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [req setHTTPMethod:@"GET"];
    //[req setValue:@"Bearer" forHTTPHeaderField:@"Authorization"];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if(!error)
        {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.searchResults = json;
            //NSLog(@"json reponse %@",json);
            [self fetchVideos];
        }else{
            NSLog(@"%@",error);
        }
        
        
        
    }] resume];

}

-(void) callSearchByText:(NSString *)text
{
    NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&q=%@&type=video&key=AIzaSyBpRHVLAcM9oTm9hvgXfe1f0ydH9Pv5sug&maxResults=25", text];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [req setHTTPMethod:@"GET"];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if(!error)
        {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.searchResults = json;
            [self fetchVideosFromSearch];
        }else{
            NSLog(@"%@",error);
        }
        
        
        
    }] resume];
}



-(void)fetchVideos
{
    NSArray* items = self.searchResults[@"items"];
    //self.videoIdList = [NSMutableArray arrayWithCapacity:10];
    
    //Testing query id from result;
     NSLog(@"adding id");
    for (NSDictionary* q in items) {
        [self.videoIdList addObject:q[@"id"][@"videoId"]];
        [self.titleList addObject:q[@"snippet"][@"title"]];
        [self.thumbnailList addObject:q[@"snippet"][@"thumbnails"][@"default"][@"url"]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoId" object:self];
}

-(void)fetchVideosFromSearch
{
    NSArray* items = self.searchResults[@"items"];
    //self.videoIdList = [NSMutableArray arrayWithCapacity:10];
    
    //Testing query id from result;
    NSLog(@"adding id");
    for (NSDictionary* q in items) {
        [self.videoIdList addObject:q[@"id"][@"videoId"]];
        [self.titleList addObject:q[@"snippet"][@"title"]];
        [self.thumbnailList addObject:q[@"snippet"][@"thumbnails"][@"default"][@"url"]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoIdFromSearch" object:self];
}


@end
