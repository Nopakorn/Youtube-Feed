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
    self.navigationController.navigationBarHidden = YES;
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"tutorial/HTML/tutorial02" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlFile];
    [self.tutorialWebView loadHTMLString:htmlString baseURL:baseURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)prevButtonTutorialPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)nextButtonPressed:(id)sender {
      [self performSegueWithIdentifier:@"NextTutorial3" sender:nil];
}
@end
