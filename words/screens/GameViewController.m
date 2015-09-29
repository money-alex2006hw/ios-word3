//
//  GameViewController.m
//  words
//
//  Created by Marius Rott on 9/4/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "GameViewController.h"
#import "FinishViewController.h"
#import "CoreDataUtils.h"
#import "SoundUtils.h"
#import "Game.h"
#import "Category.h"
#import "WordStr.h"
#import "configuration.h"
#import "CoinsManager.h"
#import "StorePayCoinsPopupManager.h"
#import <QuartzCore/QuartzCore.h>

@interface GameViewController ()
{
    WordTable *_wordTable;
    NSArray *_wordStrings;
    NSMutableArray *_labelWords;
    GameSession *_gameSession;
    UIViewController *_parentViewController;
    
    //  prevent multiple coin payment for the same hint
    bool _hintWasPayed;
}

@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) NSTimer *timerAnimations;

- (void)refreshView;
- (void)openStore:(BOOL)showNotEnough;
- (void)setLabelWordsInFrame:(CGRect)frame;
- (NSArray*)getWordStringsFromCDSet:(NSSet*)cdArray;

- (void)resetTimerAnimationFooterButtons;
- (void)animateFooterButtons;

- (void)appWillResignActive;

@end

@implementation GameViewController

- (id)initWithGame:(Game *)game parentViewController:(UIViewController *)viewController
{
    NSString *xib = @"GameViewController";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        xib = @"GameViewController_iPad";
    }
    self = [super initWithNibName:xib bundle:nil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        
        self.game = game;
        
        _wordStrings = [[NSArray alloc] initWithArray:[self getWordStringsFromCDSet:game.words]];
        _wordTable = [[WordTable alloc] initWithWords:_wordStrings
                                             delegate:self];
        _labelWords = [[NSMutableArray alloc] init];
        _gameSession = [[GameSession alloc] initWithGame:game
                                                delegate:self];
        _parentViewController = viewController;
        
        _hintWasPayed = NO;
    }
    return self;
}

