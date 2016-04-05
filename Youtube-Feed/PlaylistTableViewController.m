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

@interface PlaylistTableViewController ()<UMAFocusManagerDelegate, UMAAppDiscoveryDelegate, UMAApplicationDelegate>

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

@implementation PlaylistTableViewController
{
    BOOL isAlertShowUp;
    BOOL backFactPlaylist;
    NSInteger indexFocus;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    isAlertShowUp = NO;
    backFactPlaylist = YES;
    self.playlist_List = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self fetchPlaylist];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Playlists", nil)];
    [self.editButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Edit Button", nil)] forState:UIControlStateNormal];
    
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
    NSLog(@"viewDidDisappear PlaylistController");
    [_focusManager setHidden:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    
#pragma setup UMA in ViewDidAppear in RecommendTableView
    [_umaApp addViewController:self];
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    [_focusManager setHidden:NO];
    [_focusManager moveFocus:1];    // Give focus to the first icon.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void)orientationChanged:(NSNotification *)notification
{
    
    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        [_focusManager setFocusRootView:self.tableView];
        [_focusManager setHidden:NO];
        
        if (indexFocus == 24) {
            [_focusManager moveFocus:1];
        } else {
            
            if (indexFocus == 0) {
                [_focusManager moveFocus:2];
            } else {
                [_focusManager moveFocus:indexFocus];
            }
        }
        
    } else {
        
        [_focusManager setFocusRootView:self.tableView];
        [_focusManager setHidden:NO];
        
        if (indexFocus == 24) {
            [_focusManager moveFocus:1];
            
        } else {
            
            if (indexFocus == 0) {
                [_focusManager moveFocus:2];
            } else {
                [_focusManager moveFocus:indexFocus];
            }
            
        }
        
    }
    
}



- (void)fetchPlaylist
{

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
        return 1;
        
    } else {
        //for favorite row
        return [sectionInfo numberOfObjects]+1;

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
//        UILongPressGestureRecognizer *lgpr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
//                                                                                           action:@selector(handleLongPress:)];
//        lgpr.minimumPressDuration = 1.5;
//        [cell addGestureRecognizer:lgpr];
    }
    
    [self fetchPlaylist];
    //NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([self.playlist_List count] == 0) {
        cell.name.text = [NSString stringWithFormat:NSLocalizedString(@"Favorites", nil)];
        
    } else {
        
        if(indexPath.row == 0) {
            cell.name.text = [NSString stringWithFormat:NSLocalizedString(@"Favorites", nil)];
            
        } else {
            
            Playlist *playlist = [self.playlist_List objectAtIndex:indexPath.row-1];
            cell.name.text = playlist.title;
           
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
        
    } else {

        self.playlist = [self.playlist_List objectAtIndex:indexPath.row-1];
        [self performSegueWithIdentifier:@"PlaylistDetailSegue" sender:nil];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        dest.favorite = self.favorite;
        
    } else if ([segue.identifier isEqualToString:@"PlaylistDetailSegue"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSIndexPath *customIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        Playlist *playlistForRow = [[self fetchedResultsController] objectAtIndexPath:customIndexPath];
        PlaylistDetailTableViewController *dest = segue.destinationViewController;
        dest.playlist = playlistForRow;

    } else if ([segue.identifier isEqualToString:@"EditSegue"]) {

        [self fetchPlaylist];
        PlaylistEditTableViewController *dest = segue.destinationViewController;
        dest.playlist_List = self.playlist_List;
        
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

- (BOOL)umaDidRotateWithDistance:(NSUInteger)distance direction:(UMADialDirection)direction
{
    NSLog(@"focus index %ld distance: %lu diraction: %ld",(long)[_focusManager focusIndex], (unsigned long)distance, (long)direction);
    //NSLog(@"in tabbar %id",backFactPlaylist);
    if (backFactPlaylist == 0) {
        
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
    NSLog(@"at index : %ld",(long)[_focusManager focusIndex]);
    if (backFactPlaylist) {
        return YES;
    } else {
        
        if (distanceX == 1 && distanceY == 0) {
            NSLog(@"RIGTH");
            if ([_focusManager focusIndex] == 1) {
                [_focusManager moveFocus:1];
                NSLog(@"after: %ld",(long)[_focusManager focusIndex]);
            } else if ([_focusManager focusIndex] == 3) {
                [_focusManager moveFocus:1];
            }
        }else if (distanceX == -1 && distanceY == 0) {
            NSLog(@"LEFT");
            if ([_focusManager focusIndex] == 0) {
                [_focusManager moveFocus:4];
            } else if ([_focusManager focusIndex] == 3) {
                [_focusManager moveFocus:4];
            }
        }else if (distanceX == 0 && distanceY == 1) {
            NSLog(@"BOTTOM");
            
        }else if (distanceX == 0 && distanceY == -1) {
            NSLog(@"TOP");
            
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

            [alert dismissViewControllerAnimated:YES completion:nil];
            isAlertShowUp = false;
        }
    } else {
        
        if ([[self getButtonName:button] isEqualToString:@"Back"]) {
            //
            
            if (backFactPlaylist) {
                NSLog(@"in tabbar controller");
                [_focusManager setFocusRootView:self.tabBarController.tabBar];
                [_focusManager moveFocus:1];
                backFactPlaylist = NO;
                
            } else {
                
                NSLog(@"in main view");
                [_focusManager setFocusRootView:self.tableView];
                [_focusManager moveFocus:4];
                backFactPlaylist = YES;
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
//    NSLog(@"Long press %ld", (long)[_focusManager focusIndex]);
//    if ([_focusManager focusIndex] > 0 && [_focusManager focusIndex] < [self.playlist_List count] + 1) {
//        NSLog(@"can delete able");
//            NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Delete this playlist", nil)];
//        
//            alert = [UIAlertController alertControllerWithTitle:@""
//                                                        message:description
//                                                 preferredStyle:UIAlertControllerStyleAlert];
//        
//            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
//                                                         style:UIAlertActionStyleDefault
//                                                       handler:^(UIAlertAction *action){
//        
////                                                           [self deleteRowAtIndex:[_focusManager focusIndex]];
//                                                           [alert dismissViewControllerAnimated:YES completion:nil];
//                                                       }];
//        
//            [alert addAction:ok];
//            [self presentViewController:alert animated:YES completion:nil];
//            isAlertShowUp = YES;
//    }
//
//

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
