//
//  Tutorial4ViewController.h
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 4/7/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Tutorial4ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *submitTutorialButton;
- (IBAction)submitTutorialButtonPressed:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *prevButtonTutorial;
- (IBAction)prevButtonTutorialPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *tutorialWebView;

@end
