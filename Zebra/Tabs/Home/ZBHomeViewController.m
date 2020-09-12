//
//  ZBHomeViewController.m
//  Zebra
//
//  Created by Wilson Styres on 9/11/20.
//  Copyright © 2020 Wilson Styres. All rights reserved.
//

#import "ZBHomeViewController.h"

#import "Settings/ZBMainSettingsTableViewController.h"

@interface ZBHomeViewController ()

@end

@implementation ZBHomeViewController

#pragma mark - Initializers

- (id)init {
    self = [super init];
    
    if (self) {
        self.title = NSLocalizedString(@"Home", @"");
    }
    
    return self;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"] landscapeImagePhone:[UIImage imageNamed:@"Settings"] style:UIBarButtonItemStylePlain target:self action:@selector(presentSettings)];
    // Do any additional setup after loading the view from its nib.
}

- (void)presentSettings {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZBMainSettingsTableViewController *settingsController = [storyboard instantiateViewControllerWithIdentifier:@"settingsNavController"];
    [[self navigationController] presentViewController:settingsController animated:YES completion:nil];
}

@end