- (void)dealloc
{
    [self.buttonHint release];
    [self.buttonPause release];
    [self.buttonRemoveChars release];
    [self.buttonResolveGame release];
    [self.buttonStore release];
    [self.labelStoreCoins release];
    [self.labelTime release];
    [self.labelTmpWord release];
    [self.labelBestTime release];
    [self.labelBestTimeText release];
    [self.viewWordTable release];
    [self.viewWords release];
    [self.viewFooter release];
    [_wordTable release];
    [_wordStrings release];
    [_labelWords release];
    [_gameSession release];
    [self.game release];
    [self.timerAnimations release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.labelStoreCoins.font = [UIFont fontWithName:@"Nexa Bold" size:15];
        self.labelTmpWord.font = [UIFont fontWithName:@"Nexa Bold" size:30];
        self.labelTime.font = [UIFont fontWithName:@"Nexa Bold" size:20];
        self.labelBestTime.font = [UIFont fontWithName:@"Nexa Bold" size:20];
        self.labelBestTimeText.font = [UIFont fontWithName:@"Nexa Bold" size:20];
    }
    else
    {
        self.labelStoreCoins.font = [UIFont fontWithName:@"Nexa Bold" size:12];
        self.labelTmpWord.font = [UIFont fontWithName:@"Nexa Bold" size:18];
        self.labelTime.font = [UIFont fontWithName:@"Nexa Bold" size:13];
        self.labelBestTime.font = [UIFont fontWithName:@"Nexa Bold" size:13];
        self.labelBestTimeText.font = [UIFont fontWithName:@"Nexa Bold" size:13];
        
        NSLog(@"height %f", (568 - self.viewFooter.frame.size.height - self.labelTmpWord.frame.size.height - self.viewWords.frame.size.height - 44) / 2 + 44 + self.labelTmpWord.frame.size.height);
        
        //  move down the footer
        CGSize viewSize = [[UIScreen mainScreen] bounds].size;
        self.viewFooter.frame = CGRectMake(self.viewFooter.frame.origin.x,
                                           viewSize.height - self.viewFooter.frame.size.height,
                                           self.viewFooter.frame.size.width,
                                           self.viewFooter.frame.size.height);
        
        //  move to the middle the wordtable
        self.viewWordTable.frame = CGRectMake(self.viewWordTable.frame.origin.x,
                                              (viewSize.height - self.viewFooter.frame.size.height - self.labelTmpWord.frame.size.height - self.viewWordTable.frame.size.height - 44) / 2 + 44 + self.labelTmpWord.frame.size.height,
                                              self.viewWordTable.frame.size.width,
                                              self.viewWordTable.frame.size.width);
    }
    
    [self resetTimerAnimationFooterButtons];
    
    [_wordTable viewDidLoadWithSize:self.viewWordTable.frame.size];
    [self setLabelWordsInFrame:self.viewWords.frame];
    
    self.labelTmpWord.textColor = THEME_COLOR_RED;
    self.labelBestTime.text = [_gameSession getTimeString:[_gameSession getHighscore]];
    
    self.labelBestTimeText.text = NSLocalizedString(@"bestTime", nil);
    
    [self.viewWordTable addSubview:_wordTable.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshView
{
    self.labelStoreCoins.text = [NSString stringWithFormat:@"%d", [[CoinsManager sharedInstance] getCoins]];
}

- (void)openStore:(BOOL)showNotEnough
{
    //  pause game & open store
    [_gameSession pause];
    [self.navigationController pushViewController:[StoreCoinsViewController sharedInstanceWithDelegate:self
                                                                                    showNotEnoughCoins:showNotEnough] animated:NO];
}

- (void)setLabelWordsInFrame:(CGRect)frame
{
    int offset = 4;
    float width = (frame.size.width - (2*offset)) / 3; // 3 columns
    float height = (frame.size.height - (2*offset)) / 3;
    
    for (int i = 0; i < _wordStrings.count; i++)
    {
        NSString *word = [_wordStrings objectAtIndex:i];
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + ((i % 3) * (width + offset)),
                                                                   frame.origin.y + (((int)i/3) * (height + offset)),
                                                                   width,
                                                                   height)] autorelease];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            label.font = [UIFont fontWithName:@"Nexa Bold" size:20];
        }
        else
        {
            label.font = [UIFont fontWithName:@"Nexa Bold" size:11];
        }
        
        label.text = word;
        label.backgroundColor = THEME_COLOR_GRAY_LIGHT;
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = height/2;
        label.textAlignment = NSTextAlignmentCenter;
        [self.viewWords addSubview:label];
        [_labelWords addObject:label];
    }
}

- (NSArray *)getWordStringsFromCDSet:(NSSet *)cdArray
{
    NSMutableArray *tmpWArray = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *tmpArray = [[[NSMutableArray alloc] init] autorelease];
    NSArray *inputArray = [cdArray allObjects];
    
    while (tmpWArray.count < WORDS_PER_GAME)
    {
        WordStr *wStr = [inputArray objectAtIndex:arc4random() % (inputArray.count)];
        if (![tmpWArray containsObject:wStr])
        {
            [tmpWArray addObject:wStr];
        }
    }
    
    for (WordStr *wordStr in tmpWArray)
    {
        [tmpArray addObject:wordStr.string];
    }
    return tmpArray;
}

- (void)resetTimerAnimationFooterButtons
{
    if (self.timerAnimations)
    {
        [self.timerAnimations invalidate];
        self.timerAnimations = nil;
    }
    self.timerAnimations = [NSTimer scheduledTimerWithTimeInterval:TIMER_ANIMATION_FOOTER_BUTTONS
                                                            target:self
                                                          selector:@selector(animateFooterButtons)
                                                          userInfo:nil
                                                           repeats:YES];
}

- (void)animateFooterButtons
{
    //  animate first char as for hint
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:-M_PI/8]];
    [anim setFromValue:[NSNumber numberWithDouble:M_PI/8]]; // rotation angle
    [anim setDuration:0.2];
    [anim setRepeatCount:3];
    [anim setAutoreverses:YES];
    
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[self.buttonHint layer] addAnimation:anim forKey:@"iconShake"];
    });
    
    delayInSeconds = 0.3;
    popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[self.buttonRemoveChars layer] addAnimation:anim forKey:@"iconShake"];
    });
    
    delayInSeconds = 0.6;
    popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[self.buttonResolveGame layer] addAnimation:anim forKey:@"iconShake"];
    });
}

