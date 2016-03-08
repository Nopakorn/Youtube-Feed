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
        self.search = @"search?";
        self.video = @"video?";
        self.youtube_api_key = @"AIzaSyBpRHVLAcM9oTm9hvgXfe1f0ydH9Pv5sug";
    }
    return self;
}


-(void) callSearch
{
    NSLog(@"calling youtube services");
    [self getSearchYoutube];
}

-(void) getSearchYoutube
{

    NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id%%2C+snippet&q=pop+music&type=video&key=AIzaSyBpRHVLAcM9oTm9hvgXfe1f0ydH9Pv5sug&maxResults=20"];
    
    
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
            NSLog(@"json reponse %@",json);
            [self fetchVideos];
        }else{
            NSLog(@"%@",error);
        }
        
        
        
    }] resume];

}

-(void) fetchVideos
{
    NSArray* items = self.searchResults[@"items"];
    //self.videoIdList = [NSMutableArray arrayWithCapacity:10];
    
    //Testing query id from result;
     NSLog(@"adding id");
    for (NSDictionary* q in items) {
        [self.videoIdList addObject:q[@"id"][@"videoId"]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoId" object:self];
}

@end
