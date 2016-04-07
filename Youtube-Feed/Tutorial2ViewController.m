//
//  Tutorial2ViewController.m
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 4/7/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "Tutorial2ViewController.h"

@interface Tutorial2ViewController ()

@end

@implementation Tutorial2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)prevButtonTutorialPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)nextButtonPressed:(id)sender {
      [self performSegueWithIdentifier:@"NextTutorial3" sender:nil];
}
@end
