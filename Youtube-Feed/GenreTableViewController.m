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

static NSString *const kRowNum = @"rowNum";
static NSString *const kHeaderText = @"headerText";
static NSString *const kTitleText = @"HID Device Sample";

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
    BOOL scrollKKPTriggered;
    NSInteger indexFocus;
    NSInteger indexFocusTabbar;
    BOOL viewFact;
    NSInteger directionFocus;
    BOOL internetActive;
    BOOL hostActive;
    BOOL reloadFact;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.genreYoutube = [[Youtube alloc] init];
    backFactGenre = YES;
    scrollKKPTriggered = YES;
    internetActive = NO;
    hostActive = NO;
    reloadFact = NO;
    
    indexFocusTabbar = 1;
    directionFocus = 0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self createGerne];

    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Genre", nil)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedYoutubePlayingNotification:)
                                                 name:@"YoutubePlaying" object:nil];
    
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x4F6366);

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
  
}

- (void)viewDidAppear:(BOOL)animated
{
    self.genreYoutube = [[Youtube alloc] init];

    portraitFact = YES;
    landscapeFact = YES;
    viewFact = YES;
    backFactGenre = YES;
    internetActive = NO;
    hostActive = NO;
    reloadFact = NO;
    indexFocus = 1;
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 5)];
    navBorder.tag = 99;
    [navBorder setBackgroundColor:UIColorFromRGB(0x4F6366)];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    hostReachable = [Reachability reachabilityWithHostName:@"www.youtube.com"];
    [hostReachable startNotifier];

#pragma setup UMA in ViewDidAppear in GenreTableView
    [_umaApp addViewController:self];
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    [_focusManager setHidden:NO];
    [_focusManager moveFocus:1];    // Give focus to the first icon.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable:
        {

            internetActive = NO;
            break;
            
        }
        case ReachableViaWiFi:
        {

            internetActive = YES;
            break;
            
        }
        case ReachableViaWWAN:
        {
            internetActive = YES;
            break;
            
        }
            
            
        default:
            break;
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {

            hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {

            hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            
            hostActive = YES;
            
            break;
        }
    }
    
    [self showingNetworkStatus];
    
}

