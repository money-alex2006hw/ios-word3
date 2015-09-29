//
//  StorePackagesViewController.m
//  flows
//
//  Created by Marius Rott on 10/23/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "StorePackagesViewController.h"
#import "configuration.h"
#import "MGIAPHelper.h"
#import "SoundUtils.h"
#import "ImageUtils.h"
#import <StoreKit/StoreKit.h>
#import "Reachability.h"
#import "MGAdsManager.h"
#import "CoreDataUtils.h"
#import "Category.h"
#import "StorePackageCell.h"
#import "MGAdsManager.h"

@interface StorePackagesViewController ()
{
    
}

@property (nonatomic, retain) NSArray *skProducts;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSString *stringMessage;

- (void)loadSKProducts;

- (void)notificationProductPurchased:(NSNotification *)notification;
- (void)notificationProductPurchaseFailed:(NSNotification *)notification;

- (void)networkChanged:(NSNotification *)notification;

@end

@implementation StorePackagesViewController

- (id)init
{
    NSString *xib = @"StorePackagesViewController";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        xib = @"StorePackagesViewController_iPad";
    }
    self = [super initWithNibName:xib bundle:nil];
    if (self)
    {
        //  load data
        self.categories = [[CoreDataUtils sharedInstance] getAllCategories];
        
        //  load cell
        NSString *xib = @"StorePackageCell";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            xib = @"StorePackageCell_iPad";
        }
        self.cellLoaderPackage = [UINib nibWithNibName:xib bundle:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationProductPurchased:)
                                                     name:IAPHelperProductPurchasedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationProductPurchaseFailed:)
                                                     name:IAPHelperProductPurchaseFailedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self.viewBackground release];
    [self.labelTitle release];
    [self.tableView release];
    [self.cellLoaderPackage release];
    [self.cellPackage release];
    [self.stringMessage release];
    [self.bannerView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.viewBackground.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"window_store.png"]];
//    self.view.backgroundColor = THEME_COLOR_GRAY_BORDER;
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    if (reachability.currentReachabilityStatus != NotReachable)
    {
        [self loadSKProducts];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkConnection", nil)
                                                        message:NSLocalizedString(@"networkConnectionMsg", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.labelTitle.font = [UIFont fontWithName:@"Lucida Calligraphy" size:30];
    }
    else
    {
        self.labelTitle.font = [UIFont fontWithName:@"Lucida Calligraphy" size:20];
    }
    self.labelTitle.text = NSLocalizedString(@"unlockPackages", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.viewBackground.center = self.view.center;
    [self configureBannerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureBannerView
{
    if (self.bannerView)
    {
        return;
    }
    if (![[MGAdsManager sharedInstance] isAdsEnabled])
    {
        return;
    }
    
    //  table frame update
    CGRect frameTable = self.tableView.frame;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.bannerView = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard] autorelease];
        self.bannerView.adUnitID = MY_BANNER_UNIT_ID_IPAD;
        CGRect frame = self.bannerView.frame;
        frame.origin.x = 20;
        frame.origin.y = 934;
        self.bannerView.frame = frame;
        
        frameTable.size.height = self.view.frame.size.height - frameTable.origin.y - 90;
    }
    else
    {
        self.bannerView = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner] autorelease];
        self.bannerView.adUnitID = MY_BANNER_UNIT_ID;
        NSLog(@"%f", self.view.frame.size.height);
        CGRect frame = self.bannerView.frame;
        frame.origin.x = 0;
        frame.origin.y = self.view.frame.size.height - 50;
        self.bannerView.frame = frame;
        
        frameTable.size.height = self.view.frame.size.height - frameTable.origin.y - 50;
    }
    
    self.tableView.frame = frameTable;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;
    [self.view addSubview:self.bannerView];
    
    // Initiate a generic request to load it with an ad.
    [self.bannerView loadRequest:[GADRequest request]];
}

- (void)doButtonClose:(id)sender
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeBack];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)networkChanged:(NSNotification *)notification
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
    {
        NSLog(@"not reachable");
    }
    else
    {
        [self loadSKProducts];
    }
}

