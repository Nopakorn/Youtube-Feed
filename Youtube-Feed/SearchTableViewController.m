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
}
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search from Youtube";
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
//    [self.view addGestureRecognizer:tap];
    nextPage = true;
    self.youtube = [[Youtube alloc] init];
    self.searchYoutube = [[Youtube alloc] init];
    
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Search", nil)];
    self.searchTitle.text = [NSString stringWithFormat:NSLocalizedString(@"Search", nil)];
    self.searchIconTitle.hidden = YES;
#pragma setup UMA in ViewDidload in RecommendTableView
    //    _inputDevices = [NSMutableArray array];
//    _umaApp = [UMAApplication sharedApplication];
//    _umaApp.delegate = self;
//    //    _hidManager = [_umaApp requestHIDManager];
//    //
//    [_umaApp addViewController:self];
//    //
//    //    //focus
//    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
//    [_focusManager setFocusRootView:self.tabBarController.tabBar];
//    [_focusManager setHidden:NO];
//    [_focusManager moveFocus:5];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear SearchController");
    [_focusManager setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
#pragma setup UMA in ViewDidAppear in RecommendTableView
//    [_umaApp addViewController:self];
//    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
//    [_focusManager setFocusRootView:self.tabBarController.tabBar];
    [_focusManager setHidden:YES];
//    
//    [_focusManager moveFocus:5];    // Give focus to the first icon.
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
    
    cell.name.text = [self.searchYoutube.titleList objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
    NSString *duration = [self.searchYoutube.durationList objectAtIndex:indexPath.row];
    cell.durationLabel.text = [self durationText:duration];
    cell.thumnail.image = nil;
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
    
    
//    if (indexPath.row == [self.searchYoutube.videoIdList count]-1) {
//        [self launchReload];
//    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didselect row");
    self.selectedRow = indexPath.row;
    [self.delegate searchTableViewControllerDidSelected:self];
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
            [self launchReload];
        } else {
            NSLog(@"Its still loading api");
        }
    }
}

- (void)launchReload
{
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        [self.tableView reloadData];
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    NSLog(@"search text %@",searchBar.text);
    
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
    });

}

- (void)receivedLoadVideoIdNextPage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        self.tableView.tableFooterView = nil;
        [self.tableView reloadData];
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.searchYoutube.videoIdList count]-26 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        nextPage = true;
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
    if ([[self getButtonName:button]isEqualToString:@"Main"]) {
        return NO;
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
