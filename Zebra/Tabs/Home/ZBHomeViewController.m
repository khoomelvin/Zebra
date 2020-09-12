//
//  ZBHomeViewController.m
//  Zebra
//
//  Created by Wilson Styres on 9/11/20.
//  Copyright © 2020 Wilson Styres. All rights reserved.
//

#import "ZBHomeViewController.h"

#import "Settings/ZBMainSettingsTableViewController.h"

#import <ZBAppDelegate.h>
#import <ZBLog.h>
#import <Tabs/Sources/Helpers/ZBSource.h>
#import <Tabs/Sources/Helpers/ZBSourceManager.h>

@interface ZBHomeViewController () {
    NSArray <ZBPackage *> *featuredPackages;
    NSArray <NSDictionary *> *redditPosts;
}

@end

@implementation ZBHomeViewController

#pragma mark - Initializers

- (id)init {
    self = [super init];
    
    if (self) {
        self.title = NSLocalizedString(@"Home", @"");
        
        [self downloadFeaturedPackages:NO];
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

#pragma mark - Featured Packages

- (void)downloadFeaturedPackages:(BOOL)useCaching {
    NSArray *sources = [[ZBSourceManager sharedInstance] sources];
    dispatch_group_t downloadGroup = dispatch_group_create();

    for (ZBSource *source in sources) {
        dispatch_group_enter(downloadGroup);

        NSURLSession *session;
        NSString *filePath = [[ZBAppDelegate listsLocation] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Featured", source.baseFilename]];
        if (useCaching && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *fileError;
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&fileError];
            NSDate *date = fileError != nil ? [NSDate distantPast] : [attributes fileModificationDate];

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [formatter setTimeZone:gmt];
            [formatter setDateFormat:@"E, d MMM yyyy HH:mm:ss"];

            NSString *modificationDate = [NSString stringWithFormat:@"%@ GMT", [formatter stringFromDate:date]];

            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            configuration.HTTPAdditionalHeaders = @{@"If-Modified-Since": modificationDate};

            session = [NSURLSession sessionWithConfiguration:configuration];
        }
        else {
            session = [NSURLSession sharedSession];
        }

        NSMutableArray *featuredPackages = [NSMutableArray new];

        NSURL *featuredURL = [NSURL URLWithString:@"sileo-featured.json" relativeToURL:source.mainDirectoryURL];
        NSURLSessionDataTask *task = [session dataTaskWithURL:featuredURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if (error != NULL) {
                ZBLog(@"[Zebra] Error while downloading featured JSON for %@: %@", source, error);
                dispatch_group_leave(downloadGroup);
                return;
            }

            if (data != NULL && [httpResponse statusCode] != 404) {
                NSError *jsonReadError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonReadError];
                if (jsonReadError != NULL) {
                    ZBLog(@"[Zebra] Error while parsing featured JSON for %@: %@", source, jsonReadError);
                    dispatch_group_leave(downloadGroup);
                    return;
                }

                if ([json objectForKey:@"banners"]) {
                    NSArray *banners = [json objectForKey:@"banners"];
                    if (banners.count) {
                        [featuredPackages addObjectsFromArray:banners];
                    }
                }
            }

            NSString *filename = [NSString stringWithFormat:@"%@_Featured", source.baseFilename];
            if ([featuredPackages count] > 0) {
                [featuredPackages writeToFile:[[ZBAppDelegate listsLocation] stringByAppendingPathComponent:filename] atomically:true];
            }

            dispatch_group_leave(downloadGroup);
        }];

        [task resume];
    }

    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{
        [self chooseFeaturedPackages];
    });
}

- (void)chooseFeaturedPackages {
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[ZBAppDelegate listsLocation] error:nil];
    NSArray *featuredCacheFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '_Featured'"]];

    NSMutableArray *choices = [NSMutableArray new];
    for (NSString *path in featuredCacheFiles) {
        NSArray *contents = [NSArray arrayWithContentsOfFile:[[ZBAppDelegate listsLocation] stringByAppendingPathComponent:path]];
        [choices addObjectsFromArray:contents];
    }
    
    // Choose 5 random packages from the choices
    NSUInteger numberOfPackages = MIN(choices.count, 5); // Configurable later maybe?
    NSMutableSet *selection = [NSMutableSet new];

    while (selection.count < numberOfPackages) {
        id randomObject = [choices objectAtIndex:(arc4random() % choices.count)];
        [selection addObject:randomObject];
    }

    featuredPackages = [selection allObjects];
    NSLog(@"random choices %@", featuredPackages);
}


#pragma mark - Community News

@end
