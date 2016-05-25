//
//  SearchTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/16/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "SearchTableViewController.h"
#import "RecommendCustomCell.h"
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

@interface SearchTableViewController ()<UMAFocusManagerDelegate, UMAAppDiscoveryDelegate, UMAApplicationDelegate>

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

@implementation SearchTableViewController
{
    BOOL nextPage;
    BOOL didReceivedFromYoutubePlaying;
    BOOL spinerFact;
    NSInteger markHighlightIndex;
    BOOL reloadFact;
    BOOL searchFact;
    BOOL internetActive;
    BOOL hostActive;
}

@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search from Youtube";
    spinerFact = NO;
    reloadFact = NO;
    internetActive = NO;
    hostActive = NO;
    searchFact = NO;
    nextPage = true;
    self.youtube = [[Youtube alloc] init];
    self.searchYoutube = [[Youtube alloc] init];
    markHighlightIndex = 0;
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Search", nil)];
    self.searchTitle.text = [NSString stringWithFormat:NSLocalizedString(@"Search", nil)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedYoutubePlayingNotification:)
                                                 name:@"YoutubePlaying" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedYoutubeReloadNotification:)
                                                 name:@"YoutubeReloadSearch" object:nil];

}

- (void)receivedYoutubeReloadNotification:(NSNotification *)notification
{
    self.searchYoutube = [notification.userInfo objectForKey:@"youtubeObj"];
     self.selectedRow = [[notification.userInfo objectForKey:@"selectedIndex"] integerValue];
    self.searchTerm = [notification.userInfo objectForKey:@"searchTerm"];
    [self.tableView reloadData];

}

- (void)receivedYoutubePlayingNotification:(NSNotification *)notification
{
    Youtube *youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    NSInteger selectedIndex = [[notification.userInfo objectForKey:@"youtubeCurrentPlaying"] integerValue];
    self.searchPlaying = [[notification.userInfo objectForKey:@"searchFact"] boolValue];
    self.searchTerm = [notification.userInfo objectForKey:@"searchTerm"];
    
    if (self.searchPlaying) {
        if ([self.searchTerm isEqualToString:self.searchText]) {
            if ([[youtube.videoIdList objectAtIndex:selectedIndex] isEqualToString:[self.searchYoutube.videoIdList objectAtIndex:selectedIndex]])
            {
                didReceivedFromYoutubePlaying = YES;
                self.selectedRow = selectedIndex;
                [self.tableView reloadData];
//                if (reloadFact) {
//                    [self.tableView reloadData];
//                } else {
//                    NSIndexPath *indexPathReload = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
//                    NSIndexPath *indexPathLastMark = [NSIndexPath indexPathForRow:markHighlightIndex inSection:0];
//                    NSArray *indexArray = [NSArray arrayWithObjects:indexPathReload, indexPathLastMark, nil];
//                    [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
//                }
            
            }
            
        } else {
            
            didReceivedFromYoutubePlaying = NO;
            [self.tableView reloadData];
//            if (reloadFact) {
//                [self.tableView reloadData];
//            } else {
//                NSIndexPath *indexPathLastMark = [NSIndexPath indexPathForRow:markHighlightIndex inSection:0];
//                NSArray *indexArray = [NSArray arrayWithObjects:indexPathLastMark, nil];
//                [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
//            }

        }
        
    } else {
        
        didReceivedFromYoutubePlaying = NO;
        [self.tableView reloadData];
//        if (reloadFact) {
//            [self.tableView reloadData];
//        } else {
//            NSIndexPath *indexPathLastMark = [NSIndexPath indexPathForRow:markHighlightIndex inSection:0];
//            NSArray *indexArray = [NSArray arrayWithObjects:indexPathLastMark, nil];
//            [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
//        }
//
    }
    NSLog(@"recevied search %i",self.searchPlaying);

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if (subView.tag == 99) {
            [subView removeFromSuperview];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

    [_focusManager setHidden:YES];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.searchPlaying) {
        if ([self.searchTerm isEqualToString:self.searchText]) {
            didReceivedFromYoutubePlaying = YES;
        } else {
            didReceivedFromYoutubePlaying = NO;
        }
        
    } else {
        didReceivedFromYoutubePlaying = NO;
    }
    
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 5)];
    navBorder.tag = 99;
    [navBorder setBackgroundColor:UIColorFromRGB(0x4F6366)];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    hostReachable = [Reachability reachabilityWithHostName:@"www.youtube.com"];
    [hostReachable startNotifier];
#pragma setup UMA in ViewDidAppear in RecommendTableView
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setHidden:YES];


}


- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable:
        {
            NSLog(@"The internet is down");
            internetActive = NO;
            break;
            
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WiFi");
            internetActive = YES;
            break;
            
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via 3g");
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
            NSLog(@"A gateway to the host server is down.");
            hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
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
            reloadFact = NO;
            
            if (searchFact) {

                [spinner stopAnimating];
                [self.searchYoutube.titleList removeAllObjects];
                [self.searchYoutube.videoIdList removeAllObjects];
                [self.searchYoutube.thumbnailList removeAllObjects];
                [self.searchYoutube.durationList removeAllObjects];
                [self.tableView reloadData];
                self.searchYoutube = [[Youtube alloc] init];
              
                [self.searchYoutube callSearchByText:self.searchText withNextPage:NO];
                spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                spinner.center = CGPointMake(self.view.center.x, 85.5);
                spinner.color = [UIColor blackColor];
                [self.tableView addSubview:spinner];
                [spinner startAnimating];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(receivedLoadVideoId)
                                                             name:@"LoadVideoIdFromSearch" object:nil];
            } else {
                
                [self launchReload];
            }
            
        }
        
    } else {
        reloadFact = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoIdNextPage" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoIdFromSearch" object:nil];
    }
    
}




