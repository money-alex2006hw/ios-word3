//
//  StoreCoinsViewController.h
//  words
//
//  Created by Marius Rott on 9/5/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "GADBannerView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@protocol StoreCoinsViewControllerDelegate <NSObject>

- (void)storeCoinsViewControllerOnClose;

@end

@interface StoreCoinsViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *buttonCoins1;
@property (nonatomic, retain) IBOutlet UIButton *buttonCoins2;
@property (nonatomic, retain) IBOutlet UIButton *buttonCoins3;
@property (nonatomic, retain) IBOutlet UIButton *buttonCoins4;

@property (nonatomic, retain) IBOutlet UILabel *labelTitle;
@property (nonatomic, retain) IBOutlet UILabel *labelStoreCoins;

@property (nonatomic, retain) IBOutlet UILabel *labelCoins1Title;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins2Title;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins3Title;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins4Title;

@property (nonatomic, retain) IBOutlet UILabel *labelCoins1Subtitle;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins2Subtitle;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins3Subtitle;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins4Subtitle;

@property (nonatomic, retain) IBOutlet UILabel *labelCoins1Price;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins2Price;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins3Price;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins4Price;

@property (nonatomic, retain) IBOutlet UILabel *labelCoins1Buy;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins2Buy;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins3Buy;
@property (nonatomic, retain) IBOutlet UILabel *labelCoins4Buy;

@property (nonatomic, retain) IBOutlet UILabel *labelNotEnough;

@property (nonatomic, retain) GADBannerView *bannerView;

- (IBAction)doButtonBuyCoins:(id)sender;
- (IBAction)doButtonClose:(id)sender;

+ (StoreCoinsViewController*)sharedInstanceWithDelegate:(id<StoreCoinsViewControllerDelegate>)delegate showNotEnoughCoins:(BOOL)showNotEnough;

@end
