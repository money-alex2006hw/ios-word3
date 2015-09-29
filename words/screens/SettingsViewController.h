//
//  SettingsViewController.h
//  words
//
//  Created by Marius Rott on 9/13/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
//#import "GADBannerView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
UINavigationControllerDelegate>

@property (nonatomic, retain) IBOutlet UILabel *labelTitle;

@property (nonatomic, retain) IBOutlet UILabel *labelButtonNotifications;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonSounds;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonEmail;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonRestore;

@property (nonatomic, retain) IBOutlet UILabel *labelButtonNotificationsOnOff;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonSoundsOnOff;

@property (nonatomic, retain) IBOutlet UIButton *buttonNotifications;
@property (nonatomic, retain) IBOutlet UIButton *buttonSounds;
@property (nonatomic, retain) IBOutlet UIButton *buttonEmail;
@property (nonatomic, retain) IBOutlet UIButton *buttonRestore;

@property (nonatomic, retain) GADBannerView *bannerView;

- (IBAction)doButtonClose:(id)sender;
- (IBAction)doButtonNotifications:(id)sender;
- (IBAction)doButtonSounds:(id)sender;
- (IBAction)doButtonEmail:(id)sender;
- (IBAction)doButtonRestore:(id)sender;
- (IBAction)doButtonCredits:(id)sender;


@end
