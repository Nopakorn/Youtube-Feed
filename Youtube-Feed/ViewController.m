//
//  ViewController.m
//  Youtube-Feed
//
//  Created by guild on 2/15/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "ViewController.h"
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

@interface ViewController () <UMAAppDiscoveryDelegate, UMAApplicationDelegate>


@property (nonatomic, strong) NSArray *applications;
@property (nonatomic) BOOL remoteScreen;

@property (nonatomic) UMAHIDManager *hidManager;
@property (nonatomic) UMAInputDevice *connectedDevice;
@property (copy, nonatomic) void (^discoveryBlock)(UMAInputDevice *, NSError *);
@property (copy, nonatomic) void (^connectionBlock)(UMAInputDevice *, NSError *);
@property (copy, nonatomic) void (^disconnectionBlock)(UMAInputDevice *, NSError *);
@property (nonatomic) NSMutableArray *inputDevices;

@end

@implementation ViewController
{
    Boolean recommendTableViewFlag;
    Boolean searchTableViewFlag;
    Boolean playlistDetailTableViewFlag;
    Boolean genreListTableViewFlag;
    Boolean favoriteTableViewFlag;
    Boolean favoriteDidPlayed;
    Boolean playlistDidPlayed;
    
    BOOL outOfLengthAlert;
    BOOL isSeekForward;
    BOOL isSeekBackward;
    BOOL backFact;
    NSInteger item;
    NSInteger queryIndex;
    NSInteger indexFocusTabbar;
}
- (id)init
{
    if(self = [super init]){
//        UMAApplication *umaApp = [UMAApplication sharedApplication];
//        [umaApp addViewController:self];
    }
    _inputDevices = [NSMutableArray array];
    return self;

}
- (void)dealloc
{
    // Be sure unregister itself
    if (!_remoteScreen) {
        UMAApplication *umaApp = [UMAApplication sharedApplication];
        [umaApp removeViewController:self];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.tabBarController.delegate = self;
    self.playButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.playButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    shouldHideStatusBar = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:shouldHideStatusBar];
    indexFocusTabbar = 2;
    item = 0;
    queryIndex = -1;
    recommendTableViewFlag = false;
    searchTableViewFlag = false;
    playlistDetailTableViewFlag = false;
    genreListTableViewFlag = false;
    outOfLengthAlert = true;
    favoriteTableViewFlag = false;
    favoriteDidPlayed = false;
    playlistDidPlayed = false;
    backFact = YES;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.youtube = [[Youtube alloc] init];
    self.favorite = [[Favorite alloc] init];
    self.favoriteList = [[NSMutableArray alloc] initWithCapacity:10];
    
    
    //play recommend video first time
    MainTabBarViewController *tabbar = (MainTabBarViewController *)self.tabBarController;
    self.youtube = tabbar.youtube;
    
    if([tabbar.youtube.videoIdList count] == 0){
        NSLog(@"object is nil");
    }
    
    //[self.navigationController setNavigationBarHidden:NO];
    self.playerView.delegate = self;
    self.playerVers =  @{ @"playsinline" : @1,
                          @"controls" : @0,
                          @"showinfo" : @1,
                          @"modestbranding" : @1,
                              };
    
    [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:self.playerVers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPlayBackStartedNotification:)
                                                 name:@"Playback started" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPlaylistDetailNotification:)
                                                 name:@"PlaylistDetailDidSelected" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedGenreListNotification:)
                                                 name:@"PlayGenreListDidSelected" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDeleteFavoriteNotification:)
                                                 name:@"DeleteFavorite" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedFavoriteDidSelectedNotification:)
                                                 name:@"FavoriteDidSelected" object:nil];
    
   
    
    UITapGestureRecognizer *tgpr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleTapPressed:)];
    [self.view addGestureRecognizer:tgpr];
    self.ProgressSlider.value = 0.0;
    
    UILongPressGestureRecognizer *lgpr_right = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(handleLongPressRight:)];
    lgpr_right.minimumPressDuration = 1.5;
    [self.nextButton addGestureRecognizer:lgpr_right];
    
    UILongPressGestureRecognizer *lgpr_left = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(handleLongPressLeft:)];
    lgpr_left.minimumPressDuration = 1.5;
    [self.prevButton addGestureRecognizer:lgpr_left];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
