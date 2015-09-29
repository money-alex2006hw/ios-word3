//
//  StoreCoinsViewController.m
//  words
//
//  Created by Marius Rott on 9/5/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "StoreCoinsViewController.h"
#import "CoinsManager.h"
#import "configuration.h"
#import "MGIAPHelper.h"
#import "SoundUtils.h"
#import "ImageUtils.h"
#import <StoreKit/StoreKit.h>
#import "Reachability.h"
#import "MGAdsManager.h"

@interface StoreCoinsViewController ()
{
    
}

@property (nonatomic, assign) id<StoreCoinsViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL showNotEnough;

@property (nonatomic, retain) NSArray *skProducts;

- (void)loadSKProducts;
- (void)refreshView;

- (void)notificationProductPurchased:(NSNotification *)notification;
- (void)notificationProductPurchaseFailed:(NSNotification *)notification;

- (void)networkChanged:(NSNotification *)notification;

@end

@implementation StoreCoinsViewController

+ (StoreCoinsViewController *)sharedInstanceWithDelegate:(id<StoreCoinsViewControllerDelegate>)delegate showNotEnoughCoins:(BOOL)showNotEnough
{
    static StoreCoinsViewController *instance;
    if (instance == nil)
    {
        instance = [[StoreCoinsViewController alloc] init];
    }
    instance.delegate = delegate;
    instance.showNotEnough = showNotEnough;
    
    return instance;
}

