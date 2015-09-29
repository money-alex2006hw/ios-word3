//
//  GameViewController.h
//  words
//
//  Created by Marius Rott on 9/4/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordTable.h"
#import "GameSession.h"
#import "StoreCoinsViewController.h"

@class Game;

@protocol GameViewControllerDelegate <NSObject>

- (void)onResume;
- (void)onRestart;
- (void)onBack;
- (void)onNext;

@end

@interface GameViewController : UIViewController <WordTableDelegate, GameSessionDelegate, GameViewControllerDelegate, StoreCoinsViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIButton *buttonStore;
@property (nonatomic, retain) IBOutlet UIButton *buttonHint;
@property (nonatomic, retain) IBOutlet UIButton *buttonRemoveChars;
@property (nonatomic, retain) IBOutlet UIButton *buttonResolveGame;
@property (nonatomic, retain) IBOutlet UIButton *buttonPause;
@property (nonatomic, retain) IBOutlet UILabel *labelStoreCoins;
@property (nonatomic, retain) IBOutlet UILabel *labelTmpWord;
@property (nonatomic, retain) IBOutlet UILabel *labelTime;
@property (nonatomic, retain) IBOutlet UILabel *labelBestTime;
@property (nonatomic, retain) IBOutlet UILabel *labelBestTimeText;
@property (nonatomic, retain) IBOutlet UIView *viewWordTable;
@property (nonatomic, retain) IBOutlet UIView *viewWords;
@property (nonatomic, retain) IBOutlet UIView *viewFooter;

- (id)initWithGame:(Game*)game parentViewController:(UIViewController*)viewController;

- (IBAction)doButtonStore:(id)sender;
- (IBAction)doButtonHint:(id)sender;
- (IBAction)doButtonRemoveChars:(id)sender;
- (IBAction)doButtonResolveGame:(id)sender;
- (IBAction)doButtonPause:(id)sender;


@end