- (void)appWillResignActive
{
    if ([_gameSession isPlaying])
    {
        [self doButtonPause:nil];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    CGPoint viewPoint = [_wordTable.view convertPoint:locationPoint fromView:self.view];
//    if ([_wordTable.view pointInside:viewPoint withEvent:event])
//    {
        [_wordTable touchesBegan:viewPoint];
//    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    CGPoint viewPoint = [_wordTable.view convertPoint:locationPoint fromView:self.view];
    //if ([_wordTable.view pointInside:viewPoint withEvent:event])
    //{
    [_wordTable touchesCancelled:viewPoint];
    //}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    CGPoint viewPoint = [_wordTable.view convertPoint:locationPoint fromView:self.view];
    //if ([_wordTable.view pointInside:viewPoint withEvent:event])
    //{
    [_wordTable touchesEnded:viewPoint];
    //}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    CGPoint viewPoint = [_wordTable.view convertPoint:locationPoint fromView:self.view];
    if ([_wordTable.view pointInside:viewPoint withEvent:event])
    {
        [_wordTable touchesMoved:viewPoint];
    }
}

- (void)doButtonStore:(id)sender
{
    
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    
    [self openStore:NO];
}

- (void)doButtonHint:(id)sender
{
    [self resetTimerAnimationFooterButtons];
    
    if (_hintWasPayed)  //  user payed for this hint, but didn't revealed this word
    {
        [_wordTable doWordStartCharHint];
        [[SoundUtils sharedInstance] playMusic:SoundTypeHint];
        return;
    }
    
    void (^buttonBlock)(BOOL execute, BOOL resumeSession) = ^void(BOOL execute, BOOL resumeSession){
        if (execute)
        {
            if ([[CoinsManager sharedInstance] getCoins] < COST_HINT)
            {
                [self openStore:YES];
                return;
            }
            
            
            [_wordTable doWordStartCharHint];
            [[CoinsManager sharedInstance] substractCoins:COST_HINT];
            [[SoundUtils sharedInstance] playMusic:SoundTypeHint];
            [self refreshView];
            _hintWasPayed = YES;
        }
        if (resumeSession)
        {
            [_gameSession resume];
        }
    };
    
    if ([[StorePayCoinsPopupManager sharedInstance] canShowPopup:PAY_COINS_POPUP_TYPE_HINT])
    {
        [_gameSession pause];
        [[StorePayCoinsPopupManager sharedInstance] showPopupType:PAY_COINS_POPUP_TYPE_HINT
                                                             name:NSLocalizedString(@"useHint", nil)
                                                      description:NSLocalizedString(@"useHintMsg", nil)
                                                             cost:COST_HINT
                                                            image:[UIImage imageNamed:@"hint.png"]
                                                           inView:self.view
                                                         onButton:buttonBlock];
    }
    else
    {
        buttonBlock(YES, NO);
    }
}

- (void)doButtonRemoveChars:(id)sender
{
       [self resetTimerAnimationFooterButtons];
    
    if (![_wordTable canRemoveUnnecessaryChars:WORD_TABLE_REMOVE_CHARS])
    {
        self.buttonRemoveChars.enabled = NO;
        return;
    }
    
    void (^buttonBlock)(BOOL execute, BOOL resumeSession) = ^void(BOOL execute, BOOL resumeSession){
        if (execute)
        {
            if ([[CoinsManager sharedInstance] getCoins] < COST_REMOVE_LETTERS)
            {
                [self openStore:YES];
                return;
            }
            [_wordTable doRemoveUnnecessaryChars:WORD_TABLE_REMOVE_CHARS];
            [[CoinsManager sharedInstance] substractCoins:COST_REMOVE_LETTERS];
            [[SoundUtils sharedInstance] playMusic:SoundTypeRemoveChars];
            
            
            
            if (![_wordTable canRemoveUnnecessaryChars:WORD_TABLE_REMOVE_CHARS])
            {
                self.buttonRemoveChars.enabled = NO;
            }
            
            [self refreshView];
        }
        if (resumeSession)
        {
            [_gameSession resume];
        }
    };
    
    if ([[StorePayCoinsPopupManager sharedInstance] canShowPopup:PAY_COINS_POPUP_TYPE_REMOVE_CHARS])
    {
        [_gameSession pause];
        [[StorePayCoinsPopupManager sharedInstance] showPopupType:PAY_COINS_POPUP_TYPE_REMOVE_CHARS
                                                             name:NSLocalizedString(@"removeChars", nil)
                                                      description:NSLocalizedString(@"removeCharsMsg", nil)
                                                             cost:COST_REMOVE_LETTERS
                                                            image:[UIImage imageNamed:@"half.png"]
                                                           inView:self.view
                                                         onButton:buttonBlock];
    }
    else
    {
        buttonBlock(YES, NO);
    }
}

- (void)doButtonResolveGame:(id)sender
{
    
    [self resetTimerAnimationFooterButtons];
    
    void (^buttonBlock)(BOOL execute, BOOL resumeSession) = ^void(BOOL execute, BOOL resumeSession){
        if (execute)
        {
            if ([[CoinsManager sharedInstance] getCoins] < COST_RESOLVE_GAME)
            {
                [self openStore:YES];
                return;
            }
            [_wordTable doResolveGame];
            [[CoinsManager sharedInstance] substractCoins:COST_RESOLVE_GAME];
            [[SoundUtils sharedInstance] removeAllPlayingSounds];
            [[SoundUtils sharedInstance] playMusic:SoundTypeGameFinished];
            [_gameSession gameCompleted];
            [self refreshView];
            
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                FinishViewController *finishViewController = [[[FinishViewController alloc] initWithDelegate:self
                                                                                                 gameSession:_gameSession
                                                                                                    isPaused:NO] autorelease];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                [self.navigationController pushViewController:finishViewController animated:YES];
            });
        }
        if (!execute && resumeSession)
        {
            [_gameSession resume];
        }
    };
    
    if ([[StorePayCoinsPopupManager sharedInstance] canShowPopup:PAY_COINS_POPUP_TYPE_RESOLVE_GAME])
    {
        [_gameSession pause];
        [[StorePayCoinsPopupManager sharedInstance] showPopupType:PAY_COINS_POPUP_TYPE_RESOLVE_GAME
                                                             name:NSLocalizedString(@"resolvePuzzle", nil)
                                                      description:NSLocalizedString(@"resolvePuzzleMsg", nil)
                                                             cost:COST_RESOLVE_GAME
                                                            image:[UIImage imageNamed:@"solve.png"]
                                                           inView:self.view
                                                         onButton:buttonBlock];
    }
    else
    {
        buttonBlock(YES, NO);
    }
}

