//
//  ZBHomeViewController.m
//  Zebra
//
//  Created by Wilson Styres on 9/11/20.
//  Copyright © 2020 Wilson Styres. All rights reserved.
//

#import "ZBHomeViewController.h"

@interface ZBHomeViewController ()

@end

@implementation ZBHomeViewController

- (id)init {
    self = [super init];
    
    if (self) {
        self.title = NSLocalizedString(@"Home", @"");
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Hi!");
    // Do any additional setup after loading the view from its nib.
}

@end
