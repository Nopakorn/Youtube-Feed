//
//  GenreTableViewController.m
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 3/22/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "GenreTableViewController.h"
#import "GenreListTableViewController.h"
#import "SettingCustomCell.h"
#import "AppDelegate.h"
#import "MainTabBarViewController.h"

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

@interface GenreTableViewController ()<UMAFocusManagerDelegate, UMAAppDiscoveryDelegate, UMAApplicationDelegate>

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

@implementation GenreTableViewController
{
    BOOL backFactGenre;
    BOOL portraitFact;
    BOOL landscapeFact;
    NSInteger indexFocus;
    NSInteger indexFocusTabbar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.genreYoutube = [[Youtube alloc] init];
    backFactGenre = YES;
    indexFocusTabbar = 1;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self createGerne];
     NSLog(@"View did load");
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Genre", nil)];
    //self.genreIconTitle.hidden = YES;
//    UIImage *imageGenre = [UIImage imageNamed:@"genre1"];
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:imageGenre];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedYoutubePlayingNotification:)
                                                 name:@"YoutubePlaying" object:nil];
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x3B4C4E);
#pragma setup UMA in ViewDidload in GenreTableView
    _umaApp = [UMAApplication sharedApplication];
    _umaApp.delegate = self;
    [_umaApp addViewController:self];
    
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    [_focusManager setHidden:NO];
}

- (void)receivedYoutubePlayingNotification:(NSNotification *)notification
{
    NSInteger selectedIndex = [[notification.userInfo objectForKey:@"youtubeCurrentPlaying"] integerValue];
    self.genreListPlaying = [[notification.userInfo objectForKey:@"genreListFact"] boolValue];
    NSString *genreTypeString = [notification.userInfo objectForKey:@"genreType"];
    if (self.genreListPlaying) {

        if ([genreTypeString isEqualToString:self.searchTerm]) {
            self.genreType = genreTypeString;
            self.selectedIndex = selectedIndex;
        }
    }
  
    
    NSLog(@"Recevied in genre %@ index %li",self.genreType, (long)self.selectedIndex);
}

- (void)viewDidAppear:(BOOL)animated
{
    self.genreYoutube = [[Youtube alloc] init];
    NSLog(@"View did appear");
    portraitFact = YES;
    landscapeFact = YES;
#pragma setup UMA in ViewDidAppear in GenreTableView
    [_umaApp addViewController:self];
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    [_focusManager setHidden:NO];
    [_focusManager moveFocus:1];    // Give focus to the first icon.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear GenreController");
    [_focusManager setHidden:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)orientationChanged:(NSNotification *)notification
{
    NSLog(@"View changing");
    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        if (portraitFact) {
            if (backFactGenre) {
                [_focusManager setFocusRootView:self.tableView];
                [_focusManager setHidden:NO];
                if (indexFocus == 24) {
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
            if (backFactGenre) {
                
                [_focusManager setFocusRootView:self.tableView];
                [_focusManager setHidden:NO];
                if (indexFocus == 24) {
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



- (void)createGerne
{
    MainTabBarViewController *tabbar = (MainTabBarViewController *)self.tabBarController;
    self.genreList = tabbar.genreTitles;
    
    NSLog(@"count in create %lu",(unsigned long)[self.genreList count]);
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

    return [self.genreList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentifier = @"SettingCustomCell";
    
    SettingCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SettingCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.type.text = [self.genreList objectAtIndex:indexPath.row];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.searchTerm = [self.genreList objectAtIndex:indexPath.row];
    [self callYoutube:self.searchTerm];
}


- (void)callYoutube:(NSString *)searchTerm
{
    self.genreYoutube = [[Youtube alloc] init];
    [self.genreYoutube getGenreSearchYoutube:searchTerm withNextPage:NO];
    
    alert = [UIAlertController alertControllerWithTitle:nil message:@"Loading\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(130.5, 65.5);
    spinner.color = [UIColor blackColor];
    [alert.view addSubview:spinner];
    [spinner startAnimating];
    [self presentViewController:alert animated:NO completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadGenreVideoId)
                                                 name:@"LoadGenreVideoId" object:nil];
}


- (void)receivedLoadGenreVideoId
{
    NSLog(@"received load");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadGenreVideoId" object:nil];
        [alert dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"SubmitGenre" sender:nil];
    });
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SubmitGenre"]){
        NSLog(@"perform genre");
        GenreListTableViewController *dest = segue.destinationViewController;
        dest.genreYoutube = self.genreYoutube;
        dest.searchTerm = self.searchTerm;
        dest.genreType = self.genreType;
        dest.selectedIndex = self.selectedIndex;
    }
}



- (BOOL)umaDidRotateWithDistance:(NSUInteger)distance direction:(UMADialDirection)direction
{
    NSLog(@"focus index %ld distance: %lu diraction: %ld",(long)[_focusManager focusIndex], (unsigned long)distance, (long)direction);
    //NSLog(@"in tabbar %id",backFactPlaylist);
    if (backFactGenre == 0) {
        
        if (direction == 1) {
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 3;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 1;
            }else if ([_focusManager focusIndex] == 2) {
                indexFocusTabbar = 2;
            }
        } else {
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 3;
            }else if ([_focusManager focusIndex] == 2) {
                indexFocusTabbar = 1;
            }
            
            
        }

        if ([_focusManager focusIndex] == 3 && distance == 1 && direction == 0) {
            [_focusManager moveFocus:1];
            
        } else if ([_focusManager focusIndex] == 0 && distance == 1 && direction == 1) {
            [_focusManager moveFocus:3];
            
        }  else if ([_focusManager focusIndex] == 2 && distance == 1 && direction == 0) {
            [_focusManager moveFocus:2];
            
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
    if (backFactGenre) {
        return YES;
    } else {
        
        if (distanceX == 1 && distanceY == 0) {
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 3;
            }else if ([_focusManager focusIndex] == 2) {
                indexFocusTabbar = 1;
            }

            if ([_focusManager focusIndex] == 2) {
                [_focusManager moveFocus:2];
                NSLog(@"after: %ld",(long)[_focusManager focusIndex]);
            } else if ([_focusManager focusIndex] == 3) {
                [_focusManager moveFocus:1];
            }
        }else if (distanceX == -1 && distanceY == 0) {
            NSLog(@"LEFT");
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 3;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 1;
            }else if ([_focusManager focusIndex] == 2) {
                indexFocusTabbar = 2;
            }

            if ([_focusManager focusIndex] == 0) {
                [_focusManager moveFocus:3];
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

    return YES;
}



- (BOOL)umaDidPressUpButton:(UMAInputButtonType)button
{

    if ([[self getButtonName:button] isEqualToString:@"Back"]) {
        //
        NSLog(@"Reccomened Current view in focus %@", [_focusManager focusedView]);
        if (backFactGenre) {
            NSLog(@"in tabbar controller");
            [_focusManager setFocusRootView:self.tabBarController.tabBar];
            [_focusManager moveFocus:1];
            backFactGenre = NO;
            
        } else {
            
            NSLog(@"in main view");
            [_focusManager setFocusRootView:self.tableView];
            [_focusManager moveFocus:1];
            backFactGenre = YES;
        }
        
    } else if ([[self getButtonName:button] isEqualToString:@"Main"]) {
         [_focusManager setHidden:YES];
        return NO;
        
    } else if ([[self getButtonName:button] isEqualToString:@"VR"]) {
        
        return YES;
    }
    return YES;
}

- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button
{
    NSLog(@"Long press %@", [self getButtonName:button]);
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
