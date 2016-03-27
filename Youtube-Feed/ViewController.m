//
//  ViewController.m
//  Youtube-Feed
//
//  Created by guild on 2/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "ViewController.h"
#import "MainTabBarViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController
{
    Boolean recommendTableViewFlag;
    Boolean searchTableViewFlag;
    Boolean playlistDetailTableViewFlag;
    Boolean genreListTableViewFlag;
    Boolean favoriteTableViewFlag;
    Boolean favoriteDidPlayed;
    Boolean playlistDidPlayed;
    
    BOOL outOfLengthAlert;
    NSInteger item;
    NSInteger queryIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;
    
    item = 0;
    queryIndex = -1;
    recommendTableViewFlag = false;
    searchTableViewFlag = false;
    playlistDetailTableViewFlag = false;
    genreListTableViewFlag = false;
    outOfLengthAlert = true;
    favoriteTableViewFlag = false;
    favoriteDidPlayed = false;
    playlistDidPlayed = false;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.youtube = [[Youtube alloc] init];
    self.favorite = [[Favorite alloc] init];
    //self.playlist = [[Playlist alloc] init];
    self.favoriteList = [[NSMutableArray alloc] initWithCapacity:10];
    
    
    //play recommend video first time
    MainTabBarViewController *tabbar = (MainTabBarViewController *)self.tabBarController;
    self.youtube = tabbar.youtube;
    
    if([tabbar.youtube.videoIdList count] == 0){
        NSLog(@"object is nil");
    }
    
    //[self.navigationController setNavigationBarHidden:NO];
    self.playerView.delegate = self;
    NSDictionary *playerVers = @{
                                 @"playsinline" : @1,
                                 @"controls" : @0,
                                 @"showinfo" : @1,
                                 @"modestbranding" : @1,
    };
    
    [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPlayBackStartedNotification:)
                                                 name:@"Playback started" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPlaylistDetailNotification:)
                                                 name:@"PlaylistDetailDidSelected" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedGenreListNotification:)
                                                 name:@"PlayGenreListDidSelected" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDeleteFavoriteNotification:)
                                                 name:@"DeleteFavorite" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedFavoriteDidSelectedNotification:)
                                                 name:@"FavoriteDidSelected" object:nil];
    self.addButton.hidden = YES;
    NSLog(@"View did load in youtube %@",[tabbar.recommendYoutube.titleList objectAtIndex:1]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    NSLog(@"View did appear in youtube");
    
    if (recommendTableViewFlag) {
        NSDictionary *playerVers = @{
                                     @"playsinline" : @1,
                                     @"controls" : @0,
                                     @"showinfo" : @1,
                                     @"modestbranding" : @1,
                                     };
        
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
        recommendTableViewFlag = false;
    }
    
    if (searchTableViewFlag) {
        NSDictionary *playerVers = @{
                                     @"playsinline" : @1,
                                     @"controls" : @0,
                                     @"showinfo" : @1,
                                     @"modestbranding" : @1,
                                     };
        
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
        searchTableViewFlag = false;
    }
    
    if (playlistDetailTableViewFlag) {
        NSDictionary *playerVers = @{
                                     @"playsinline" : @1,
                                     @"controls" : @0,
                                     @"showinfo" : @1,
                                     @"modestbranding" : @1,
                                     };
        
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
        playlistDetailTableViewFlag = false;
        playlistDidPlayed = true;
    }

    if (genreListTableViewFlag) {
        NSDictionary *playerVers = @{
                                     @"playsinline" : @1,
                                     @"controls" : @0,
                                     @"showinfo" : @1,
                                     @"modestbranding" : @1,
                                     };
        
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
        genreListTableViewFlag = false;

    }
    
    if (favoriteTableViewFlag) {
        NSDictionary *playerVers = @{
                                     @"playsinline" : @1,
                                     @"controls" : @0,
                                     @"showinfo" : @1,
                                     @"modestbranding" : @1,
                                     };
        
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
        favoriteTableViewFlag = false;
        favoriteDidPlayed = true;
        
    }
    
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    BOOL checkFav = false;
    UIImage *btnImageStarCheck = [UIImage imageNamed:@"star_2.png"];
    UIImage *btnImageStar = [UIImage imageNamed:@"star_1.jpg"];
    
    self.resultFovorite = [self.fetchedResultsController fetchedObjects];
    for (int i = 0; i < [self.resultFovorite count]; i++) {
        
        NSManagedObject *object = [self.resultFovorite objectAtIndex:i];
        if ([[object valueForKey:@"videoId"]isEqualToString:[self.youtube.videoIdList objectAtIndex:item]]) {
            checkFav = true;
            break;
        } else {
            checkFav = false;
        }
    }
    
    if (checkFav) {
        [self.favoriteButton setImage:btnImageStarCheck forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setImage:btnImageStar forState:UIControlStateNormal];
    }
    
    [self.playerView playVideo];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    if (state == kYTPlayerStateEnded) {
        NSLog(@"Ended video");
        item+=1;
        [self.playerView pauseVideo];
        if(item == [self.youtube.videoIdList count]){
            NSLog(@"Out of length");
            outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
            outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
            [self presentViewController:outOflengthAlert animated:YES completion:nil];
            
        }else {
            NSDictionary *playerVers = @{
                                         @"playsinline" : @1,
                                         @"controls" : @0,
                                         @"showinfo" : @1,
                                         @"modestbranding" : @1,
                                         @"autoplay" : @0
                                         };
            [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
            
        }
        
    }else if (state == kYTPlayerErrorVideoNotFound) {
        
        NSLog(@"Video not found : %@", [self.youtube.videoIdList objectAtIndex:item]);
        
    }else if (state == kYTPlayerStateUnstarted) {
        
        NSLog(@"Video unstarted : %@", [self.youtube.videoIdList objectAtIndex:item]);
        item+=1;
        [self.playerView pauseVideo];
        if(item == [self.youtube.videoIdList count]) {
            
             NSLog(@"Out of length");
            outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
            outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
            [self presentViewController:outOflengthAlert animated:YES completion:nil];
             item-=1;
        }else {
            NSDictionary *playerVers = @{
                                         @"playsinline" : @1,
                                         @"controls" : @0,
                                         @"showinfo" : @1,
                                         @"modestbranding" : @1,
                                         @"autoplay" : @0
                                         };
            [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
            
        }

    }
}

- (void)buttonPressed:(id)sender
{
    if (sender == self.playButton) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback Started" object:self];
        [self.playerView playVideo];
        
    } else if (sender == self.pauseButton) {
        
        [self.playerView pauseVideo];
        
    } else if (sender == self.nextButton) {
        
        item+=1;
        [self.playerView pauseVideo];
        if (outOfLengthAlert) {
            
            if (item == [self.youtube.videoIdList count]) {
                NSLog(@"Out of length");
                outOfLengthAlert = false;
                outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
                outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
                [self presentViewController:outOflengthAlert animated:YES completion:nil];
                item-=1;
            }else {
                NSDictionary *playerVers = @{
                                             @"playsinline" : @1,
                                             @"controls" : @0,
                                             @"showinfo" : @1,
                                             @"modestbranding" : @1,
                                             @"autoplay" : @0
                                             };
                [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
                
            }

        }
        
    } else if (sender == self.prevButton) {
        
        item-=1;
        [self.playerView pauseVideo];
        if (outOfLengthAlert) {
            if (item < 0) {
                NSLog(@"Out of length");
                outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
                outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
                [self presentViewController:outOflengthAlert animated:YES completion:nil];
                item+=1;
            } else {
                NSDictionary *playerVers = @{
                                             @"playsinline" : @1,
                                             @"controls" : @0,
                                             @"showinfo" : @1,
                                             @"modestbranding" : @1,
                                             @"autoplay" : @0
                                             };
                [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:playerVers];
                
            }

        }
    }

}

- (void)favoritePressed:(id)sender
{
    NSString *videoId = [self.youtube.videoIdList objectAtIndex:item];
    NSString *videoTitle = [self.youtube.titleList objectAtIndex:item];
    NSString *videoThumbnail = [self.youtube.thumbnailList objectAtIndex:item];
    [self.favorite setFavoriteWithTitle:videoTitle thumbnail:videoThumbnail andVideoId:videoId];
    
    UIImage *btnImageStarCheck = [UIImage imageNamed:@"star_2.png"];
    UIImage *btnImageStar = [UIImage imageNamed:@"star_1.jpg"];

    if ([[self.favoriteButton imageForState:UIControlStateNormal] isEqual:btnImageStar]) {
        
        favoriteAlert = [UIAlertController alertControllerWithTitle:nil message:@"Adding to Favorite" preferredStyle:UIAlertControllerStyleAlert];
        favoriteAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissFavoriteAlert) userInfo:nil repeats:NO];
        [self presentViewController:favoriteAlert animated:YES completion:nil];
        [self.favoriteList addObject:self.favorite];
        [self insertFavorite:self.favorite];
        [self.favoriteButton setImage:btnImageStarCheck forState:UIControlStateNormal];
    } else {
        
        favoriteAlert = [UIAlertController alertControllerWithTitle:nil message:@"Delete From Favorite" preferredStyle:UIAlertControllerStyleAlert];
        favoriteAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissFavoriteAlert) userInfo:nil repeats:NO];
        [self presentViewController:favoriteAlert animated:YES completion:nil];
        [self deleteFavorite:self.favorite];
        [self.favoriteButton setImage:btnImageStar forState:UIControlStateNormal];
    }

}

