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

static NSString *const kSettingsManualConnectionTitle = @"Manual Connection";
static NSString *const kSettingsManualConnectionSubTitle =
@"Be able to select a device which you want to connect.";
static NSString *const kDeviceNone = @"No Name";
static NSString *const kAddressNone = @"No Address";

static const NSInteger kNumberOfSectionsInTableView = 4;
static NSString *const kRowNum = @"rowNum";
static NSString *const kHeaderText = @"headerText";
static NSString *const kTitleText = @"HID Device Sample";
static const NSInteger kHeightForHeaderInSection = 33;
static const NSTimeInterval kHidDeviceControlTimeout = 5;
NSString *const kIsManualConnection = @"is_manual_connection";

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface FavoriteTableViewController ()<UMAFocusManagerDelegate, UMAAppDiscoveryDelegate, UMAApplicationDelegate>

@property (nonatomic, strong) UMAFocusManager *focusManager;
@property (nonatomic, strong) NSArray *applications;
@property (nonatomic) BOOL remoteScreen;
@property (nonatomic) UMAApplication *umaApp;
@property (nonatomic) UMAHIDManager *hidManager;
@property (nonatomic) UMAInputDevice *connectedDevice;
@property (copy, nonatomic) void (^discoveryBlock)(UMAInputDevice *, NSError *);
@property (copy, nonatomic) void (^connectionBlock)(UMAInputDevice *, NSError *);
@property (copy, nonatomic) void (^disconnectionBlock)(UMAInputDevice *, NSError *);
@property (nonatomic) NSMutableArray *inputDevices;

@end

@implementation FavoriteTableViewController
{
    BOOL isAlertShowUp;
    NSInteger indexFocus;
    NSInteger indexFocusTabbar;
    NSInteger numberOfFavorites;
    BOOL backFactFavorite;
    BOOL portraitFact;
    BOOL landscapeFact;
    BOOL didReceivedFromYoutubePlaying;
    BOOL currentPlayingFact;
    NSArray *youtubeFavorite;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isAlertShowUp = NO;
    indexFocusTabbar = 1;
    numberOfFavorites = 0;
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Favorites", nil)];

    //fetchdata for checking when youtube is playing
    youtubeFavorite = [self.fetchedResultsController fetchedObjects];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedYoutubePlayingNotification:)
                                                 name:@"YoutubePlaying" object:nil];