- (void)orientationChanged:(NSNotification *)notification
{
    
    if (spinerFact) {
        spinner.center = CGPointMake(self.view.center.x, 85.5);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.searchYoutube.videoIdList count] == 0) {
        
        return 0;
    } else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.searchYoutube.videoIdList count] == 0 ) {
        return 0;
    }else {
        return [self.searchYoutube.videoIdList count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"RecommendCustomCell";
    RecommendCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecommendCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    if ([self.searchYoutube.durationList count] != [self.searchYoutube.videoIdList count]) {
        NSLog(@"No data");

    } else {
        cell.name.text = [self.searchYoutube.titleList objectAtIndex:indexPath.row];
        cell.tag = indexPath.row;
        NSString *duration = [self.searchYoutube.durationList objectAtIndex:indexPath.row];
        cell.durationLabel.text = [self durationText:duration];
        cell.thumnail.image = nil;
        
        if (didReceivedFromYoutubePlaying) {
            if (indexPath.row == self.selectedRow) {
                markHighlightIndex = indexPath.row;
                cell.contentView.backgroundColor = UIColorFromRGB(0xFFCCCC);
            } else {
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        
        //
        if([self.searchYoutube.thumbnailList objectAtIndex:indexPath.row] != [NSNull null]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.searchYoutube.thumbnailList objectAtIndex:indexPath.row]]];
                
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

    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    self.selectedRow = indexPath.row;

    NSString *selected = [NSString stringWithFormat:@"%lu",(long)self.selectedRow];
    NSDictionary *userInfo = @{ @"youtubeObj": self.searchYoutube,
                                @"selectedIndex": selected,
                                @"searchTerm":self.searchText };

    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaySearchDidSelected" object:self userInfo:userInfo];

    
    
    [self.tabBarController setSelectedIndex:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView
                  willDecelerate:(BOOL)decelerate
{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 50;
    if(y > h + reload_distance) {
        if (nextPage) {
            reloadFact = YES;
            [self launchReload];
        } else {
            NSLog(@"Its still loading api");
        }
    }
}

- (void)launchReload
{
    searchFact = NO;
    nextPage = false;
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake(0, 0, 320, 44);
    spinner.color = [UIColor blackColor];
    self.tableView.tableFooterView = spinner;
    [spinner startAnimating];
    
    [self.searchYoutube callSearchByText:self.searchText withNextPage:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoIdNextPage)
                                                 name:@"LoadVideoIdFromSearchNextPage" object:nil];
   
}




- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
     self.searchBar.text = @"";
     self.searchBar.showsCancelButton = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //when text changing
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    self.searchBar.showsCancelButton = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoIdFromSearch" object:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        [self.tableView reloadData];

    });
    

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchYoutube.titleList removeAllObjects];
    [self.searchYoutube.videoIdList removeAllObjects];
    [self.searchYoutube.thumbnailList removeAllObjects];
    [self.searchYoutube.durationList removeAllObjects];
    [self.tableView reloadData];

    self.searchText = searchBar.text;

    reloadFact = YES;
    spinerFact = YES;
    searchFact = YES;
    self.searchYoutube = [[Youtube alloc] init];
    [self.searchYoutube callSearchByText:searchBar.text withNextPage:NO];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(self.view.center.x, 85.5);
    spinner.color = [UIColor blackColor];
    [self.tableView addSubview:spinner];
    [spinner startAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoId)
                                                 name:@"LoadVideoIdFromSearch" object:nil];
}
- (void)receivedLoadVideoId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        [self.tableView reloadData];
        [self.searchBar resignFirstResponder];
        self.searchBar.showsCancelButton = NO;
        spinerFact = NO;
        reloadFact = NO;
        searchFact = NO;
        if ([self.searchText isEqualToString:self.searchTerm]) {
            if (self.searchPlaying) {
                didReceivedFromYoutubePlaying = YES;
            } else {
                didReceivedFromYoutubePlaying = NO;
    
            }

        } else {
            didReceivedFromYoutubePlaying = NO;
        }
     
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoIdFromSearch" object:nil];

    });

}

- (void)receivedLoadVideoIdNextPage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        self.tableView.tableFooterView = nil;
        reloadFact = NO;
        nextPage = true;
        [self.tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoIdFromSearchNextPage" object:nil];
    });

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
    NSLog(@"Press Down in Recommended %@",[self getButtonName:button]);
    return YES;
}

- (BOOL)umaDidPressUpButton:(UMAInputButtonType)button
{
//    if ([[self getButtonName:button]isEqualToString:@"Main"]) {
//        return NO;
//    }
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