#pragma setup UMA in ViewDidload
    _inputDevices = [NSMutableArray array];
    _umaApp = [UMAApplication sharedApplication];
    _umaApp.delegate = self;
    _hidManager = [_umaApp requestHIDManager];
    
    [_umaApp addViewController:self];
    
    //focus
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:_containerView];
    [_focusManager setHidden:YES];
    [self prepareBlocks];
    [_hidManager setDisconnectionCallback:_disconnectionBlock];
}

- (void)prepareBlocks
{
    __weak typeof(self) weakSelf = self;
    
    //
    // Block of Discovery Completion
    //
    _discoveryBlock = ^(UMAInputDevice *device, NSError *error) {
        UIAlertView *alertView;
        
        switch ([error code]) {
            case kUMADiscoveryDone: // Intentionally stops by the app
            case kUMADiscoveryFailed: // Discovery failed with some reason
                //[weakSelf.refreshControl endRefreshing];
                break;
            case kUMADiscoveryTimeout: // Timeout occurred
                [weakSelf.hidManager stopDiscoverDevice];
                alertView = [[UIAlertView alloc] initWithTitle:@"Discovery of HID Device finished"
                                                       message:@"If you would like to discover again, pull down the view."
                                                      delegate:weakSelf
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
                alertView.tag = ALERT_TYPE_DISCOVERY_TIMEOUT;
                [alertView show];
                //[weakSelf.refreshControl endRefreshing];
                break;
            case kUMADiscoveryDiscovered:       // Device discovered
                /* Get discovered devices and reload table*/
                [weakSelf.inputDevices addObject:device];
                //[weakSelf.sampleTableView reloadData];
                break;
            case kUMADiscoveryStarted:
                break;
            default:
                break;
        }
    };
    [_hidManager setDiscoveryCallback:_discoveryBlock];
    
    //
    // Block of Connection Complete
    //
    _connectionBlock = ^(UMAInputDevice *device, NSError *error) {
        UIAlertView *alertView;
        switch ([error code]) {
            case kUMAConnectedSuccess:
                [weakSelf.hidManager stopDiscoverDevice];
                weakSelf.connectedDevice = device;
                //[weakSelf.sampleTableView reloadData];
                break;
            case kUMAConnectedTimeout:
            case kUMAConnectedFailed:
                alertView =
                [[UIAlertView alloc] initWithTitle:@"Connection timeout occurred."
                                           message:@"Reset the last memory and start to discovery?"
                                          delegate:weakSelf
                                 cancelButtonTitle:@"No"
                                 otherButtonTitles:@"Yes", nil];
                alertView.tag = ALERT_TYPE_FAIL_TO_CONNECT;
                [alertView show];
                break;
            default:
                break;
                
        }
    };
    [_hidManager setConnectionCallback:_connectionBlock];
    
    //
    // Block of Disonnection Complete
    //
    _disconnectionBlock = ^(UMAInputDevice *device, NSError *error) {
        weakSelf.connectedDevice = nil;
        //[weakSelf.sampleTableView reloadData];
    };
    [_hidManager setDisconnectionCallback:_disconnectionBlock];
}

- (BOOL)prefersStatusBarHidden
{
    //return shouldHideStatusBar;
    return YES;
}

- (void)hideNavigation
{
    if (self.tabBarController.tabBar.hidden == YES) {
//        shouldHideStatusBar = NO;
//        [self setNeedsStatusBarAppearanceUpdate];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        self.tabBarController.tabBar.hidden = NO;
        //self.topSapceConstraint.constant = 94;
        self.playButton.hidden = NO;
        self.pauseButton.hidden = NO;
        self.nextButton.hidden = NO;
        self.prevButton.hidden = NO;
        self.favoriteButton.hidden = NO;
        self.ProgressSlider.hidden = NO;
        self.totalTime.hidden = NO;
        self.currentTimePlay.hidden = NO;
        [_focusManager setHidden:YES];
    } else {
        shouldHideStatusBar = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        self.tabBarController.tabBar.hidden = YES;
        //self.topSapceConstraint.constant = 204;
        self.playButton.hidden = YES;
        self.pauseButton.hidden = YES;
        self.nextButton.hidden = YES;
        self.prevButton.hidden = YES;
        self.favoriteButton.hidden = YES;
        self.ProgressSlider.hidden = YES;
        self.totalTime.hidden = YES;
        self.currentTimePlay.hidden = YES;
        [_focusManager setHidden:YES];
    }

}

- (void)handleTapPressed:(UITapGestureRecognizer *)gestureRecognizer
{
    if (self.tabBarController.tabBar.hidden == YES) {
        //self.topSapceConstraint.constant = 94;
//        shouldHideStatusBar = NO;
//        [self setNeedsStatusBarAppearanceUpdate];
        [hideNavigation invalidate];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        self.tabBarController.tabBar.hidden = NO;
        
        self.playButton.hidden = NO;
        self.pauseButton.hidden = NO;
        self.nextButton.hidden = NO;
        self.prevButton.hidden = NO;
        self.favoriteButton.hidden = NO;
        self.ProgressSlider.hidden = NO;
        self.totalTime.hidden = NO;
        self.currentTimePlay.hidden = NO;
        [_focusManager setHidden:YES];
         hideNavigation = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hideNavigation) userInfo:nil repeats:NO];

    } else {
        
        //self.topSapceConstraint.constant = 204;
        [hideNavigation invalidate];

        [self.navigationController setNavigationBarHidden:YES animated:NO];
        self.tabBarController.tabBar.hidden = YES;
       
        self.playButton.hidden = YES;
        self.pauseButton.hidden = YES;
        self.nextButton.hidden = YES;
        self.prevButton.hidden = YES;
        self.favoriteButton.hidden = YES;
        self.ProgressSlider.hidden = YES;
        self.totalTime.hidden = YES;
        self.currentTimePlay.hidden = YES;
        [_focusManager setHidden:YES];
        

    }

}

