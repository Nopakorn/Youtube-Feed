//
//  AddPlaylistPopUpViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/10/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPlaylistPopUpViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *okButton;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)okButtonPressed:(id)sender;

@end
