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
    [self createPlaylist];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    //[self insertNewObject];
    //[self fetchData];
}

- (void)fetchData
{
    NSArray *result = [self.fetchedResultsController fetchedObjects];
    for (int i = 0; i < result.count; i++) {
        NSManagedObject *object = [result objectAtIndex:i];
        NSLog(@"check result %@", [object valueForKey:@"playlistTitle"]);
    }
    //NSManagedObject *object = [[self.fetchedResultsController fetchedObjects] objectAtIndex:0];

}
- (void)insertNewObject
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

    [newManagedObject setValue:@"Playlist 3" forKey:@"playlistTitle"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)createPlaylist
{
    NSString *title1 = @"Play List 1";
    Playlist *pav1 = [[Playlist alloc] init];
    [pav1 setTitle:title1];
    for (int i = 0; i < 10; i++) {
        [pav1 addPlaylistWithTitle:[self.youtube.titleList objectAtIndex:i] thumbnail:[self.youtube.thumbnailList objectAtIndex:i] andVideoId:[self.youtube.videoIdList objectAtIndex:i]];
    }
    [self.playlist_List addObject:pav1];
    
    NSString *title2 = @"Play List 2";
    Playlist *pav2 = [[Playlist alloc] init];
    [pav2 setTitle:title2];
    for (int i = 10; i < 20; i++) {
        [pav2 addPlaylistWithTitle:[self.youtube.titleList objectAtIndex:i] thumbnail:[self.youtube.thumbnailList objectAtIndex:i] andVideoId:[self.youtube.videoIdList objectAtIndex:i]];
    }
     [self.playlist_List addObject:pav2];
    
    NSString *title3 = @"Play List 3";
    Playlist *pav3 = [[Playlist alloc] init];
    [pav3 setTitle:title3];
    [self.playlist_List addObject:pav3];
    
    NSLog(@"index list %lu",(unsigned long)[self.playlist_List count]);
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
    
    if ([self.playlist_List count] == 0) {
        return 2;
        
    } else {
        //for favorite and . . . row
        return [self.playlist_List count]+2;

    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"PlaylistCustomCell";
    PlaylistCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaylistCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
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
                
                Playlist *playlist = [self.playlist_List objectAtIndex:indexPath.row-1];
                cell.name.text = playlist.playTitle;
                
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
    Playlist *playlist = [[Playlist alloc] init];
    [playlist setTitle:title];
    [self.playlist_List addObject:playlist];
    [self.tableView reloadData];
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
        dest.playlist = self.playlist;
        dest.favorite = self.favorite;
        
    } else if ([segue.identifier isEqualToString:@"PlaylistDetailSegue"]) {
         NSLog(@"prepare playlistdetail");
        PlaylistDetailTableViewController *dest = segue.destinationViewController;
        dest.playlist = self.playlist;
        
    } else if ([segue.identifier isEqualToString:@"EditSegue"]) {
        NSLog(@"prepare playlistEdit");
        PlaylistEditTableViewController *dest = segue.destinationViewController;
        dest.playlist_List = self.playlist_List;
        dest.favorite = self.favorite;
    }
    
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"playlistTitle" ascending:NO];
    
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