- (void)hideNavWithFact:(BOOL )fact
{
    if (fact) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        self.tabBarController.tabBar.hidden = YES;
        self.topSapceConstraint.constant = 94;
        self.playButton.hidden = YES;
        self.pauseButton.hidden = YES;
        self.nextButton.hidden = YES;
        self.prevButton.hidden = YES;
        self.favoriteButton.hidden = YES;
        self.ProgressSlider.hidden = YES;
        self.totalTime.hidden = YES;
        self.currentTimePlay.hidden = YES;
        
    } else {
        
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        self.tabBarController.tabBar.hidden = NO;
        self.topSapceConstraint.constant = 50;
        self.playButton.hidden = NO;
        self.pauseButton.hidden = NO;
        self.nextButton.hidden = NO;
        self.prevButton.hidden = NO;
        self.favoriteButton.hidden = NO;
        self.ProgressSlider.hidden = NO;
        self.totalTime.hidden = NO;
        self.currentTimePlay.hidden = NO;
        
    }

}



- (void)viewDidLayoutSubviews
{
    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        if (self.tabBarController.tabBar.hidden == YES) {
            self.topSapceConstraint.constant = 94;
        } else {
            self.topSapceConstraint.constant = 50;
        }
        
    } else {
        
        if (self.tabBarController.tabBar.hidden == YES) {
            self.topSapceConstraint.constant = 0;
            //self.heightPlayerViewConstraint.constant = 360;
            self.bottomSpacingPlayerViewConstraint.constant = 0;
            
        } else {
            self.topSapceConstraint.constant = 0;
            self.bottomSpacingPlayerViewConstraint.constant = 57;
            //self.heightPlayerViewConstraint.constant = 230;

        }

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"View did appear in youtube");
    hideNavigation = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hideNavigation) userInfo:nil repeats:NO];
    
    
    indexFocusTabbar = 2;
   
    if (recommendTableViewFlag) {

        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:self.playerVers];
        recommendTableViewFlag = false;
    }
    
    if (searchTableViewFlag) {
    
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:self.playerVers];
        searchTableViewFlag = false;
    }
    
    if (playlistDetailTableViewFlag) {

        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:self.playerVers];
        playlistDetailTableViewFlag = false;
        playlistDidPlayed = true;
    }

    if (genreListTableViewFlag) {
        NSLog(@"in genreList");
        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:self.playerVers];
        genreListTableViewFlag = false;
        

    }
    
    if (favoriteTableViewFlag) {

        [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:self.playerVers];
        favoriteTableViewFlag = false;
        favoriteDidPlayed = true;
        
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    [_umaApp addViewController:self];
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:_containerView];
    
    
    
    [_focusManager moveFocus:4];    // Give focus to the first icon.
    //[_focusManager setDelegate:self];
    [_focusManager setHidden:YES];
    [_hidManager setConnectionCallback:_connectionBlock];
    [_hidManager enableAutoConnectionWithDiscoveryTimeout:kHidDeviceControlTimeout
                                    WithDiscoveryInterval:kHidDeviceControlTimeout
                                    WithConnectionTimeout:kHidDeviceControlTimeout];
    [_hidManager startDiscoverWithDeviceName:nil];

}


