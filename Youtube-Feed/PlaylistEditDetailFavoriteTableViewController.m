//
//  PlaylistEditDetailFavoriteTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "PlaylistEditDetailFavoriteTableViewController.h"
#import "FavoriteCustomCell.h"
#import "AppDelegate.h"

#import <UIEMultiAccess/UIEMultiAccess.h>
#import <UIEMultiAccess/DNApplicationManager.h>
#import <UIEMultiAccess/DNAppCatalog.h>
#import <UIEMultiAccess/UMAApplicationInfo.h>

typedef NS_ENUM(NSInteger, SectionType) {
    SECTION_TYPE_SETTINGS,
    SECTION_TYPE_LAST_CONNECTED_DEVICE,
    SECTION_TYPE_CONNECTED_DEVICE,
    SECTION_TYPE_DISCOVERED_DEVICES,
};

typedef NS_ENUM(NSInteger, AlertType) {
    ALERT_TYPE_FAIL_TO_CONNECT,
    ALERT_TYPE_DISCOVERY_TIMEOUT,
};

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface PlaylistEditDetailFavoriteTableViewController ()<UMAFocusManagerDelegate>

@property (nonatomic, strong) UMAFocusManager *focusManager;

@end

@implementation PlaylistEditDetailFavoriteTableViewController
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Favorites", nil)];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setHidden:YES];

    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 5)];
    navBorder.tag = 99;
    [navBorder setBackgroundColor:UIColorFromRGB(0x4F6366)];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_focusManager setHidden:YES];
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if (subView.tag == 99) {
            [subView removeFromSuperview];
        }
    }
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if (subView.tag == 99) {
            [subView removeFromSuperview];
        }
    }
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 5)];
    navBorder.tag = 99;
    [navBorder setBackgroundColor:UIColorFromRGB(0x4F6366)];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    
}

- (void)viewWillAppear:(BOOL)animated
{

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"FavoriteCustomCell";
    FavoriteCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FavoriteCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.name.text = [object valueForKey:@"videoTitle"];
    cell.durationLabel.text = [self durationText:[object valueForKey:@"videoDuration"]];
    cell.favoriteIcon.hidden = YES;
    cell.tag = indexPath.row;
    cell.thumnail.image = nil;
    
    if([object valueForKey:@"videoThumbnail"]  != nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[object valueForKey:@"videoThumbnail"]]];
            
            if(data){
                [self.imageData addObject:data];
                UIImage* image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(cell.tag == indexPath.row){
                            cell.thumnail.image = image;
                            [cell setNeedsLayout];
                        }
                    });
                }
            }
        });
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    self.favorite = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self saveVideotoPlaylist:self.favorite];
}


- (void)saveVideotoPlaylist:(Favorite *)favorite
{

    if ([self checkPlaylist:favorite]) {
        
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"This video is already in the Playlist", nil)];
        
        alert = [UIAlertController alertControllerWithTitle:@""
                                                    message:description
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
       
    } else {

        NSString *description = [NSString stringWithFormat:@"Adding Video to %@",self.playlist.title];
        alert = [UIAlertController alertControllerWithTitle:@"Adding Video"
                                                    message:description
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       
                                                       
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        YoutubeVideo *youtubeVideo = [NSEntityDescription insertNewObjectForEntityForName:@"YoutubeVideo" inManagedObjectContext:context];
        youtubeVideo.timeStamp = [NSDate date];
        youtubeVideo.videoTitle = favorite.videoTitle;
        youtubeVideo.videoId = favorite.videoId;
        youtubeVideo.videoThumbnail = favorite.videoThumbnail;
        youtubeVideo.videoDuration = favorite.videoDuration;
        youtubeVideo.playlist = self.playlist;
        youtubeVideo.index = @([self.playlist.youtubeVideos count]);

        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"updatePlaylistFact"];
        [self.delegate addingVideoFromPlayListEditDetailFavorite:favorite];
    }
}

- (BOOL)checkPlaylist:(Favorite *)favorite
{
    BOOL flag = false;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"YoutubeVideo" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"playlist == %@",self.playlist]];
    
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    
    for (YoutubeVideo *youtubeObject in result) {
        if ([youtubeObject.videoId isEqualToString:favorite.videoId]) {
            flag = true;
            break;
        }
    }
    
    return flag;
}

- (NSString *)durationText:(NSString *)duration
{
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    duration = [duration substringFromIndex:[duration rangeOfString:@"T"].location];
    
    while ([duration length] > 1) { //only one letter remains after parsing
        duration = [duration substringFromIndex:1];
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:duration];
        
        NSString *durationPart = [[NSString alloc] init];
        [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] intoString:&durationPart];
        
        NSRange rangeOfDurationPart = [duration rangeOfString:durationPart];
        
        duration = [duration substringFromIndex:rangeOfDurationPart.location + rangeOfDurationPart.length];
        
        if ([[duration substringToIndex:1] isEqualToString:@"H"]) {
            hours = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"M"]) {
            minutes = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"S"]) {
            seconds = [durationPart intValue];
        }
    }
    
    if (hours != 0) {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    

    [fetchRequest setFetchBatchSize:20];
    

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadData];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
