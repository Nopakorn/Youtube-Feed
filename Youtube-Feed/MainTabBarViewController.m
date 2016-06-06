//
//  MainTabBarViewController.m
//  Youtube-Feed
//
//  Created by guild on 3/8/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "ViewController.h"
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

static NSString *const kRowNum = @"rowNum";
static NSString *const kHeaderText = @"headerText";
static NSString *const kTitleText = @"HID Device Sample";

NSString *const kIsManualConnection = @"is_manual_connection";

@interface MainTabBarViewController ()<UMAFocusManagerDelegate, UMAAppDiscoveryDelegate, UMAApplicationDelegate>
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

@implementation MainTabBarViewController
@synthesize youtube;
@synthesize recommendYoutube;
@synthesize searchYoutube;
@synthesize genreSelected;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customizableViewControllers = nil;
    self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
    UITableView *view = (UITableView *)self.moreNavigationController.topViewController.view;
    
    view.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setSelectedIndex:0];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] } forState:UIControlStateNormal];
    
     _inputDevices = [NSMutableArray array];
#pragma setup UMA in ViewDidloadTABBAR
    _inputDevices = [NSMutableArray array];
    _umaApp = [UMAApplication sharedApplication];
    _umaApp.delegate = self;
    [_umaApp addViewController:self];
    
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:[self.tabBarController.viewControllers objectAtIndex:0].view];
    [_focusManager setHidden:YES];
}



- (void)viewDidAppear:(BOOL)animated
{

    [_focusManager moveFocus:4];    

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveYoutubeObj:(Youtube *)yt
{
    if(yt.videoIdList != 0) {
        for (int i = 0; i < [yt.videoIdList count]; i++) {
            [self.youtube.videoIdList addObject:[yt.videoIdList objectAtIndex:i]];
            [self.youtube.titleList addObject:[yt.titleList objectAtIndex:i]];
            [self.youtube.thumbnailList addObject:[yt.thumbnailList objectAtIndex:i]];
        }
        
    }
}
- (NSString *)getButtonName:(UMAInputButtonType)button
{
    switch (button) {
        case kUMAInputButtonTypeDown:
            return @"Down";
        default:
            return @"Unknown";
    }
}

#pragma mark - UMARemoteInputEventDelegate

- (BOOL)umaDidPressDownButton:(UMAInputButtonType)button
{
    
    return NO;
}

- (BOOL)umaDidPressUpButton:(UMAInputButtonType)button
{
   
    return NO;
}

- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button
{
    
    return NO;
}

- (BOOL)umaDidDoubleClickButton:(UMAInputButtonType)button
{
    
    return NO;
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
