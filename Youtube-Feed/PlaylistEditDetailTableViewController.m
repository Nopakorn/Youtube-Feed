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
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setEditing:YES animated:YES];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.navigationItem.title = self.playlist.playlistTitle;
    //[self fetchPlaylist];
}

//- (void)fetchPlaylist
//{
//    NSLog(@"fetch playlist");
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    NSManagedObjectContext *context = [appDelegate managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:context]];
//    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"playlistTitle == %@",self.playlist.playlistTitle]];
//     NSArray *result = [self.fetchedResultsController fetchedObjects];
//    
//    for (NSManagedObject *manageObject in result) {
//        if ([manageObject valueForKey:@"videoIdList"] != nil) {
//            self.playlist.videoIdList = [NSKeyedUnarchiver unarchiveObjectWithData:[manageObject valueForKey:@"videoIdList"]];
//            self.playlist.videoTitleList = [NSKeyedUnarchiver unarchiveObjectWithData:[manageObject valueForKey:@"videoTitleList"]];
//            self.playlist.videoThumbnail = [NSKeyedUnarchiver unarchiveObjectWithData:[manageObject valueForKey:@"videoThumbnail"]];
//        } else {
//            NSLog(@"playlist has nil object time:%@ title:%@",[manageObject valueForKey:@"timeStamp"], [manageObject valueForKey:@"playlistTitle"]);
//        }
//       
//    }
//}
//
//- (void)insertPlaylist:(Favorite *)favorite
//{
//    
//    //[self.playlist addPlaylistWithTitle:favorite.videoTitle thumbnail:favorite.videothumbnail andVideoId:favorite.videoId];
//    NSLog(@"save playlist at title %@",self.playlist.playlistTitle);
//    [self.playlist.videoIdList addObject:favorite.videoId];
//    [self.playlist.videoTitleList addObject:favorite.videoTitle];
//    [self.playlist.videoThumbnail addObject:favorite.videoThumbnail];
//    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    NSManagedObjectContext *context = [appDelegate managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:context]];
//    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"playlistTitle == %@",self.playlist.playlistTitle]];
//    NSArray *result = [self.fetchedResultsController fetchedObjects];
//    
//    NSData *videoIdListData = [NSKeyedArchiver archivedDataWithRootObject:self.playlist.videoIdList];
//    NSData *videoTitleListData = [NSKeyedArchiver archivedDataWithRootObject:self.playlist.videoTitleList];
//    NSData *videoThumbnailData = [NSKeyedArchiver archivedDataWithRootObject:self.playlist.videoThumbnail];
//    
//    for (NSManagedObject *manageObject in result) {
//        [manageObject setValue:[NSDate date] forKey:@"timeStamp"];
//        [manageObject setValue:videoIdListData forKey:@"videoIdList"];
//        [manageObject setValue:videoTitleListData forKey:@"videoTitleList"];
//        [manageObject setValue:videoThumbnailData forKey:@"videoThumbnail"];
//        // Save the context.
//        NSError *error = nil;
//        if (![context save:&error]) {
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        } else {
//            NSLog(@"update data");
//        }
//    }
//
//}
//

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view did appear playlisteditdetail");
    //[self fetchPlaylist];
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
    //id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    if (self.playlist.videoIdList == nil) {
        return 1;
    } else {
        //NSLog(@"playlist count %lu",(unsigned long)[self.playlist.videoIdList count]);
        return 1;
    }
    
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
        cell.name.text = self.playlist.playlistTitle;
        
        
    }else {
        cell.name.text = [self.playlist.videoTitleList objectAtIndex:indexPath.row-1];
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
        dest.favorite = self.favorite;
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
        NSString *message = [NSString stringWithFormat:@"Are you sure to remove this video from %@",self.playlist.playlistTitle];
        
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
    [self.playlist.videoIdList removeObjectAtIndex:index];
    [self.playlist.videoTitleList removeObjectAtIndex:index];
    [self.playlist.videoThumbnail removeObjectAtIndex:index];
    [self.tableView reloadData];
    
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
    NSString *videoTitleToMove = [self.playlist.videoTitleList objectAtIndex:sourceIndexPath.row-1];
    NSString *videoIdToMove = [self.playlist.videoIdList objectAtIndex:sourceIndexPath.row-1];
    NSString *videoThumbnailToMove = [self.playlist.videoThumbnail objectAtIndex:sourceIndexPath.row-1];
    
    [self.playlist.videoIdList removeObjectAtIndex:sourceIndexPath.row-1];
    [self.playlist.videoTitleList removeObjectAtIndex:sourceIndexPath.row-1];
    [self.playlist.videoThumbnail removeObjectAtIndex:sourceIndexPath.row-1];
    
    [self.playlist.videoIdList insertObject:videoIdToMove atIndex:destinationIndexPath.row-1];
    [self.playlist.videoTitleList insertObject:videoTitleToMove atIndex:destinationIndexPath.row-1];
    [self.playlist.videoThumbnail insertObject:videoThumbnailToMove atIndex:destinationIndexPath.row-1];
    
    
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
   
    //self.playlist = playlist;
    //[self insertPlaylist:favorite];
    //[self fetchPlaylist];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    
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
    NSIndexPath *customIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    NSIndexPath *customNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row+1 inSection:indexPath.section];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[customNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[customIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadData];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[customIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[customNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