- (id)init
{
    NSString *xib = @"StoreCoinsViewController";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        xib = @"StoreCoinsViewController_iPad";
    }
    self = [super initWithNibName:xib bundle:nil];
    if (self)
    {
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
    [self.skProducts release];
    [self.buttonCoins1 release];
    [self.buttonCoins2 release];
    [self.buttonCoins3 release];
    [self.buttonCoins4 release];
    
    [self.labelTitle release];
    [self.labelStoreCoins release];
    
    [self.labelCoins1Title release];
    [self.labelCoins2Title release];
    [self.labelCoins3Title release];
    [self.labelCoins4Title release];
    
    [self.labelCoins1Subtitle release];
    [self.labelCoins2Subtitle release];
    [self.labelCoins3Subtitle release];
    [self.labelCoins4Subtitle release];
    
    [self.labelCoins1Price release];
    [self.labelCoins2Price release];
    [self.labelCoins3Price release];
    [self.labelCoins4Price release];
    
    [self.labelCoins1Buy release];
    [self.labelCoins2Buy release];
    [self.labelCoins3Buy release];
    [self.labelCoins4Buy release];
    
    [self.labelNotEnough release];
    
    [self.bannerView release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    if (reachability.currentReachabilityStatus != NotReachable)
    {
        [self loadSKProducts];
    }
    else
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkConnection", nil)
                                                         message:NSLocalizedString(@"networkConnectionMsg", nil)
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                               otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.labelTitle.font = [UIFont fontWithName:@"Lucida Calligraphy" size:30];
        self.labelStoreCoins.font = [UIFont fontWithName:@"Nexa Bold" size:15];
        self.labelNotEnough.font = [UIFont fontWithName:@"Segoe UI" size:36];
        
        self.labelCoins1Title.font = [UIFont fontWithName:@"Lucida Calligraphy" size:24];
        self.labelCoins2Title.font = [UIFont fontWithName:@"Lucida Calligraphy" size:24];
        self.labelCoins3Title.font = [UIFont fontWithName:@"Lucida Calligraphy" size:24];
        self.labelCoins4Title.font = [UIFont fontWithName:@"Lucida Calligraphy" size:24];
        
        self.labelCoins1Subtitle.font = [UIFont fontWithName:@"Segoe UI" size:22];
        self.labelCoins2Subtitle.font = [UIFont fontWithName:@"Segoe UI" size:22];
        self.labelCoins3Subtitle.font = [UIFont fontWithName:@"Segoe UI" size:22];
        self.labelCoins4Subtitle.font = [UIFont fontWithName:@"Segoe UI" size:22];
        
        self.labelCoins1Price.font = [UIFont fontWithName:@"Nexa Bold" size:22];
        self.labelCoins2Price.font = [UIFont fontWithName:@"Nexa Bold" size:22];
        self.labelCoins3Price.font = [UIFont fontWithName:@"Nexa Bold" size:22];
        self.labelCoins4Price.font = [UIFont fontWithName:@"Nexa Bold" size:22];
        
        self.labelCoins1Buy.font = [UIFont fontWithName:@"Nexa Bold" size:18];
        self.labelCoins2Buy.font = [UIFont fontWithName:@"Nexa Bold" size:18];
        self.labelCoins3Buy.font = [UIFont fontWithName:@"Nexa Bold" size:18];
        self.labelCoins4Buy.font = [UIFont fontWithName:@"Nexa Bold" size:18];
    }
    else
    {
        self.labelTitle.font = [UIFont fontWithName:@"Lucida Calligraphy" size:20];
        self.labelStoreCoins.font = [UIFont fontWithName:@"Nexa Bold" size:12];
        self.labelNotEnough.font = [UIFont fontWithName:@"Segoe UI" size:16];
        
        self.labelCoins1Title.font = [UIFont fontWithName:@"Lucida Calligraphy" size:14];
        self.labelCoins2Title.font = [UIFont fontWithName:@"Lucida Calligraphy" size:14];
        self.labelCoins3Title.font = [UIFont fontWithName:@"Lucida Calligraphy" size:14];
        self.labelCoins4Title.font = [UIFont fontWithName:@"Lucida Calligraphy" size:14];
        
        self.labelCoins1Subtitle.font = [UIFont fontWithName:@"Segoe UI" size:12];
        self.labelCoins2Subtitle.font = [UIFont fontWithName:@"Segoe UI" size:12];
        self.labelCoins3Subtitle.font = [UIFont fontWithName:@"Segoe UI" size:12];
        self.labelCoins4Subtitle.font = [UIFont fontWithName:@"Segoe UI" size:12];
        
        self.labelCoins1Price.font = [UIFont fontWithName:@"Nexa Bold" size:14];
        self.labelCoins2Price.font = [UIFont fontWithName:@"Nexa Bold" size:14];
        self.labelCoins3Price.font = [UIFont fontWithName:@"Nexa Bold" size:14];
        self.labelCoins4Price.font = [UIFont fontWithName:@"Nexa Bold" size:14];
        
        self.labelCoins1Buy.font = [UIFont fontWithName:@"Nexa Bold" size:12];
        self.labelCoins2Buy.font = [UIFont fontWithName:@"Nexa Bold" size:12];
        self.labelCoins3Buy.font = [UIFont fontWithName:@"Nexa Bold" size:12];
        self.labelCoins4Buy.font = [UIFont fontWithName:@"Nexa Bold" size:12];
    }
    
    self.labelNotEnough.textColor = THEME_COLOR_RED;
    self.labelNotEnough.text = NSLocalizedString(@"coinsMsg", nil);
    
    self.labelTitle.text = NSLocalizedString(@"coins", nil);
    
    self.labelCoins1Title.text = STORE_BUNDLE_IN_APP_1_TITLE;
    self.labelCoins2Title.text = STORE_BUNDLE_IN_APP_2_TITLE;
    self.labelCoins3Title.text = STORE_BUNDLE_IN_APP_3_TITLE;
    self.labelCoins4Title.text = STORE_BUNDLE_IN_APP_4_TITLE;
    
    self.labelCoins1Subtitle.text = STORE_BUNDLE_IN_APP_1_DESCRIPTION;
    self.labelCoins2Subtitle.text = STORE_BUNDLE_IN_APP_2_DESCRIPTION;
    self.labelCoins3Subtitle.text = STORE_BUNDLE_IN_APP_3_DESCRIPTION;
    self.labelCoins4Subtitle.text = STORE_BUNDLE_IN_APP_4_DESCRIPTION;
    
    self.labelCoins1Buy.text = NSLocalizedString(@"buy", nil);
    self.labelCoins2Buy.text = NSLocalizedString(@"buy", nil);
    self.labelCoins3Buy.text = NSLocalizedString(@"buy", nil);
    self.labelCoins4Buy.text = NSLocalizedString(@"buy", nil);
    
    UIImage *imageBackButton = [ImageUtils imageWithColor:THEME_COLOR_GRAY_LIGHT
                                                 rectSize:self.buttonCoins1.frame.size];
    
    [self.buttonCoins1 setBackgroundImage:imageBackButton
                                 forState:UIControlStateHighlighted];
    [self.buttonCoins2 setBackgroundImage:imageBackButton
                                 forState:UIControlStateHighlighted];
    [self.buttonCoins3 setBackgroundImage:imageBackButton
                                 forState:UIControlStateHighlighted];
    [self.buttonCoins4 setBackgroundImage:imageBackButton
                                 forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshView];
    
    if (self.showNotEnough)
    {
        self.labelNotEnough.hidden = NO;
    }
    else
    {
        self.labelNotEnough.hidden = YES;
    }
    
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.bannerView = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard] autorelease];
        self.bannerView.adUnitID = MY_BANNER_UNIT_ID_IPAD;
        CGRect frame = self.bannerView.frame;
        frame.origin.x = 20;
        frame.origin.y = 934;
        self.bannerView.frame = frame;
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
        
        //  table frame update
        //        CGRect frameTable = self.tableView.frame;
        //        frameTable.size.height = self.view.frame.size.height - frameTable.origin.y - 50;
        //        self.tableView.frame = frameTable;
    }
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;
    [self.view addSubview:self.bannerView];
    
    // Initiate a generic request to load it with an ad.
    [self.bannerView loadRequest:[GADRequest request]];
}


