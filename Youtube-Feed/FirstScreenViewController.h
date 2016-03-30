//
//  FirstScreenViewController.h
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 3/30/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "ViewController.h"
#import "FirstSettingTableViewController.h"
#import "Youtube.h"

@interface FirstScreenViewController : UIViewController<UIAlertViewDelegate, FirstSettingTableViewControllerDelegate >
{
    UIAlertController *alert;
}

@property (strong, nonatomic) Youtube *youtube;
@property (nonatomic, retain) NSMutableArray *genreList;
@property (nonatomic, retain) NSMutableArray *genreSelected;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@end
