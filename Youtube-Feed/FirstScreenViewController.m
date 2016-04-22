//
//  FirstScreenViewController.m
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 3/30/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "FirstScreenViewController.h"
#import "MainTabBarViewController.h"

@interface FirstScreenViewController ()

@end

@implementation FirstScreenViewController
{
    BOOL receivedGenre;
    BOOL receivedYoutube;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.youtube = [[Youtube alloc] init];
    self.genre = [[Genre alloc] init];
    receivedGenre = NO;
    receivedYoutube = NO;
    self.genreSelected = [[NSMutableArray alloc] initWithCapacity:10];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.loadingLabel.hidden = YES;
    self.spinner.hidden = YES;
    //[self.spinner startAnimating];
    //tutorial has been showed
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tutorialPass"];
//    [[NSUserDefaults standardUserDefaults] synchronize];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"tutorialPass"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"genreSelectedFact"]) {
            self.spinner.hidden = NO;
            [self.spinner startAnimating];
            NSString *saveGenre = [[NSUserDefaults standardUserDefaults] stringForKey:@"genreSelectedString"];
            NSArray *stringSeparated = [saveGenre componentsSeparatedByString:@"+"];
            self.genreSelected = [NSMutableArray arrayWithArray:stringSeparated];
            
            NSString *saveGenreId = [[NSUserDefaults standardUserDefaults] stringForKey:@"genreIdSelectedString"];
            NSArray *stringSeparatedId = [saveGenreId componentsSeparatedByString:@"+"];
            self.genreIdSelected = [NSMutableArray arrayWithArray:stringSeparatedId];
            
            [self callSearchSecondTime:saveGenre];
            if (!receivedGenre) {
                [self callGenreSecondTime];
            }
            
        } else {
            self.loadingLabel.hidden = NO;
            self.spinner.hidden = NO;
            [self.spinner startAnimating];
            [self callGenre];
        }
        
    } else {
        
        [self performSegueWithIdentifier:@"TutorialPhase" sender:@0];
    }

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)callSearchSecondTime:(NSString *)saveGenre
{
   
    [self.youtube getRecommendSearchYoutube:saveGenre withNextPage:NO];
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
     self.loadingLabel.hidden = NO;
    //[self presentViewController:alert animated:NO completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoId)
                                                 name:@"LoadVideoId" object:nil];
    
}

- (void)callSearchFirstTime:(NSString *)saveGenre
{
    [self.youtube getRecommendSearchYoutube:saveGenre withNextPage:NO];
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
     self.loadingLabel.hidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoId)
                                                 name:@"LoadVideoId" object:nil];
    
}


- (void)callGenre
{
    [self.genre getGenreFromYoutube];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedGenre)
                                                 name:@"LoadGenreTitle" object:nil];
}

- (void)callGenreSecondTime
{
    [self.genre getGenreFromYoutube];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedGenreSecondtime)
                                                 name:@"LoadGenreTitle" object:nil];
}

- (void)receivedGenreSecondtime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"received genre");
        receivedGenre = YES;
        [self callPerformTabbar];
    });
}

- (void)receivedGenre
{
    dispatch_async(dispatch_get_main_queue(), ^{
        receivedGenre = YES;
        [self performSegueWithIdentifier:@"SettingView" sender:@0];
    });
}

- (void)receivedLoadVideoId
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        NSLog(@"received youtube");
        receivedYoutube = YES;
        [self callPerformTabbar];
        
    });
    
}
- (void)callPerformTabbar
{
    if (receivedGenre && receivedYoutube) {
        [self performSegueWithIdentifier:@"SubmitToTabbarController" sender:@0];
    } else {
        NSLog(@"not YET");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SubmitToTabbarController"]){
        NSNumber *indexShow = @0;
        NSLog(@"tabbar segue");
        MainTabBarViewController *dest = segue.destinationViewController;
        dest.youtube = self.youtube;
        dest.recommendYoutube = self.youtube;
        dest.genreSelected = self.genreSelected;
        dest.genreIdSelected = self.genreIdSelected;
        dest.genreIds= self.genre.genreIds;
        dest.genreTitles = self.genre.genreTitles;
        [dest setSelectedIndex:indexShow.unsignedIntegerValue];

    } else if ([segue.identifier isEqualToString:@"SettingView"]) {
        FirstSettingTableViewController *newVC = segue.destinationViewController;
        newVC.delegate = self;
        newVC.genreList = self.genre.genreTitles;
        newVC.genreIdList = self.genre.genreIds;
        [FirstScreenViewController setPresentationStyleForSelfController:self presentingController:newVC];
        
    }
}

+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        //iOS 8.0 and above
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}

- (void)firstSettingTableViewControllerDidSelected:(FirstSettingTableViewController *)firstSettingViewController
{
    NSLog(@"first setting did selected");
    self.genreSelected = firstSettingViewController.genreSelected;
    NSString *genreSelectedString = @"";
    for(int i = 0 ; i < [self.genreSelected count] ; i++){
        genreSelectedString = [NSString stringWithFormat:@"%@ %@", genreSelectedString, [self.genreSelected objectAtIndex:i]];
    }
    genreSelectedString = [genreSelectedString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [self callSearchFirstTime:genreSelectedString];
}


@end
