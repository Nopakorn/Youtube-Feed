//
//  AddPlaylistPopUpViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/10/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "AddPlaylistPopUpViewController.h"
#import "PlaylistPopUpCustomCell.h"

@interface AddPlaylistPopUpViewController ()

@end

@implementation AddPlaylistPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)okButtonPressed:(id)sender
{
   
}

@end