- (void)orientationChanged:(NSNotification *)notification
{
    UIDevice *device = notification.object;
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
            if (backFact == 0) {
                
                [_focusManager setFocusRootView:self.tabBarController.tabBar];
                [_focusManager setHidden:NO];
                [_focusManager moveFocus:indexFocusTabbar];
                
            }
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            if (backFact == 0) {
                
                [_focusManager setFocusRootView:self.tabBarController.tabBar];
                [_focusManager setHidden:NO];
                [_focusManager moveFocus:indexFocusTabbar];
                
            }
            break;
            
        case UIDeviceOrientationLandscapeRight:
            if (backFact == 0) {
                
                [_focusManager setFocusRootView:self.tabBarController.tabBar];
                [_focusManager setHidden:NO];
                [_focusManager moveFocus:indexFocusTabbar];
                
            }
            break;
  
        default:
            break;
    }
//    NSLog(@"View changing %ld", (long)indexFocusTabbar);
//    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
//        if (backFact == 0) {
//
//            [_focusManager setFocusRootView:self.tabBarController.tabBar];
//            [_focusManager setHidden:NO];
//            [_focusManager moveFocus:indexFocusTabbar];
//            
//        }
//        
//    } else {
//        
//        if (backFact == 0) {
//            
//            [_focusManager setFocusRootView:self.tabBarController.tabBar];
//            [_focusManager setHidden:NO];
//            [_focusManager moveFocus:indexFocusTabbar];
//        }
//        
//    }
    
}




- (void)handleLongPressRight:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [hideNavigation invalidate];
    if (gestureRecognizer.state == 2) {
        isSeekForward = true;
        
    } else {
        isSeekForward = false;
         hideNavigation = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hideNavigation) userInfo:nil repeats:NO];
    }
}

