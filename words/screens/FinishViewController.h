//
//  FinishViewController.h
//  words
//
//  Created by Marius Rott on 9/12/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"
//#import "GADBannerView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@class GameSession;

@interface FinishViewController : UIViewController <GADBannerViewDelegate>

@property (nonatomic, retain) IBOutlet UILabel *labelTitle;
@property (nonatomic, retain) IBOutlet UILabel *labelGameName;
@property (nonatomic, retain) IBOutlet UILabel *labelPoints;
@property (nonatomic, retain) IBOutlet UILabel *labelTime;
@property (nonatomic, retain) IBOutlet UIButton *buttonMoreGames;
@property (nonatomic, retain) IBOutlet UIButton *buttonPackage;
@property (nonatomic, retain) IBOutlet UIButton *buttonSettings;
@property (nonatomic, retain) IBOutlet UIButton *buttonNext;
@property (nonatomic, retain) IBOutlet UIButton *buttonRestart;
@property (nonatomic, retain) IBOutlet UIButton *buttonFacebook;
@property (nonatomic, retain) IBOutlet UIButton *buttonTwitter;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonNext;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonRestart;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonSettings;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonPackages;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonMoreGames;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewMoreGames;
@property (nonatomic, retain) IBOutlet UIView *viewStars;
@property (nonatomic, retain) IBOutlet UILabel *labelShare;
@property (nonatomic, retain) IBOutlet UILabel *labelFacebookCoins;
@property (nonatomic, retain) IBOutlet UILabel *labelTwitterCoins;
@property (nonatomic, retain) IBOutlet UIView *viewShareSeparator;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewFacebookCoins;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewTwitterCoins;
@property (nonatomic, retain) GADBannerView *bannerView;


- (id)initWithDelegate:(id<GameViewControllerDelegate>)delegate gameSession:(GameSession*)gameSession isPaused:(BOOL)isPaused;

- (IBAction)doButtonBack:(id)sender;
- (IBAction)doButtonNext:(id)sender;
- (IBAction)doButtonRestart:(id)sender;
- (IBAction)doButtonMoreGames:(id)sender;
- (IBAction)doButtonPackage:(id)sender;
- (IBAction)doButtonSettings:(id)sender;
- (IBAction)doButtonFacebook:(id)sender;
- (IBAction)doButtonTwitter:(id)sender;

@end
