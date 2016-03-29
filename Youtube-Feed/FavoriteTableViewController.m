//
//  FavoriteTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "FavoriteTableViewController.h"
#import "FavoriteCustomCell.h"
#import "RecommendCustomCell.h"
#import "AppDelegate.h"

@interface FavoriteTableViewController ()

@end

@implementation FavoriteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    NSLog(@"favorite view did load");
}

- (void)fetchData
{
    NSArray *result = [self.fetchedResultsController fetchedObjects];
    for (int i = 0; i < result.count; i++) {
        NSManagedObject *object = [result objectAtIndex:i];
        NSLog(@"check favorite %@", [object valueForKey:@"videoTitle"]);
    }
}



- (void)insertObjectWithFavorite:(NSString *)videoId withTitle:(NSString *)videoTitle andWithThumbnail:(NSString *)videoThumbnail
{

        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
        [newManagedObject setValue:videoId forKey:@"videoId"];
        [newManagedObject setValue:videoTitle forKey:@"videoTitle"];
        [newManagedObject setValue:videoThumbnail forKey:@"videoThumbnail"];
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //fetch data
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
        
        
        //add gesture ;
        UILongPressGestureRecognizer *lgpr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleLongPress:)];
        lgpr.minimumPressDuration = 1.5;
        [cell addGestureRecognizer:lgpr];
        
    }
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.name.text = [object valueForKey:@"videoTitle"];
    cell.favoriteIcon.hidden = YES;
    cell.tag = indexPath.row;
    cell.durationLabel.text = [self durationText:[object valueForKey:@"videoDuration"]];
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
    [context deleteObject:[[self.fetchedResultsController fetchedObjects] objectAtIndex:index]];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSArray *result = [self.fetchedResultsController fetchedObjects];
    Youtube *youtube = [[Youtube alloc] init];
    
    for (NSManagedObject *manageObject in result) {
        [youtube.videoIdList addObject:[manageObject valueForKey:@"videoId"]];
        [youtube.titleList addObject:[manageObject valueForKey:@"videoTitle"]];
        [youtube.thumbnailList addObject:[manageObject valueForKey:@"videoThumbnail"]];
    }
    
    NSString *selected = [NSString stringWithFormat:@"%lu",self.selectedRow];
    NSDictionary *userInfo = @{@"youtubeObj": youtube,
                               @"selectedIndex": selected};

    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteFavorite" object:self userInfo:userInfo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;

    NSArray *result = [self.fetchedResultsController fetchedObjects];
    Youtube *youtube = [[Youtube alloc] init];
    
    for (NSManagedObject *manageObject in result) {
        [youtube.videoIdList addObject:[manageObject valueForKey:@"videoId"]];
        [youtube.titleList addObject:[manageObject valueForKey:@"videoTitle"]];
        [youtube.thumbnailList addObject:[manageObject valueForKey:@"videoThumbnail"]];
    }
    
    NSString *selected = [NSString stringWithFormat:@"%lu",self.selectedRow];
    NSDictionary *userInfo = @{@"youtubeObj": youtube,
                               @"selectedIndex": selected};
    NSLog(@"post favorite");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FavoriteDidSelected" object:self userInfo:userInfo];
    [self.tabBarController setSelectedIndex:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    
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