- (void)handleLongPressLeft:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [hideNavigation invalidate];
    if (gestureRecognizer.state == 2) {
        isSeekBackward = true;
        
    } else {
        isSeekBackward= false;
        hideNavigation = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hideNavigation) userInfo:nil repeats:NO];
    }
    
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear Viewcontroller");
    [hideNavigation invalidate];
    [_focusManager setHidden:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
   
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    BOOL checkFav = false;
    UIImage *btnImageStarCheck = [UIImage imageNamed:@"star_2"];
    UIImage *btnImageStar = [UIImage imageNamed:@"star_1"];
    
    //self.navigationItem.title = [self.youtube.titleList objectAtIndex:item];
    
    self.resultFovorite = [self.fetchedResultsController fetchedObjects];
    for (int i = 0; i < [self.resultFovorite count]; i++) {
        
        NSManagedObject *object = [self.resultFovorite objectAtIndex:i];
        if ([[object valueForKey:@"videoId"]isEqualToString:[self.youtube.videoIdList objectAtIndex:item]]) {
            checkFav = true;
            break;
        } else {
            checkFav = false;
        }
    }
    
    if (checkFav) {
        [self.favoriteButton setImage:btnImageStarCheck forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setImage:btnImageStar forState:UIControlStateNormal];
    }
    UIImage *btnImagePause = [UIImage imageNamed:@"pauseButton"];
    [self.playButton setImage:btnImagePause forState:UIControlStateNormal];

    [self.playerView playVideo];
    //implementprogress bar
    self.ProgressSlider.value = 0;
    self.currentTimePlay.text = @"00:00";
    self.totalTime.text = @"00:00";
    [self.ProgressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{

    NSInteger startTime = sender.value * self.playerTotalTime;
    [self.timerProgress invalidate];
    self.ProgressSlider.value = (double)startTime / self.playerTotalTime;
    
    double currentTimeChange = sender.value * self.playerTotalTime;
    NSTimeInterval currentTimeInterval = currentTimeChange;
    self.currentTimePlay.text = [self stringFromTimeInterval:currentTimeInterval];

    [self.playerView seekToSeconds:currentTimeChange allowSeekAhead:YES];
}



- (void)makeProgressBarMoving:(NSTimer *)timer
{
    float total = [self.ProgressSlider value];
    double currentTime = [self.playerView currentTime];
    NSTimeInterval currentTimeInterval = currentTime;
    self.currentTimePlay.text = [self stringFromTimeInterval:currentTimeInterval];
    
    if (isSeekForward) {
        if (total < 1) {
            float playerCurrentTime = [self.playerView currentTime];
            playerCurrentTime+=5;
            self.ProgressSlider.value = (playerCurrentTime / (float)self.playerTotalTime);
            [self.playerView seekToSeconds:playerCurrentTime allowSeekAhead:YES];
            
        } else {
            [self.timerProgress invalidate];
        }

    } else if (isSeekBackward){
        if (total < 1) {
            float playerCurrentTime = [self.playerView currentTime];
            playerCurrentTime-=5;
            self.ProgressSlider.value = (playerCurrentTime / (float)self.playerTotalTime);
            [self.playerView seekToSeconds:playerCurrentTime allowSeekAhead:YES];
            
        } else {
            [self.timerProgress invalidate];
        }
        
    }else {
        if (total < 1) {
            float playerCurrentTime = [self.playerView currentTime];
            self.ProgressSlider.value = (playerCurrentTime / (float)self.playerTotalTime);
        } else {
            [self.timerProgress invalidate];
        }

    }
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    if (hours > 0) {
        //self.totalTimeWidthConstraint.constant = 75;
         return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        //self.totalTimeWidthConstraint.constant = 48;

        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
   
}



- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{

    if (state == kYTPlayerStatePlaying) {
        
        UIImage *btnImagePause = [UIImage imageNamed:@"pauseButton"];
        [self.playButton setImage:btnImagePause forState:UIControlStateNormal];
        self.playerTotalTime = [self.playerView duration];
        self.totalTime.text = [self stringFromTimeInterval:self.playerTotalTime];
        double currentTime = [self.playerView currentTime];
        NSTimeInterval currentTimeInterval = currentTime;
       
        self.currentTimePlay.text = [self stringFromTimeInterval:currentTimeInterval];
        
        self.timerProgress = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(makeProgressBarMoving:) userInfo:nil repeats:YES];
        
    } else if (state == kYTPlayerStatePaused) {
        [self.timerProgress invalidate];
         UIImage *btnImagePlay = [UIImage imageNamed:@"playButton"];
         [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
    }

    if (state == kYTPlayerStateEnded) {
        NSLog(@"Ended video");
        item+=1;
        [self.playerView pauseVideo];
        UIImage *btnImagePlay = [UIImage imageNamed:@"playButton"];
        [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
        if(item == [self.youtube.videoIdList count]){
            NSLog(@"Out of length");
            outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
            outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
            [self presentViewController:outOflengthAlert animated:YES completion:nil];
            
        }else {

            [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:self.playerVers];
            
        }
        
    }else if (state == kYTPlayerErrorVideoNotFound) {
        
        NSLog(@"Video not found : %@", [self.youtube.videoIdList objectAtIndex:item]);
        
    }else if (state == kYTPlayerStateUnstarted) {
        
        NSLog(@"Video unstarted : %@", [self.youtube.videoIdList objectAtIndex:item]);
        item+=1;
        [self.playerView pauseVideo];
        UIImage *btnImagePlay = [UIImage imageNamed:@"playButton"];
        [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
        if(item == [self.youtube.videoIdList count]) {
            
             NSLog(@"Out of length");
            outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
            outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
            [self presentViewController:outOflengthAlert animated:YES completion:nil];
             item-=1;
        }else {

            [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:self.playerVers];
            
        }
        
    }
}

- (void)buttonPressed:(id)sender
{
    if (sender == self.playButton) {
        
        UIImage *btnImagePlay = [UIImage imageNamed:@"playButton"];
        UIImage *btnImagePause = [UIImage imageNamed:@"pauseButton"];
        
        if ([[self.playButton imageForState:UIControlStateNormal] isEqual:btnImagePlay]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback Started" object:self];
            [self.playerView playVideo];
            [self.playButton setImage:btnImagePause forState:UIControlStateNormal];
            //self.playButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        } else {
            [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
            [self.playerView pauseVideo];

        }
        
        
    } else if (sender == self.nextButton) {
        
        item+=1;
        [self.playerView pauseVideo];
        UIImage *btnImagePlay = [UIImage imageNamed:@"playButton"];
        [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
        if (outOfLengthAlert) {
            
            if (item == [self.youtube.videoIdList count]) {
                NSLog(@"Out of length");
                outOfLengthAlert = false;
                outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
                outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
                [self presentViewController:outOflengthAlert animated:YES completion:nil];
                item-=1;
            }else {

                [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:self.playerVers];
                
            }

        }
        
    } else if (sender == self.prevButton) {
        
        item-=1;
        [self.playerView pauseVideo];
        UIImage *btnImagePlay = [UIImage imageNamed:@"playButton"];
        [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
        if (outOfLengthAlert) {
            if (item < 0) {
                NSLog(@"Out of length");
                outOflengthAlert = [UIAlertController alertControllerWithTitle:nil message:@"Out Of Length" preferredStyle:UIAlertControllerStyleAlert];
                outOflengthAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissOutOflengthAlert) userInfo:nil repeats:NO];
                [self presentViewController:outOflengthAlert animated:YES completion:nil];
                item+=1;
            } else {

                [self.playerView loadWithVideoId:[self.youtube.videoIdList objectAtIndex:item] playerVars:self.playerVers];
                
            }

        }
    }

}

- (void)favoritePressed:(id)sender
{
    NSLog(@"favorite check youtube %@", self.youtube.titleList);
    NSString *videoId = [self.youtube.videoIdList objectAtIndex:item];
    NSString *videoTitle = [self.youtube.titleList objectAtIndex:item];
    NSString *videoThumbnail = [self.youtube.thumbnailList objectAtIndex:item];
    NSString *videoDuration = [self.youtube.durationList objectAtIndex:item];
    //self.favorite = [[Favorite alloc] init];
    [self.favorite setFavoriteWithTitle:videoTitle thumbnail:videoThumbnail andVideoId:videoId andDuration:videoDuration];
    NSLog(@"favorite check favorite %@", self.favorite.videoTitle);
    UIImage *btnImageStarCheck = [UIImage imageNamed:@"star_2"];
    UIImage *btnImageStar = [UIImage imageNamed:@"star_1"];

    if ([[self.favoriteButton imageForState:UIControlStateNormal] isEqual:btnImageStar]) {
        
//        favoriteAlert = [UIAlertController alertControllerWithTitle:nil message:@"Adding to Favorite" preferredStyle:UIAlertControllerStyleAlert];
//        favoriteAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissFavoriteAlert) userInfo:nil repeats:NO];
//        [self presentViewController:favoriteAlert animated:YES completion:nil];
//        [self.favoriteList addObject:self.favorite];
        [self insertFavorite:self.favorite];
        [self.favoriteButton setImage:btnImageStarCheck forState:UIControlStateNormal];
    } else {
        
//        favoriteAlert = [UIAlertController alertControllerWithTitle:nil message:@"Delete From Favorite" preferredStyle:UIAlertControllerStyleAlert];
//        favoriteAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissFavoriteAlert) userInfo:nil repeats:NO];
//        [self presentViewController:favoriteAlert animated:YES completion:nil];
        [self deleteFavorite:self.favorite];
        [self.favoriteButton setImage:btnImageStar forState:UIControlStateNormal];
    }

}

- (void)deleteFavorite:(Favorite *)favorite
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"videoId == %@",favorite.videoId]];
    
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    for (NSManagedObject *manageObject in result) {
        [context deleteObject:manageObject];
    }
    
}


- (void)insertFavorite:(Favorite *)favorite
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    [newManagedObject setValue:favorite.videoId forKey:@"videoId"];
    [newManagedObject setValue:favorite.videoTitle forKey:@"videoTitle"];
    [newManagedObject setValue:favorite.videoThumbnail forKey:@"videoThumbnail"];
    [newManagedObject setValue:favorite.videoDuration forKey:@"videoDuration"];
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


- (void)dismissFavoriteAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [favoriteAlert dismissViewControllerAnimated:YES completion:nil];
        [favoriteAlertTimer invalidate];
    });
}

