//
//  GenreTableViewController.h
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 3/22/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Youtube.h"
#import <UIEMultiAccess/UIEMultiAccess.h>

@interface GenreTableViewController : UITableViewController
{
    UIAlertController *alert;
}

@property (weak, nonatomic) IBOutlet UIImageView *genreIconTitle;
@property (strong, nonatomic) Youtube *genreYoutube;
@property (nonatomic, copy) NSString *searchTerm;

@property (nonatomic, retain) NSMutableArray *genreList;


@end