- (void)showingNetworkStatus
{
    if (internetActive) {
        if(reloadFact){
            [alert dismissViewControllerAnimated:YES completion:nil];
            [self callYoutube:self.searchTerm];
            reloadFact = NO;
        }
        
    } else {
       reloadFact = YES;
       [alert dismissViewControllerAnimated:YES completion:nil];
       [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadGenreVideoId" object:nil];
    }
    
}




- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [_focusManager setHidden:YES];
    viewFact = NO;
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if (subView.tag == 99) {
            [subView removeFromSuperview];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)orientationChanged:(NSNotification *)notification
{

    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        if (scrollKKPTriggered) {
            if (portraitFact) {
                if (backFactGenre) {
                    [_focusManager setFocusRootView:self.tableView];
                    [_focusManager setHidden:NO];
                    if (indexFocus == 24) {
                        [_focusManager moveFocus:1];
                    } else {
                        
                        if (indexFocus == 0) {
                            if (directionFocus == 1) {
                                [_focusManager moveFocus:indexFocus];
                            } else {
                                [_focusManager moveFocus:[_focusManager focusIndex]];
                            }
                            
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
            [_focusManager setHidden:YES];
        }
        
    } else {
        
        if (scrollKKPTriggered) {
            if (landscapeFact) {
                if (backFactGenre) {
                    
                    [_focusManager setFocusRootView:self.tableView];
                    [_focusManager setHidden:NO];
                    if (indexFocus == 24) {
                        [_focusManager moveFocus:1];
                    } else {
                        
                        if (indexFocus == 0) {
                            if (directionFocus == 1) {
                                [_focusManager moveFocus:indexFocus];
                            } else {
                                [_focusManager moveFocus:[_focusManager focusIndex]];
                            }
                            
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

        } else {
            [_focusManager setHidden:YES];
        }
        
    }
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



- (void)createGerne
{
    MainTabBarViewController *tabbar = (MainTabBarViewController *)self.tabBarController;
    self.genreList = tabbar.genreTitles;
    self.genreIdList = tabbar.genreIds;

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
    self.genreTitle = [self.genreList objectAtIndex:indexPath.row];
    self.searchTerm = [self.genreIdList objectAtIndex:indexPath.row];
    [self callYoutube:self.searchTerm];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView
willDecelerate:(BOOL)decelerate
{

    scrollKKPTriggered = NO;
    [_focusManager setHidden:YES];
    
}


- (void)callYoutube:(NSString *)searchTerm
{
    reloadFact = YES;
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

    dispatch_async(dispatch_get_main_queue(), ^{
        reloadFact = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadGenreVideoId" object:nil];
        [alert dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"SubmitGenre" sender:nil];
    });
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SubmitGenre"]){

        GenreListTableViewController *dest = segue.destinationViewController;
        dest.genreYoutube = self.genreYoutube;
        dest.searchTerm = self.searchTerm;
        dest.genreType = self.genreType;
        dest.selectedIndex = self.selectedIndex;
        dest.genreTitle = self.genreTitle;
    }
}



- (BOOL)umaDidRotateWithDistance:(NSUInteger)distance direction:(UMADialDirection)direction
{
    if (viewFact == NO) {
        return YES;
    }
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
    scrollKKPTriggered = YES;
    [_focusManager setHidden:NO];
    indexFocus = [_focusManager focusIndex];
    if (direction == 0) {
        directionFocus = 0;
        indexFocus+=2;
    } else {
        directionFocus = 1;
    }

    return NO;
}

- (BOOL)umaDidTranslateWithDistance:(NSInteger)distanceX distanceY:(NSInteger)distanceY
{
    scrollKKPTriggered = YES;
    [_focusManager setHidden:NO];
    if (viewFact == NO) {
        return YES;
    }

    indexFocus = [_focusManager focusIndex];
    if (backFactGenre) {
        if (distanceX == 0 && distanceY == 1) {
            directionFocus = 0;
            indexFocus+=2;
            [_focusManager moveFocus:1 direction:kUMAFocusForward];
        } else if (distanceX == 0 && distanceY == -1) {
            directionFocus = 1;
            [_focusManager moveFocus:1 direction:kUMAFocusBackward];
        }

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
            } else if ([_focusManager focusIndex] == 3) {
                [_focusManager moveFocus:1];
            }
        }else if (distanceX == -1 && distanceY == 0) {

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
            
        }else if (distanceX == 0 && distanceY == -1) {

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
    if (viewFact == NO) {
        return YES;
    }
    if ([[self getButtonName:button] isEqualToString:@"Back"]) {
        //
     
        if (backFactGenre) {
            [_focusManager setFocusRootView:self.tabBarController.tabBar];
            [_focusManager moveFocus:1];
            backFactGenre = NO;
            
        } else {

            [_focusManager setFocusRootView:self.tableView];
            [_focusManager moveFocus:1];
            backFactGenre = YES;
        }
        
    } else if ([[self getButtonName:button] isEqualToString:@"Main"]) {
         [_focusManager setHidden:YES];
        return NO;
        
    } else if ([[self getButtonName:button] isEqualToString:@"VR"]) {
        
        return YES;
    } else if ([[self getButtonName:button] isEqualToString:@"Home"]) {
        return NO;
        
    }
    return YES;
}

- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button
{
   
    return YES;
}

- (BOOL)umaDidDoubleClickButton:(UMAInputButtonType)button
{

    return YES;
}

- (void)umaDidAccelerometerUpdate:(UMAAcceleration)acceleration
{

}




#pragma mark - UMAAppDiscoveryDelegate
- (void)didDiscoverySucceed:(NSArray *)appInfo
{

}
#pragma mark - UMAApplicationDelegate

- (UIViewController *)uma:(UMAApplication *)application requestRootViewController:(UIScreen *)screen {
    // This sample does not use this delegate
    return nil;
}

- (void)didDiscoveryFail:(int)reason withMessage:(NSString *)message;
{
  
}
- (void)uma:(UMAApplication *)application didConnectInputDevice:(UMAInputDevice *)device
{
    
}

- (void)uma:(UMAApplication *)application didDisconnectInputDevice:(UMAInputDevice *)device
{

}

@end