- (void)dismissOutOflengthAlert
{
    outOfLengthAlert = true;
    [outOflengthAlert dismissViewControllerAnimated:YES completion:nil];
    [outOflengthAlertTimer invalidate];
}
- (void)receivedDeleteFavoriteNotification:(NSNotification *)notification
{
    UIImage *btnImageStar = [UIImage imageNamed:@"star_1"];
    [self.favoriteButton setImage:btnImageStar forState:UIControlStateNormal];
    if (favoriteDidPlayed) {
        favoriteDidPlayed = false;
        favoriteTableViewFlag = true;
        self.youtube = [notification.userInfo objectForKey:@"youtubeObj"];
        
    }
}

- (void)receivedPlayBackStartedNotification:(NSNotification *) notification
{
    if ([notification.name isEqual:@"Playback Started"] && notification.object != self) {
        NSLog(@"pause video");
        [self.playerView pauseVideo];
    }

}

- (void)receivedPlaylistDetailNotification:(NSNotification *)notification
{
    playlistDetailTableViewFlag = true;
    self.youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    item = [[notification.userInfo objectForKey:@"selectedIndex"] integerValue];
    NSLog(@"Received playlistDetail");
}

- (void)receivedGenreListNotification:(NSNotification *)notification
{
    genreListTableViewFlag = true;
    self.youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    item = [[notification.userInfo objectForKey:@"selectedIndex"] integerValue];
    //NSLog(@"Received playGenreList");
     NSLog(@"Received genrelistdetail %lu item: %lu",(unsigned long)[self.youtube.titleList count], item);
}