- (void)doButtonPause:(id)sender
{    
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeBack];
    
    [_gameSession pause];
    
    FinishViewController *finishViewController = [[[FinishViewController alloc] initWithDelegate:self
                                                                                     gameSession:_gameSession
                                                                                        isPaused:YES] autorelease];
    [self.navigationController pushViewController:finishViewController animated:NO];
}

#pragma mark protocol GameViewControllerDelegate

- (void)onBack
{
    NSLog(@"%@", self.parentViewController.class);
    [self.navigationController popToViewController:_parentViewController animated:YES];
}

- (void)onRestart
{
    self.buttonRemoveChars.enabled = YES;
    
    [_wordStrings release];
    _wordStrings = [[NSArray alloc] initWithArray:[self getWordStringsFromCDSet:self.game.words]];
    
    [_wordTable.view removeFromSuperview];
    [_wordTable release];
    _wordTable = [[WordTable alloc] initWithWords:_wordStrings
                                         delegate:self];
    for (UILabel *label in _labelWords)
    {
        [label removeFromSuperview];
    }
    [_labelWords release];
    _labelWords = [[NSMutableArray alloc] init];
    
    [_wordTable viewDidLoadWithSize:self.viewWordTable.frame.size];
    [self setLabelWordsInFrame:self.viewWords.frame];
    
    [self.viewWordTable addSubview:_wordTable.view];
    
    [_gameSession release];
    _gameSession = [[GameSession alloc] initWithGame:self.game
                                            delegate:self];
    self.labelTime.text = @"00:00";
}