- (void)deleteFavorite:(Favorite *)favorite
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"videoId == %@",favorite.videoId]];
    
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    for (NSManagedObject *manageObject in result) {
        [context deleteObject:manageObject];
    }
    
}


- (void)insertFavorite:(Favorite *)favorite
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    [newManagedObject setValue:favorite.videoId forKey:@"videoId"];
    [newManagedObject setValue:favorite.videoTitle forKey:@"videoTitle"];
    [newManagedObject setValue:favorite.videoThumbnail forKey:@"videoThumbnail"];
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


- (void)dismissFavoriteAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [favoriteAlert dismissViewControllerAnimated:YES completion:nil];
        [favoriteAlertTimer invalidate];
    });
}

- (void)dismissOutOflengthAlert
{
    outOfLengthAlert = true;
    [outOflengthAlert dismissViewControllerAnimated:YES completion:nil];
    [outOflengthAlertTimer invalidate];
}
- (void)receivedDeleteFavoriteNotification:(NSNotification *)notification
{
    if (favoriteDidPlayed) {
        favoriteDidPlayed = false;
        favoriteTableViewFlag = true;
        self.youtube = [notification.userInfo objectForKey:@"youtubeObj"];
        
    }
}

- (void)receivedPlayBackStartedNotification:(NSNotification *) notification
{
    if ([notification.name isEqual:@"Playback Started"] && notification.object != self) {
        NSLog(@"pause video");
        [self.playerView pauseVideo];
    }

}