- (void)receivedFavoriteDidSelectedNotification:(NSNotification *)notification
{
    favoriteTableViewFlag = true;
    self.youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    item = [[notification.userInfo objectForKey:@"selectedIndex"] integerValue];
    NSLog(@"Received favorite");

}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    UIViewController *newVC = segue.destinationViewController;
//    
//    [ViewController setPresentationStyleForSelfController:self presentingController:newVC];
//}
//
//+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
//{
//    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
//    {
//        //iOS 8.0 and above
//        presentingController.providesPresentationContextTransitionStyle = YES;
//        presentingController.definesPresentationContext = YES;
//        
//        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
//    }
//    else
//    {
//        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
//        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
//    }
//}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [hideNavigation invalidate];
    [_focusManager setHidden:NO];
    backFact = YES;
    if (tabBarController.selectedIndex == 2) {
    
        UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:2];
        PlaylistTableViewController *playlistView = [nav.viewControllers objectAtIndex:0];
        playlistView.favorite = self.favorite;
        playlistView.youtube = self.youtube;
        NSLog(@"select playlist");
    }
    
    if (tabBarController.selectedIndex == 1) {
       
        UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:1];
        RecommendTableViewController *rec = [nav.viewControllers objectAtIndex:0];
        rec.delegate = self;
         NSLog(@"select rocommend");
    }
    
    if (tabBarController.selectedIndex == 4) {
        
        UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:4];
        SearchTableViewController *seachView = [nav.viewControllers objectAtIndex:0];
        seachView.delegate = self;
        NSLog(@"select search");
    }
}

#pragma mark - delegate RecommendTableViewController

- (void)recommendTableViewControllerDidSelected:(RecommendTableViewController *)recommendViewController
{
    recommendTableViewFlag = true;
    self.youtube = recommendViewController.recommendYoutube;
    item = recommendViewController.selectedRow;
    NSLog(@"recommend did selected");
}

- (void)recommendTableViewControllerNextPage:(RecommendTableViewController *)recommendViewController
{
    self.youtube = recommendViewController.recommendYoutube;
    NSLog(@"recommend next page");
}

#pragma mark - delegate SearchTableViewController

- (void)searchTableViewControllerDidSelected:(SearchTableViewController *)searchViewController
{
    searchTableViewFlag = true;
    self.youtube = searchViewController.searchYoutube;
    item = searchViewController.selectedRow;
     NSLog(@"Received Search");
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{

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

 float level = 0.0;
- (BOOL)umaDidRotateWithDistance:(NSUInteger)distance direction:(UMADialDirection)direction
{
    NSLog(@"focus index %ld distance: %lu diraction: %ld",(long)[_focusManager focusIndex], (unsigned long)distance, (long)direction);
    if (backFact) {
        //limitation of volume level
        if (level < 0) {
            level = 0.0;
        } else if (level > 1) {
            level = 1.0;
        }
        
        NSLog(@"in main view %lu    %ld",(unsigned long)distance, (long)direction);
        if ((long)direction == 1) {
            NSLog(@"goes up");
            level += 0.05;
            NSLog(@"level %f",level);
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:level];
        } else {
            NSLog(@"goes down");
            level -= 0.05;
             NSLog(@"level %f",level);
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:level];
        }
        return YES;
        
    } else {
        
        
        if (direction == 1) {
            if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 4;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 3;
            }else if ([_focusManager focusIndex] == 2) {
                indexFocusTabbar = 2;
            }
        } else {
            if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 3;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 2) {
                indexFocusTabbar = 4;
            }

        
        }
        
        if ([_focusManager focusIndex] == 3 && distance == 1 && direction == 0) {
            NSLog(@"search");
            [_focusManager moveFocus:2];

        } else if ([_focusManager focusIndex] == 1 && distance == 1 && direction == 1) {
            NSLog(@"search");
            [_focusManager moveFocus:3];
            
        }

        return NO;
    }
    
}

