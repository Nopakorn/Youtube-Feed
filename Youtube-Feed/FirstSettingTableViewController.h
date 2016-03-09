//
//  FirstSettingTableViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/9/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"

@interface FirstSettingTableViewController : UITableViewController<UIAlertViewDelegate,UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource>
{
    UIAlertController *alert;
}

@property(strong, nonatomic) Youtube *youtube;
@property (nonatomic, retain) NSMutableArray *genreList;
@property (nonatomic, retain) NSMutableArray *genreSelected;


@property(weak,nonatomic) IBOutlet UIButton  *submitButton;
- (IBAction)submitButtonPressed:(id)sender;

@end