#pragma setup UMA in ViewDidload in PlaylistTableView
    _umaApp = [UMAApplication sharedApplication];
    _umaApp.delegate = self;
    [_umaApp addViewController:self];
    
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    [_focusManager setHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
 
    didReceivedFromYoutubePlaying = false;
    [_focusManager setHidden:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if (![[self.navigationController viewControllers] containsObject:self]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"YoutubePlaying" object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    backFactFavorite = YES;
    portraitFact = YES;
    landscapeFact = YES;

#pragma setup UMA in ViewDidAppear in RecommendTableView
    [_umaApp addViewController:self];
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    if (numberOfFavorites == 0) {
        [_focusManager setHidden:YES];
    } else {
        [_focusManager setHidden:NO];
        [_focusManager moveFocus:1];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    backFactFavorite = YES;

}


- (void)receivedYoutubePlayingNotification:(NSNotification *)notification
{
    NSInteger selectedIndex = [[notification.userInfo objectForKey:@"youtubeCurrentPlaying"] integerValue];
    self.favoritePlaying = [[notification.userInfo objectForKey:@"favoriteFact"] boolValue];

    if (self.favoritePlaying) {
        self.selectedRow = selectedIndex;
        [self.tableView reloadData];
    }
    //NSLog(@"Recevied in favorite %i",self.favoritePlaying);
}

- (void)orientationChanged:(NSNotification *)notification
{
    NSLog(@"View changing");
    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        if (portraitFact) {
            if (backFactFavorite) {
                [_focusManager setFocusRootView:self.tableView];
                [_focusManager setHidden:NO];
                if (indexFocus == numberOfFavorites-1) {
                    [_focusManager moveFocus:1];
                } else {
                    
                    if (indexFocus == 0) {
                        [_focusManager moveFocus:1];
                    } else {
                        [_focusManager moveFocus:indexFocus];
                    }
                    
                }
            } else {
                
                [_focusManager setFocusRootView:self.tabBarController.tabBar];
                [_focusManager setHidden:NO];
                [_focusManager moveFocus:indexFocusTabbar];
                
            }
            portraitFact = NO;
            landscapeFact = YES;
        }
        
    } else {
        if (landscapeFact) {
            if (backFactFavorite) {
                
                [_focusManager setFocusRootView:self.tableView];
                [_focusManager setHidden:NO];
                if (indexFocus == numberOfFavorites-1) {
                    [_focusManager moveFocus:1];
                } else {
                    
                    if (indexFocus == 0) {
                        [_focusManager moveFocus:1];
                    } else {
                        [_focusManager moveFocus:indexFocus];
                    }
                    
                }
            } else {
                
                [_focusManager setFocusRootView:self.tabBarController.tabBar];
                [_focusManager setHidden:NO];
                [_focusManager moveFocus:indexFocusTabbar];
                
            }
            portraitFact = YES;
            landscapeFact = NO;
        }
        
    }
    
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
    numberOfFavorites = [sectionInfo numberOfObjects];
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
    
    if (self.favoritePlaying) {
        if (indexPath.row == self.selectedRow) {
            cell.contentView.backgroundColor = UIColorFromRGB(0xFFCCCC);
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.name.text = [object valueForKey:@"videoTitle"];
    cell.favoriteIcon.hidden = NO;
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
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Delete this item from favorites", nil)];

        alert = [UIAlertController alertControllerWithTitle:@""
                                                    message:description
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
        [youtube.durationList addObject:[manageObject valueForKey:@"videoDuration"]];
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
        [youtube.durationList addObject:[manageObject valueForKey:@"videoDuration"]];
    }
    
    NSString *selected = [NSString stringWithFormat:@"%lu",self.selectedRow];
    NSDictionary *userInfo = @{@"youtubeObj": youtube,
                               @"selectedIndex": selected};

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



- (BOOL)umaDidRotateWithDistance:(NSUInteger)distance direction:(UMADialDirection)direction
{

    if (backFactFavorite == 0) {
        
        if (direction == 1) {
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 4;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 1;
            }
        } else {
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 4;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 1;
            }
            
            
        }

        if ([_focusManager focusIndex] == 3 && distance == 1 && direction == 0) {
            NSLog(@"search");
            [_focusManager moveFocus:1];
            
        } else if ([_focusManager focusIndex] == 0 && distance == 1 && direction == 1) {
            NSLog(@"search");
            [_focusManager moveFocus:4];
            
        } else if ([_focusManager focusIndex] == 3 && distance == 1 && direction == 1) {
            NSLog(@"search");
            [_focusManager moveFocus:4];
            
        } else if ([_focusManager focusIndex] == 1 && distance == 1 && direction == 0) {
            NSLog(@"search");
            [_focusManager moveFocus:1];
            
        }
        
    }
    
    indexFocus = [_focusManager focusIndex];
    if (direction == 0) {
        indexFocus+=2;
    }
    
    return NO;
}

- (BOOL)umaDidTranslateWithDistance:(NSInteger)distanceX distanceY:(NSInteger)distanceY
{
   
    if (backFactFavorite) {
        return YES;
    } else {
        
        if (distanceX == 1 && distanceY == 0) {
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 4;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 1;
            }

            if ([_focusManager focusIndex] == 1) {
                [_focusManager moveFocus:1];
            } else if ([_focusManager focusIndex] == 3) {
                [_focusManager moveFocus:1];
            }
            
        }else if (distanceX == -1 && distanceY == 0) {
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 4;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 1;
            }
            
            if ([_focusManager focusIndex] == 0) {
                [_focusManager moveFocus:4];
            } else if ([_focusManager focusIndex] == 3) {
                [_focusManager moveFocus:4];
            }
        }
        return NO;
        
    }
}



- (NSString *)getButtonName:(UMAInputButtonType)button
{
    switch (button) {
        case kUMAInputButtonTypeBack:
            return @"Back";
        case kUMAInputButtonTypeDown:
            return @"Down";
        case kUMAInputButtonTypeHome:
            return @"Home";
        case kUMAInputButtonTypeLeft:
            return @"Left";
        case kUMAInputButtonTypeMain:
            return @"Main";
        case kUMAInputButtonTypeRight:
            return @"Right";
        case kUMAInputButtonTypeUp:
            return @"UP";
        case kUMAInputButtonTypeVR:
            return @"VR";
        default:
            return @"Unknown";
    }
}

#pragma mark - UMARemoteInputEventDelegate

- (BOOL)umaDidPressDownButton:(UMAInputButtonType)button
{
    NSLog(@"Press Down in Playlist");
    return YES;
}


- (BOOL)umaDidPressUpButton:(UMAInputButtonType)button
{
    NSLog(@"Press up in playlist");
    if (isAlertShowUp) {
        if ([[self getButtonName:button] isEqualToString:@"Back"]) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            isAlertShowUp = false;
        } else if ([[self getButtonName:button] isEqualToString:@"Main"]) {
            [self deleteRowAtIndex:[_focusManager focusIndex]];
            [alert dismissViewControllerAnimated:YES completion:nil];
            isAlertShowUp = false;
        }
    } else {
        if ([[self getButtonName:button] isEqualToString:@"Back"]) {
            //
            
            if (backFactFavorite) {
                NSLog(@"in tabbar controller");
                [_focusManager setFocusRootView:self.tabBarController.tabBar];
                [_focusManager setHidden:NO];
                [_focusManager moveFocus:1];
                backFactFavorite = NO;
                
            } else {
                
                NSLog(@"in main view");
                [_focusManager setFocusRootView:self.tableView];
                [_focusManager moveFocus:1];
               
                backFactFavorite = YES;
            }
            
        } else if ([[self getButtonName:button] isEqualToString:@"Main"]) {
            return NO;
            
        } else if ([[self getButtonName:button] isEqualToString:@"VR"]) {
            
            return YES;
        }

    
    }
    return YES;
}

- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button
{
    NSLog(@"Long press %@ at %ld", [self getButtonName:button], (long)[_focusManager focusIndex]);
    NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Delete this item from favorites", nil)];

    alert = [UIAlertController alertControllerWithTitle:@""
                                                        message:description
                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){
    
                                                           [self deleteRowAtIndex:[_focusManager focusIndex]];
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];

    [alert addAction:ok];
    //[alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    isAlertShowUp = YES;
    return YES;
}

- (BOOL)umaDidDoubleClickButton:(UMAInputButtonType)button
{
    NSLog(@"Double click %@", [self getButtonName:button]);
    return YES;
}

- (void)umaDidAccelerometerUpdate:(UMAAcceleration)acceleration
{
    NSLog(@"Accer x=%f, y=%f, z=%f", acceleration.x, acceleration.y, acceleration.z);
}




#pragma mark - UMAAppDiscoveryDelegate
- (void)didDiscoverySucceed:(NSArray *)appInfo
{
    NSLog(@"didDiscoverySucceed");
    if(appInfo) {
        int i = 0;
        for (UMAApplicationInfo *app in appInfo) {
            NSLog(@"-------------[app(%d)]----------------",i);
            NSLog(@"id    :%@",[app stringProperty:PROP_APP_ID withDefault:@"-"]);
            NSLog(@"name  :%@",[app stringProperty:PROP_APP_NAME withDefault:@"-"]);
            NSLog(@"cname :%@",[app stringProperty:PROP_APP_VENDOR withDefault:@"-"]);
            NSLog(@"text  :%@",[app stringProperty:PROP_APP_DESCRIPTION withDefault:@"-"]);
            NSLog(@"cat   :%@",[app stringProperty:PROP_APP_CATEGORY withDefault:@"-"]);
            NSLog(@"url   :%@",[app stringProperty:PROP_APP_URL withDefault:@"-"]);
            NSLog(@"schema:%@",[app stringProperty:PROP_APP_SCHEMA withDefault:@"-"]);
            NSLog(@"icon  :%@",[app stringProperty:PROP_APP_ICON_URL withDefault:@"-"]);
            NSLog(@"new   :%d",[app integerProperty:PROP_APP_NEW withDefault:-1]);
            NSLog(@"recmt :%d",[app integerProperty:PROP_APP_RECMD withDefault:-1]);
            NSLog(@"date  :%@",[app stringProperty:PROP_APP_DATE withDefault:@"-"]);
            NSLog(@"dev2  :%d",[app integerProperty:PROP_APP_DEV2 withDefault:-1]);
            NSLog(@"drive :%d",[app integerProperty:PROP_APP_DRIVE withDefault:-1]);
            i++;
        }
    }
}
#pragma mark - UMAApplicationDelegate

- (UIViewController *)uma:(UMAApplication *)application requestRootViewController:(UIScreen *)screen {
    // This sample does not use this delegate
    return nil;
}

- (void)didDiscoveryFail:(int)reason withMessage:(NSString *)message;
{
    NSLog(@"app discovery failed. (%@)", message);
}
- (void)uma:(UMAApplication *)application didConnectInputDevice:(UMAInputDevice *)device
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)uma:(UMAApplication *)application didDisconnectInputDevice:(UMAInputDevice *)device
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
