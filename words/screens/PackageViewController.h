//
//  PackageViewController.h
//  words
//
//  Created by Marius Rott on 9/5/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreCoinsViewController.h"
//#import "GADBannerView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>


@class Category;
@class PackageGameCell;

@interface PackageViewController : UIViewController <StoreCoinsViewControllerDelegate, GADBannerViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet PackageGameCell *cellGame;
@property (nonatomic, retain) UINib *cellLoaderGame;
@property (nonatomic, retain) IBOutlet UILabel *labelTitle;

@property (nonatomic, retain) GADBannerView *bannerView;

- (id)initWithCategory:(Category*)category;

- (IBAction)doButtonBack:(id)sender;
- (IBAction)doButtonStore:(id)sender;

@end
