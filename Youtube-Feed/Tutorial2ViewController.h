//
//  Tutorial2ViewController.h
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 4/7/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "ViewController.h"

@interface Tutorial2ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *prevButtonTutorial;
@property (weak, nonatomic) IBOutlet UIButton *nextButtonTutorial;

- (IBAction)prevButtonTutorialPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLeadingPrevButtonTutorial;

@end