- (void)onResume
{
    [_gameSession resume];
}

- (void)onNext
{
    [_wordStrings release];
    
    Game *nextGame = nil;
    NSArray *allGames = [self.game.category.games allObjects];
    NSSortDescriptor *sortDescriptorID = [[[NSSortDescriptor alloc] initWithKey:@"identifier"
                                                                     ascending:YES] autorelease];
    allGames = [allGames sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptorID]];
    for (Game *game in allGames)
    {
        if (game.identifier.intValue > self.game.identifier.intValue)
        {
            nextGame = game;
            break;
        }
    }
    if (nextGame == nil)
    {
        self.game = [allGames objectAtIndex:0];
    }
    else
    {
        self.game = nextGame;
    }
        
    _wordStrings = [[NSArray alloc] initWithArray:[self getWordStringsFromCDSet:self.game.words]];
    
    [_wordTable.view removeFromSuperview];
    [_wordTable release];
    _wordTable = [[WordTable alloc] initWithWords:_wordStrings
                                         delegate:self];
    for (UILabel *label in _labelWords)
    {
        [label removeFromSuperview];
    }
    [_labelWords release];
    _labelWords = [[NSMutableArray alloc] init];
    
    [_wordTable viewDidLoadWithSize:self.viewWordTable.frame.size];
    [self setLabelWordsInFrame:self.viewWords.frame];
    
    [self.viewWordTable addSubview:_wordTable.view];
    
    [_gameSession release];
    _gameSession = [[GameSession alloc] initWithGame:self.game
                                            delegate:self];
    self.labelTime.text = @"00:00";
}

#pragma mark -

#pragma mark WordTableDelegate

- (void)wordTable:(WordTable *)wordTable changedTmpWord:(NSString *)word
{
    if (!self.labelTmpWord.text.length && word.length)
    {
        [[SoundUtils sharedInstance] removeAllPlayingSounds];
        [[SoundUtils sharedInstance] playMusic:SoundTypeStartTmpWord];
    }
    self.labelTmpWord.text = [word uppercaseString];
}

- (void)wordTable:(WordTable *)wordTable foundWord:(NSString *)word
{
    [self resetTimerAnimationFooterButtons];
    
    //  give coins
//    [[CoinsManager sharedInstance] addCoins:COINS_REWARD_FOUND_WORD];
    //  play sound, added coins
    [[SoundUtils sharedInstance] removeAllPlayingSounds];
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeFoundWord];
    
    for (UILabel *label in _labelWords)
    {
        if ([label.text caseInsensitiveCompare:word] == NSOrderedSame)
        {
            label.backgroundColor = THEME_COLOR_BLUE;
        }
    }
    
    if (![_wordTable canRemoveUnnecessaryChars:WORD_TABLE_REMOVE_CHARS])
    {
        self.buttonRemoveChars.enabled = NO;
    }
    
    _hintWasPayed = NO;
    
    [self refreshView];
}

- (void)wordTableCompletedGame:(WordTable *)wordTable
{
    [[CoinsManager sharedInstance] addCoins:[_gameSession getSessionPoints]];
    [_gameSession gameCompleted];
    
    [[SoundUtils sharedInstance] removeAllPlayingSounds];
    [[SoundUtils sharedInstance] playMusic:SoundTypeGameFinished];
    
    FinishViewController *finishViewController = [[[FinishViewController alloc] initWithDelegate:self
                                                                                     gameSession:_gameSession
                                                                                        isPaused:NO] autorelease];
    [self.navigationController pushViewController:finishViewController animated:YES];
}

#pragma mark -

#pragma mark GameSessionDelegate

- (void)onTimeChanged:(NSString *)timeString
{
    self.labelTime.text = timeString;
}

#pragma mark -

#pragma mark StoreCoinsViewControllerDelegate

- (void)storeCoinsViewControllerOnClose
{
    [_gameSession resume];
    [self refreshView];
}

#pragma mark -

-(void)offerwallPointsEarned:(NSNotification*)notifyObj
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self refreshView];
    });
}

@end
