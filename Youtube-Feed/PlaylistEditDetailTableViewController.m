//
//  PlaylistEditDetailTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "PlaylistEditDetailTableViewController.h"
#import "PlaylistEditDetailFavoriteTableViewController.h"
#import "PlaylistCustomCell.h"
#import "PlaylistEditDetailCustomCell.h"
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
@interface PlaylistEditDetailTableViewController ()<UMAFocusManagerDelegate>

@property (nonatomic, strong) UMAFocusManager *focusManager;


@end

@implementation PlaylistEditDetailTableViewController
{
    NSInteger lastIndex;
    BOOL selectFact;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.youtubeVideoList = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setEditing:YES animated:YES];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.navigationItem.title = self.playlist.title;
    [self fetchYoutubeVideoList];
    //[self getYt];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    selectFact = NO;
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
    
    if (!selectFact) {
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:NO];
    }
    
    
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

- (void)fetchYoutubeVideoList
{
    self.youtubeVideoList = [NSMutableArray arrayWithArray:self.playlist.youtubeVideos.allObjects];    
}

- (void)getYt
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"YoutubeVideo" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"playlist == %@",self.playlist]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    //
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [self.youtubeVideoList removeAllObjects];
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    for (int i = 0; i < result.count; i++) {
        YoutubeVideo *yo = [result objectAtIndex:i];
        [self.youtubeVideoList addObject:yo];
        NSLog(@"check fetch: %@ and index: %@",yo.videoTitle, yo.index);
    }

}


- (void)updateYoutubeVideoList
{

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"YoutubeVideo" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"playlist == %@",self.playlist]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    //
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [self.youtubeVideoList removeAllObjects];
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    for (int i = 0; i < result.count; i++) {
        YoutubeVideo *yo = [result objectAtIndex:i];
        [self.youtubeVideoList addObject:yo];
        
    }

    [self.tableView reloadData];
    //sending data
    Youtube *youtube = [[Youtube alloc] init];
    
    for (int i = 0; i < [self.youtubeVideoList count]; i++) {
        YoutubeVideo *youtubeVideo = [self.youtubeVideoList objectAtIndex:i];
        [youtube.videoIdList addObject:youtubeVideo.videoId];
        [youtube.titleList addObject:youtubeVideo.videoTitle];
        [youtube.thumbnailList addObject:youtubeVideo.videoThumbnail];
        [youtube.durationList addObject:youtubeVideo.videoDuration];
    }
    NSLog(@"check before updated %@",youtube.titleList);
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"updatePlaylistFact"];
    NSString *selected = [NSString stringWithFormat:@"%lu",(long)lastIndex];
    NSDictionary *userInfo = @{@"youtubeObj": youtube,
                               @"selectedIndex": selected};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatePlaylist" object:self userInfo:userInfo];
}

- (void)removeYoutubeVideoFromList
{
    NSSet *newYoutubeVideoList = [NSSet setWithArray:self.youtubeVideoList];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title == %@",self.playlist.title]];
    
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    for (Playlist *playlistObject in result) {
        NSLog(@"remove youtube from playlist");
        playlistObject.youtubeVideos = newYoutubeVideoList;
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }

   
}


- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view did appear playlisteditdetail");
    //[self fetchPlaylist];
    [self getYt];
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

    return [self.youtubeVideoList count]+1;
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
//    if ([sectionInfo numberOfObjects] == 0) {
//        return 1;
//    } else {
//        return [sectionInfo numberOfObjects]+1;
//    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"PlaylistEditDetailCustomCell";
    PlaylistEditDetailCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaylistEditDetailCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        //add gesture ;
        UILongPressGestureRecognizer *lgpr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleLongPress:)];
        lgpr.minimumPressDuration = 1.5;
        [cell addGestureRecognizer:lgpr];
        
    }
    //[self fetchPlaylist];
    if (indexPath.row == 0) {
        cell.name.text = self.playlist.title;
        
        
    }else {
//         NSIndexPath *customIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
//        YoutubeVideo *youtubeVideoForRow = [self.fetchedResultsController objectAtIndexPath:customIndexPath];
        YoutubeVideo *youtubeVideoForRow = [self.youtubeVideoList objectAtIndex:indexPath.row-1];
        cell.name.text = youtubeVideoForRow.videoTitle;
        cell.addIcon.hidden = YES;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectFact = YES;
    lastIndex = indexPath.row;
    if (indexPath.row == 0) {
        
        [self performSegueWithIdentifier:@"AddPlaylistSegue" sender:nil];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    if ([segue.identifier isEqualToString:@"AddPlaylistSegue"]){
        
        PlaylistEditDetailFavoriteTableViewController *dest = segue.destinationViewController;
        dest.playlist = self.playlist;
        dest.youtubeVideoList = self.youtubeVideoList;
        dest.delegate = self;
        
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    if (indexPath == nil) {
        
        NSLog(@"long press table view but not in row");
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan && indexPath.row != 0) {
        
        NSLog(@"began at %ld",indexPath.row);
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Delete this item from playlists", nil)];
        alert = [UIAlertController alertControllerWithTitle:@""
                                                    message:description
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       
                                                       [self deleteRowAtIndex:indexPath.row-1];
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"CANCEL"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){
                                                           
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan && indexPath.row == 0) {
        
        NSLog(@"began at %ld",indexPath.row);
        [self renamePlaylistTitle];
        
    } else {
        NSLog(@"gestureRecognizer state = %ld", gestureRecognizer.state);
    }
}

- (void)deleteRowAtIndex:(NSInteger )index
{
    NSLog(@"delete at %ld", index);
    [self.youtubeVideoList removeObjectAtIndex:index];
    [self.tableView reloadData];
    [self removeYoutubeVideoFromList];
    
    Youtube *youtube = [[Youtube alloc] init];
    
    for (int i = 0; i < [self.youtubeVideoList count]; i++) {
        YoutubeVideo *youtubeVideo = [self.youtubeVideoList objectAtIndex:i];
        [youtube.videoIdList addObject:youtubeVideo.videoId];
        [youtube.titleList addObject:youtubeVideo.videoTitle];
        [youtube.thumbnailList addObject:youtubeVideo.videoThumbnail];
        [youtube.durationList addObject:youtubeVideo.videoDuration];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"updatePlaylistFact"];
    NSString *selected = [NSString stringWithFormat:@"%lu",(long)index];
    NSDictionary *userInfo = @{@"youtubeObj": youtube,
                               @"selectedIndex": selected};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatePlaylist" object:self userInfo:userInfo];
}

//- (void)addingDataToYoutubeObject
//{
//    Youtube *youtube = [[Youtube alloc] init];
//    
//    for (int i = 0; i < [self.youtubeVideoList count]; i++) {
//        YoutubeVideo *youtubeVideo = [self.youtubeVideoList objectAtIndex:i];
//        [youtube.videoIdList addObject:youtubeVideo.videoId];
//        [youtube.titleList addObject:youtubeVideo.videoTitle];
//        [youtube.thumbnailList addObject:youtubeVideo.videoThumbnail];
//        [youtube.durationList addObject:youtubeVideo.videoDuration];
//    }
//}

- (void)renamePlaylistTitle
{
    NSString *title = self.playlist.title;
    alert = [UIAlertController alertControllerWithTitle:@"Edit playlist name"
                                                message:self.playlist.title
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
                                                   
                                                   [self saveNewPlaylistTitle:[[alert.textFields objectAtIndex:0] text]];
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                               }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"CANCEL"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.text = title;
    }];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)saveNewPlaylistTitle:(NSString *)text
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title == %@",self.playlist.title]];
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    for (Playlist *playlistObject in result) {
        NSLog(@"rename playlist title----------------------");
        playlistObject.title = text;
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            
        } else {
            
            self.navigationItem.title = text;
            [self.tableView reloadData];
        }
    }
}

