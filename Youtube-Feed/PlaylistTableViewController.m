//
//  PlaylistTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "PlaylistTableViewController.h"
#import "PlaylistCustomCell.h"
#import "FavoriteTableViewController.h"
#import "PlaylistDetailTableViewController.h"
#import "PlaylistEditTableViewController.h"
#import "MainTabBarViewController.h"
#import "AppDelegate.h"

@interface PlaylistTableViewController ()

@end

@implementation PlaylistTableViewController




- (void)viewDidLoad
{
    [super viewDidLoad];

    self.playlist_List = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self fetchPlaylist];
}



- (void)fetchPlaylist
{
//    NSArray *result = [self.fetchedResultsController fetchedObjects];
//    for (int i = 0; i < result.count; i++) {
//        NSManagedObject *object = [result objectAtIndex:i];
//        [self.playlist_List addObject:object];
//    }
    NSArray *result = [self.fetchedResultsController fetchedObjects];
    self.playlist_List = [NSMutableArray arrayWithArray:result];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 - (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"inside view will appear");

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    if ([sectionInfo numberOfObjects] == 0) {
        return 2;
        
    } else {
        //for favorite and . . . row
        return [sectionInfo numberOfObjects]+2;

    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"PlaylistCustomCell";
    PlaylistCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaylistCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        //add gesture ;
        UILongPressGestureRecognizer *lgpr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleLongPress:)];
        lgpr.minimumPressDuration = 1.5;
        [cell addGestureRecognizer:lgpr];
    }
    
    [self fetchPlaylist];
    if ([self.playlist_List count] == 0) {
        if(indexPath.row == 0) {
            cell.name.text = @"Favorite";
        }else {
            cell.name.text = @" . . . . ";
        }

    } else {
        
        if(indexPath.row == 0) {
            cell.name.text = @"Favorite";
            
        }else {
            if (indexPath.row <= [self.playlist_List count]) {
                
                NSManagedObject *playlist = [self.playlist_List objectAtIndex:indexPath.row-1];
                cell.name.text = [playlist valueForKey:@"playlistTitle"];
                
            }else {
                cell.name.text = @" . . . . ";
            }
        }
        
    }
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 ) {
        [self performSegueWithIdentifier:@"FavoriteSegue" sender:nil];
        
    }else if(indexPath.row == [self.playlist_List count]+1) {
        
        [self createNewPlaylist];
        
    }else {
        NSLog(@"perfrom playlistdetail");
        self.playlist = [self.playlist_List objectAtIndex:indexPath.row-1];
        [self performSegueWithIdentifier:@"PlaylistDetailSegue" sender:nil];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)createNewPlaylist
{
    alert = [UIAlertController alertControllerWithTitle:@"Create New Playlist"
                                                message:@"Type your playlist name"
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
                                                   
                                                   [self saveNewPlaylist:[[alert.textFields objectAtIndex:0] text]];
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
       textField.placeholder = @"New playlist name";
    }];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)saveNewPlaylist:(NSString *)text
{
    NSString *title = text;
    [self insertNewPlaylist:title];
}
- (void)insertNewPlaylist:(NSString *)title
{

    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    [newManagedObject setValue:title forKey:@"playlistTitle"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    if (indexPath == nil) {
        NSLog(@"long press table view but not in row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press began at row %ld", indexPath.row);
        
        alert = [UIAlertController alertControllerWithTitle:@"Delete Video"
                                                    message:@"Are you sure to remove this video from Favorite"
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       
                                                       [self deleteRowAtIndex:indexPath.row];
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
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [context deleteObject:[[self.fetchedResultsController fetchedObjects] objectAtIndex:index-1]];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteFavorite" object:self userInfo:nil];
}


- (IBAction)editButtonPressed:(id)sender
{
    NSLog(@"Edit buttonPressed");
    //[self performSegueWithIdentifier:@"EditSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FavoriteSegue"]){
        
        FavoriteTableViewController *dest = segue.destinationViewController;
        //dest.playlist = self.playlist;
        dest.favorite = self.favorite;
        
    } else if ([segue.identifier isEqualToString:@"PlaylistDetailSegue"]) {
         NSLog(@"prepare playlistdetail");
        PlaylistDetailTableViewController *dest = segue.destinationViewController;
        //dest.playlist = self.playlist;
        
    } else if ([segue.identifier isEqualToString:@"EditSegue"]) {
        NSLog(@"prepare playlistEdit");
        PlaylistEditTableViewController *dest = segue.destinationViewController;
        [self fetchPlaylist];
        dest.playlist_List = self.playlist_List;
        dest.favorite = self.favorite;
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