- (void)loadSKProducts
{
    if (!self.skProducts.count)
    {
        [[MGIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success)
            {
                self.skProducts = products;
                [self.tableView reloadData];
            }
        }];
    }
}


- (void)notificationProductPurchased:(NSNotification *)notification
{
    if(self.bannerView)
    {
        self.bannerView.hidden = YES;
    }
    
    NSString *bundleID = notification.object;
    
    
    [self.tableView reloadData];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                    message:[NSString stringWithFormat:@"You have successfully unlocked %@!", self.stringMessage]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)notificationProductPurchaseFailed:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase error"
                                                    message:@"There was an error completing your purchase. Please try again later!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (SKProduct *)getSKProductForBundleID:(NSString *)bundleID
{
    if (self.skProducts != nil && [self.skProducts count] > 0)
    {
        for (SKProduct *tmp in self.skProducts)
        {
            if ([tmp.productIdentifier compare:bundleID] == NSOrderedSame)
            {
                return tmp;
            }
        }
    }
    return nil;
}



#pragma mark tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    for (Category *category in self.categories)
    {
        NSLog(@"%@", category.bundleID);
        if (category.bundleID.length && ![[MGIAPHelper sharedInstance] productPurchased:category.bundleID])
        {
            count++;
        }
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = 77;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        height = 130;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"TABLE_VIEW_TYPE_STORE_CATEGORY"];
    if (cell == nil) {
        [self.cellLoaderPackage instantiateWithOwner:self options:nil];
        cell = self.cellPackage;
        self.cellPackage = nil;
    }
    
    [self.cellLoaderPackage instantiateWithOwner:self options:nil];
    
    [self configurePackageCell:(StorePackageCell*)cell
                   atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    
    NSString *bundleID;
    
    int count = 0, index = 0;
    for (Category *category in self.categories)
    {
        if (category.bundleID.length && ![[MGIAPHelper sharedInstance] productPurchased:category.bundleID])
        {
            if (index == indexPath.row)
            {
                break;
            }
            index++;
        }
        count++;
    }
    Category *category = [self.categories objectAtIndex:count];
    bundleID = category.bundleID;
    self.stringMessage = category.name;
    
    SKProduct *product = [self getSKProductForBundleID:bundleID];
    if (!product)
        return;
    
    [[MGIAPHelper sharedInstance] buyProduct:product];
}

- (void)configurePackageCell:(StorePackageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [[UIView new] autorelease];
    cell.selectedBackgroundView = [[UIView new] autorelease];
    
    int count = 0, index = 0;
    
    for (Category *category in self.categories)
    {
        count++;
        if (category.bundleID.length && ![[MGIAPHelper sharedInstance] productPurchased:category.bundleID])
        {
            if (index == indexPath.row)
            {
                break;
            }
            index++;
        }
    }
    Category *category = [self.categories objectAtIndex:count - 1];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        cell.labelName.font = [UIFont fontWithName:@"Lucida Calligraphy" size:26];
        cell.labelDescription.font = [UIFont fontWithName:@"Segoe UI" size:20];
        cell.labelPrice.font = [UIFont fontWithName:@"Nexa Bold" size:22];
    }
    else
    {
        cell.labelName.font = [UIFont fontWithName:@"Lucida Calligraphy" size:18];
        cell.labelDescription.font = [UIFont fontWithName:@"Segoe UI" size:14];
        cell.labelPrice.font = [UIFont fontWithName:@"Nexa Bold" size:22];
    }
    
    cell.labelDescription.textColor = THEME_COLOR_GRAY_TEXT;
    
    cell.labelName.text = NSLocalizedString(category.name, nil);
    cell.labelDescription.text = [NSString stringWithFormat:@"%d puzzles", category.games.count];
    cell.labelPrice.text = [MGIAPHelper priceForSKProduct:[self getSKProductForBundleID:category.bundleID]];
    
//    cell.labelName.textColor = [UIColor greenColor];
//    cell.labelDescription.textColor = THEME_COLOR_GRAY_TEXT;
    NSString *imageName = @"pack01.png";
    cell.imageViewIcon.image = [UIImage imageNamed:imageName];
}

#pragma mark -


@end
