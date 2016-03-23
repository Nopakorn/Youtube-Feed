//
//  GenreTableViewController.m
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 3/22/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "GenreTableViewController.h"
#import "GenreListTableViewController.h"
#import "SettingCustomCell.h"

@interface GenreTableViewController ()

@end

@implementation GenreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.genreYoutube = [[Youtube alloc] init];
    
    //self.genreSelected = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self createGerne];
     NSLog(@"View did load");
}

- (void)viewDidAppear:(BOOL)animated
{
    self.genreYoutube = [[Youtube alloc] init];
    NSLog(@"View did appear");
}

- (void) viewDidDisappear:(BOOL)animated
{
     NSLog(@"View did disappear");
}

- (void)createGerne
{
    self.genreList = [[NSMutableArray alloc] initWithObjects:@"Pop", @"Rock", @"Alternative Rock", @"Classical", @"Country", @"Dance", @"Folk", @"Indie", @"Jazz", @"Hip-hop", nil];
    NSLog(@"count in create %lu",(unsigned long)[self.genreList count]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.genreList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentifier = @"SettingCustomCell";
    
    SettingCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SettingCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.type.text = [self.genreList objectAtIndex:indexPath.row];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.searchTerm = [self.genreList objectAtIndex:indexPath.row];
    [self callYoutube:self.searchTerm];
}


- (void)callYoutube:(NSString *)searchTerm
{
    self.genreYoutube = [[Youtube alloc] init];
    [self.genreYoutube getGenreSearchYoutube:searchTerm withNextPage:NO];
    
    alert = [UIAlertController alertControllerWithTitle:nil message:@"Loading\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(130.5, 65.5);
    spinner.color = [UIColor blackColor];
    [alert.view addSubview:spinner];
    [spinner startAnimating];
    [self presentViewController:alert animated:NO completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadGenreVideoId)
                                                 name:@"LoadGenreVideoId" object:nil];
}


- (void)receivedLoadGenreVideoId
{
    NSLog(@"received load");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadGenreVideoId" object:nil];
        [alert dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"SubmitGenre" sender:nil];
    });
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SubmitGenre"]){
        NSLog(@"perform genre");
        GenreListTableViewController *dest = segue.destinationViewController;
        dest.genreYoutube = self.genreYoutube;
        dest.searchTerm = self.searchTerm;
    }
}

@end