- (void)loadSKProducts
{
    if (!self.skProducts.count)
    {
        [[MGIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success)
            {
                self.skProducts = products;
                [self refreshView];
            }
        }];
    }
}

- (void)refreshView
{
//    NSLog(@"%d videos", [[CoinsManager sharedInstance] getVideoViews]);
    
    self.labelStoreCoins.text = [NSString stringWithFormat:@"%d", [[CoinsManager sharedInstance] getCoins]];
    
    SKProduct *coins1 = [self getSKProductForBundleID:STORE_BUNDLE_IN_APP_1];
    if (coins1)
        self.labelCoins1Price.text = [MGIAPHelper priceForSKProduct:coins1];
    SKProduct *coins2 = [self getSKProductForBundleID:STORE_BUNDLE_IN_APP_2];
    if (coins2)
        self.labelCoins2Price.text = [MGIAPHelper priceForSKProduct:coins2];
    SKProduct *coins3 = [self getSKProductForBundleID:STORE_BUNDLE_IN_APP_3];
    if (coins3)
        self.labelCoins3Price.text = [MGIAPHelper priceForSKProduct:coins3];
    SKProduct *coins4 = [self getSKProductForBundleID:STORE_BUNDLE_IN_APP_4];
    if (coins4)
        self.labelCoins4Price.text = [MGIAPHelper priceForSKProduct:coins4];
    
}

- (void)doButtonBuyCoins:(id)sender
{
    int tag = ((UIButton*)sender).tag;
    NSString *bundleID = @"";
    switch (tag)
    {
        case 1: bundleID = STORE_BUNDLE_IN_APP_1; break;
        case 2: bundleID = STORE_BUNDLE_IN_APP_2; break;
        case 3: bundleID = STORE_BUNDLE_IN_APP_3; break;
        case 4: bundleID = STORE_BUNDLE_IN_APP_4; break;
    }
    
    SKProduct *product = [self getSKProductForBundleID:bundleID];
    if (!product)
        return;
    
    [[MGIAPHelper sharedInstance] buyProduct:product];
    
   
}

- (void)doButtonClose:(id)sender
{
    
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeBack];
    
    if (_delegate && [_delegate respondsToSelector:@selector(storeCoinsViewControllerOnClose)])
    {
        [_delegate storeCoinsViewControllerOnClose];
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)notificationProductPurchased:(NSNotification *)notification
{
    NSString *bundleID = notification.object;
    int coins = 0;
    if ([bundleID caseInsensitiveCompare:STORE_BUNDLE_IN_APP_1] == NSOrderedSame)
    {
        coins = STORE_BUNDLE_IN_APP_1_COINS;
    }
    else if ([bundleID caseInsensitiveCompare:STORE_BUNDLE_IN_APP_2] == NSOrderedSame)
    {
        coins = STORE_BUNDLE_IN_APP_2_COINS;
    }
    else if ([bundleID caseInsensitiveCompare:STORE_BUNDLE_IN_APP_3] == NSOrderedSame)
    {
        coins = STORE_BUNDLE_IN_APP_3_COINS;
    }
    else if ([bundleID caseInsensitiveCompare:STORE_BUNDLE_IN_APP_4] == NSOrderedSame)
    {
        coins = STORE_BUNDLE_IN_APP_4_COINS;
    }
    if (coins == 0)
    {
        return;
    }
      
    [[CoinsManager sharedInstance] addCoins:coins];
    self.labelNotEnough.text = [NSString stringWithFormat:NSLocalizedString(@"receivedCoinsMsg", nil), coins];
    self.labelNotEnough.hidden = NO;
    [[SoundUtils sharedInstance] playMusic:SoundTypeCoinsAdded];
    [self refreshView];
    
    NSLog(@"current coins %d", [[CoinsManager sharedInstance] getCoins]);
    
    if(self.bannerView)
    {
        self.bannerView.hidden = YES;
    }
}

- (void)notificationProductPurchaseFailed:(NSNotification *)notification
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"purchaseError", nil)
                                                     message:NSLocalizedString(@"purchaseErrorMsg", nil)
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil] autorelease];
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

@end
