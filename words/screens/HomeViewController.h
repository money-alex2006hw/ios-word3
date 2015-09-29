//
//  HomeViewController.h
//  words
//
//  Created by Marius Rott on 9/4/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreCoinsViewController.h"
#import "HomePackageCell.h"
#import "HomeQuestCell.h"
//#import "GADBannerView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, StoreCoinsViewControllerDelegate, GADBannerViewDelegate>

@property (nonatomic, retain) IBOutlet UILabel *labelTitle;
@property (nonatomic, retain) IBOutlet UIButton *buttonCategories;
@property (nonatomic, retain) IBOutlet UIButton *buttonQuests;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewTabCategories;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewTabQuests;
@property (nonatomic, retain) IBOutlet UILabel *labelTabCategories;
@property (nonatomic, retain) IBOutlet UILabel *labelTabQuests;

@property (nonatomic, retain) IBOutlet UILabel *labelQuestLevelName;
@property (nonatomic, retain) IBOutlet UIButton *buttonStorePackages;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet HomePackageCell *cellPackage;
@property (nonatomic, retain) IBOutlet HomeQuestCell *cellQuest;

@property (nonatomic, retain) UINib *cellLoaderPackage;
@property (nonatomic, retain) UINib *cellLoaderQuest;

@property (nonatomic, retain) GADBannerView *bannerView;

- (IBAction)doButtonSettings:(id)sender;
- (IBAction)doButtonCategory:(id)sender;
- (IBAction)doButtonQuest:(id)sender;
- (IBAction)doButtonStore:(id)sender;
- (IBAction)doButtonQuickPlay:(id)sender;
- (IBAction)doButtonSkipQuest:(id)sender;
- (IBAction)doButtonStorePackages:(id)sender;

@end
