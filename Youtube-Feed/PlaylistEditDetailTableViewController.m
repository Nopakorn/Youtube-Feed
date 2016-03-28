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

@interface PlaylistEditDetailTableViewController ()

@end

@implementation PlaylistEditDetailTableViewController

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
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title == %@",self.playlist.title]];
    
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    for (Playlist *playlistObject in result) {
        NSLog(@"received youtube from playlist");
        self.youtubeVideoList = [NSMutableArray arrayWithArray:playlistObject.youtubeVideos.allObjects];
    }
    [self.tableView reloadData];
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

- (void)viewDidDisappear:(BOOL)animated
{
     NSLog(@"view did Disappear playlisteditdetail");
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
        NSString *message = [NSString stringWithFormat:@"Are you sure to remove this video from %@",self.playlist.title];
        
        alert = [UIAlertController alertControllerWithTitle:@"Delete Video"
                                                    message:message
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
    //youtubeVideoToMove.index = destNumber;
   
    YoutubeVideo *youtubeVideoToSource = [self.youtubeVideoList objectAtIndex:destinationIndexPath.row-1];
    youtubeVideoToSource.index = sourceNumber;
    [self.youtubeVideoList removeObjectAtIndex:sourceIndexPath.row-1];
//     [self.youtubeVideoList removeObjectAtIndex:destinationIndexPath.row-1];
    [self.youtubeVideoList insertObject:youtubeVideoToMove atIndex:destinationIndexPath.row-1];
    NSMutableArray *newList = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i = 0; i < [self.youtubeVideoList count]; i++) {
        YoutubeVideo *y = [self.youtubeVideoList objectAtIndex:i];
        y.index = @(i);
        [newList addObject:y];
        NSLog(@"list: %@ index:%@",y.videoTitle, y.index);
    }
    
    NSSet *newYoutubeVideoList = [NSSet setWithArray:newList];
    //NSOrderedSet *oderedSet = [NSOrderedSet orderedSetWithArray:self.youtubeVideoList];
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