- (BOOL)umaDidTranslateWithDistance:(NSInteger)distanceX distanceY:(NSInteger)distanceY
{
    [self hideNavWithFact:NO];
    [hideNavigation invalidate];
    if (backFact) {
        if (distanceX == 1 && distanceY == 0) {
            NSLog(@"RIGTH");
            
            [self buttonPressed:self.nextButton];
        }else if (distanceX == -1 && distanceY == 0) {
            NSLog(@"LEFT");
            [self buttonPressed:self.prevButton];
        }else if (distanceX == 0 && distanceY == 1) {
            NSLog(@"BOTTOM");
            [self buttonPressed:self.prevButton];
        }else if (distanceX == 0 && distanceY == -1) {
            NSLog(@"TOP");
            [self buttonPressed:self.nextButton];
        }
        hideNavigation = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hideNavigation) userInfo:nil repeats:NO];
        return YES;
        
    } else {
        
        if (distanceX == 1 && distanceY == 0) {
            NSLog(@"RIGTH");
            if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 3;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 2) {
                indexFocusTabbar = 4;
            }
            
            if ([_focusManager focusIndex] == 3) {
                [_focusManager moveFocus:2];
               
            }
            
        }else if (distanceX == -1 && distanceY == 0) {
            NSLog(@"LEFT");
           
            if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 4;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 3;
            }else if ([_focusManager focusIndex] == 2) {
                indexFocusTabbar = 2;
            }


            if ([_focusManager focusIndex] == 1) {
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
    NSLog(@"Press down %@",[self getButtonName:button]);
    return YES;
}


- (BOOL)umaDidPressUpButton:(UMAInputButtonType)button
{
    NSLog(@"Press up %@", [self getButtonName:button]);
    [self hideNavWithFact:NO];
    [hideNavigation invalidate];
    if ([[self getButtonName:button] isEqualToString:@"Back"]) {
        
        
        if (backFact) {
            NSLog(@"backFact %id",backFact);
            [_focusManager setHidden:NO];
            [_focusManager setFocusRootView:self.tabBarController.tabBar];
            //[_focusManager setFocusable:[self.tabBarController.viewControllers objectAtIndex:4].view value:NO];
            [_focusManager moveFocus:2];
          
            backFact = NO;
            
        } else {
           
            //NSLog(@"in tabbar controller");
            [_focusManager setFocusRootView:_containerView];
            [_focusManager setHidden:YES];
            [_focusManager moveFocus:4];
            backFact = YES;
            hideNavigation = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hideNavigation) userInfo:nil repeats:NO];
        }
        
    } else if ([[self getButtonName:button] isEqualToString:@"Main"]) {
        return NO;
        
    } else if ([[self getButtonName:button] isEqualToString:@"VR"]) {
        
        //[self hideNavigation];
        [self favoritePressed:self.favoriteButton];
        return YES;
        
    } else if ([[self getButtonName:button] isEqualToString:@"Right"]){
        NSLog(@"Right button");
        return NO;
        
    }  else if ([[self getButtonName:button] isEqualToString:@"Left"]){
        NSLog(@"Right button");
        return NO;
    }
    return YES;
}

- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button
{
    NSLog(@"Long press %@", [self getButtonName:button]);
    
    return YES;
}
- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button state:(UMAInputGestureRecognizerState)state
{
    [self hideNavWithFact:NO];
    [hideNavigation invalidate];
    if ([[self getButtonName:button] isEqualToString:@"Right"]) {
        if (state == 0) {
            isSeekForward = true;
        } else {
            isSeekForward = false;
        }
    } else if ([[self getButtonName:button] isEqualToString:@"Left"]){
        if (state == 0) {
            isSeekBackward = true;
        } else {
            isSeekBackward = false;
        }
    }
    hideNavigation = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hideNavigation) userInfo:nil repeats:NO];
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