# pragma mark - editmode

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSNumber *sourceNumber = @(sourceIndexPath.row-1);
    NSNumber *destNumber = @(destinationIndexPath.row-1);
    YoutubeVideo *youtubeVideoToMove = [self.youtubeVideoList objectAtIndex:sourceIndexPath.row-1];
   
    YoutubeVideo *youtubeVideoToSource = [self.youtubeVideoList objectAtIndex:destinationIndexPath.row-1];
    youtubeVideoToSource.index = sourceNumber;
    [self.youtubeVideoList removeObjectAtIndex:sourceIndexPath.row-1];
    [self.youtubeVideoList insertObject:youtubeVideoToMove atIndex:destinationIndexPath.row-1];
    
    NSMutableArray *newList = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i = 0; i < [self.youtubeVideoList count]; i++) {
        YoutubeVideo *y = [self.youtubeVideoList objectAtIndex:i];
        y.index = @(i);
        [newList addObject:y];
        NSLog(@"list: %@ index:%@",y.videoTitle, y.index);
    }
    
    NSSet *newYoutubeVideoList = [NSSet setWithArray:newList];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title == %@",self.playlist.title]];
    
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    for (Playlist *playlistObject in result) {
        NSLog(@"reordering youtube from playlist----------------------");
        //[context deleteObject:playlistObject.youtubeVideos];
        playlistObject.youtubeVideos = newYoutubeVideoList;
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    if (sourceNumber == destNumber) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"updatePlaylistFact"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"updatePlaylistFact"];
        Youtube *youtube = [[Youtube alloc] init];
        //update screen 1
        [self getYt];
        for (int i = 0; i < [self.youtubeVideoList count]; i++) {
            YoutubeVideo *youtubeVideo = [self.youtubeVideoList objectAtIndex:i];
            [youtube.videoIdList addObject:youtubeVideo.videoId];
            [youtube.titleList addObject:youtubeVideo.videoTitle];
            [youtube.thumbnailList addObject:youtubeVideo.videoThumbnail];
            [youtube.durationList addObject:youtubeVideo.videoDuration];
        }
        //NSLog(@"selectedIndex : %lu",(long)sourceIndexPath.row-1);
        //NSLog(@"new youtube list %@",youtube.titleList);
        NSString *selected = [NSString stringWithFormat:@"%lu",(long)sourceIndexPath.row-1];
        NSDictionary *userInfo = @{@"youtubeObj": youtube,
                                   @"selectedIndex": selected};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatePlaylist" object:self userInfo:userInfo];
    }
    
    
}



- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    
    if( proposedDestinationIndexPath.row == 0 ) {
        return [NSIndexPath indexPathForRow:sourceIndexPath.row inSection:proposedDestinationIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}

#pragma mark - delegate PlaylistEditDetailFavoriteController

- (void)addingVideoFromPlayListEditDetailFavorite:(Favorite *)favorite
{

    [self updateYoutubeVideoList];
    //[self.tableView reloadData];
    NSLog(@"Receive from delegate playlisteditdetailfavorite %@",favorite.videoTitle);
    
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
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"YoutubeVideo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"playlist == %@",self.playlist]];

    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
//    
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

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        default:
//            return;
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//    UITableView *tableView = self.tableView;
//    NSIndexPath *customIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
//    NSIndexPath *customNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row-1 inSection:indexPath.section];
//    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[customNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[customIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self.tableView reloadData];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[customIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:@[customNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView endUpdates];
//}

@end