- (void)receivedPlaylistDetailNotification:(NSNotification *)notification
{
    playlistDetailTableViewFlag = true;
    self.youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    item = [[notification.userInfo objectForKey:@"selectedIndex"] integerValue];
    NSLog(@"Received playlistDetail");
}

- (void)receivedGenreListNotification:(NSNotification *)notification
{
    genreListTableViewFlag = true;
    self.youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    item = [[notification.userInfo objectForKey:@"selectedIndex"] integerValue];
    NSLog(@"Received playGenreList");
}

- (void)receivedFavoriteDidSelectedNotification:(NSNotification *)notification
{
    favoriteTableViewFlag = true;
    self.youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    item = [[notification.userInfo objectForKey:@"selectedIndex"] integerValue];
    NSLog(@"Received favorite");

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *newVC = segue.destinationViewController;
    
    [ViewController setPresentationStyleForSelfController:self presentingController:newVC];
}

+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        //iOS 8.0 and above
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 2) {
    
        UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:2];
        PlaylistTableViewController *playlistView = [nav.viewControllers objectAtIndex:0];
        playlistView.favorite = self.favorite;
        playlistView.youtube = self.youtube;
        NSLog(@"select playlist");
    }
    
    if (tabBarController.selectedIndex == 1) {
       
        UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:1];
        RecommendTableViewController *rec = [nav.viewControllers objectAtIndex:0];
        rec.delegate = self;
         NSLog(@"select rocommend");
    }
    
    if (tabBarController.selectedIndex == 3) {
        
        UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:3];
        SearchTableViewController *seachView = [nav.viewControllers objectAtIndex:0];
        seachView.delegate = self;
        NSLog(@"select search");
    }
}

#pragma mark - delegate RecommendTableViewController

- (void)recommendTableViewControllerDidSelected:(RecommendTableViewController *)recommendViewController
{
    recommendTableViewFlag = true;
    self.youtube = recommendViewController.recommendYoutube;
    item = recommendViewController.selectedRow;
    NSLog(@"recommend did selected");
}

- (void)recommendTableViewControllerNextPage:(RecommendTableViewController *)recommendViewController
{
    self.youtube = recommendViewController.recommendYoutube;
    NSLog(@"recommend next page");
}

#pragma mark - delegate SearchTableViewController

- (void)searchTableViewControllerDidSelected:(SearchTableViewController *)searchViewController
{
    searchTableViewFlag = true;
    self.youtube = searchViewController.searchYoutube;
    item = searchViewController.selectedRow;
     NSLog(@"Received Search");
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{

    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}

@end
