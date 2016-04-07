//
//  Tutorial4ViewController.m
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 4/7/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "Tutorial4ViewController.h"

@interface Tutorial4ViewController ()

@end

@implementation Tutorial4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)submitTutorialButtonPressed:(id)sender
{
    NSLog(@"Done tutorial");
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tutorialPass"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:Nil];
}


- (IBAction)prevButtonTutorialPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}
@end
