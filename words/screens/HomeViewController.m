//
//  HomeViewController.m
//  words
//
//  Created by Marius Rott on 9/4/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "HomeViewController.h"
#import "GameViewController.h"
#import "StoreCoinsViewController.h"
#import "StorePackagesViewController.h"
#import "PackageViewController.h"
#import "SettingsViewController.h"
#import "CoreDataUtils.h"
#import "CoinsManager.h"
#import "QuestManager.h"
#import "ImageUtils.h"
#import "QuestPopupManager.h"
#import "Category.h"
#import "Game.h"
#import "Quest.h"
#import "Level.h"
#import "configuration.h"
#import "SoundUtils.h"
#import "MGIAPHelper.h"
#import "MGAdsManager.h"

#define TABLE_VIEW_TYPE_CATEGORY     1
#define TABLE_VIEW_TYPE_QUEST        2

@interface HomeViewController ()
{
    int _tableViewType;
    QuestPopupManager *_questPopupManager;
}

@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSArray *quests;

- (void)refreshView;
- (void)loadQuests;

- (void)configurePackageCell:(HomePackageCell*)cell atIndexPath:(NSIndexPath*)indexPath;
- (void)configureQuestCell:(HomeQuestCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@end

@implementation HomeViewController

- (id)init
{
    NSString *xib = @"HomeViewController";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        xib = @"HomeViewController_iPad";
    }
    self = [super initWithNibName:xib bundle:nil];
    if (self) {
        _tableViewType = TABLE_VIEW_TYPE_CATEGORY;
        
        //  load data
        self.categories = [[CoreDataUtils sharedInstance] getAllCategories];
        [self loadQuests];
        
        //  load cell
        NSString *xib = @"HomePackageCell";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            xib = @"HomePackageCell_iPad";
        }
        self.cellLoaderPackage = [UINib nibWithNibName:xib bundle:nil];
        xib = @"HomeQuestCell";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            xib = @"HomeQuestCell_iPad";
        }
        self.cellLoaderQuest = [UINib nibWithNibName:xib bundle:nil];
    }
    return self;
}

- (void)dealloc
{
    [self.labelTitle release];
    [self.buttonCategories release];
    [self.buttonQuests release];
    [self.imageViewTabCategories release];
    [self.imageViewTabQuests release];
    [self.labelTabCategories release];
    [self.labelTabQuests release];
    [self.tableView release];
    [self.categories release];
    [self.quests release];
    [self.cellLoaderPackage release];
    [self.cellLoaderQuest release];
    [self.cellPackage release];
    [self.cellQuest release];
    if (_questPopupManager)
        [_questPopupManager release];
    [self.bannerView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.labelTitle.font = [UIFont fontWithName:@"Lucida Calligraphy" size:30];
        self.labelTabCategories.font = [UIFont fontWithName:@"Nexa Bold" size:24];
        self.labelTabQuests.font = [UIFont fontWithName:@"Nexa Bold" size:24];
        self.labelQuestLevelName.font = [UIFont fontWithName:@"Nexa Bold" size:24];
        self.buttonStorePackages.titleLabel.font = [UIFont fontWithName:@"Nexa Bold" size:24];
    }
    else
    {
        self.labelTitle.font = [UIFont fontWithName:@"Lucida Calligraphy" size:20];
        self.labelTabCategories.font = [UIFont fontWithName:@"Nexa Bold" size:16];
        self.labelTabQuests.font = [UIFont fontWithName:@"Nexa Bold" size:16];
        self.labelQuestLevelName.font = [UIFont fontWithName:@"Nexa Bold" size:16];
        self.buttonStorePackages.titleLabel.font = [UIFont fontWithName:@"Nexa Bold" size:16];
    }
    
    self.labelTitle.text = NSLocalizedString(@"wordSearch", nil);
    self.labelTabCategories.text = NSLocalizedString(@"packages", nil);
    self.labelTabQuests.text = NSLocalizedString(@"quests", nil);
    [self.buttonStorePackages setTitle:NSLocalizedString(@"unlockPackages", nil) forState:UIControlStateNormal];
    
    [self refreshView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
    [self configureBannerView];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshView
{
    UIColor *colorSelected = THEME_COLOR_RED;
    UIColor *colorHidden = THEME_COLOR_GRAY;
    UIImage *imageTabSelected = [ImageUtils imageWithColor:colorSelected
                                                  rectSize:self.buttonCategories.frame.size];
    UIImage *imageTabHidden = [ImageUtils imageWithColor:colorHidden
                                                rectSize:self.buttonCategories.frame.size];
    
    int bannerHeight;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        bannerHeight = 90;
    }
    else
    {
        bannerHeight = 50;
    }
    if (![[MGAdsManager sharedInstance] isAdsEnabled])
    {
        bannerHeight = 0;
        if (self.bannerView && self.bannerView.superview == self.view)
        {
            [self.bannerView removeFromSuperview];
        }
    }
    
    if (_tableViewType == TABLE_VIEW_TYPE_CATEGORY)
    {
        self.labelQuestLevelName.hidden = YES;
        self.buttonStorePackages.hidden = NO;
        
        self.buttonCategories.enabled = NO;
        self.buttonQuests.enabled = YES;
        self.imageViewTabCategories.image = [UIImage imageNamed:@"packages_tab_inactive.png"];
        self.imageViewTabQuests.image = [UIImage imageNamed:@"quest_tab_active.png"];
        self.labelTabCategories.textColor = colorSelected;
        self.labelTabQuests.textColor = colorHidden;
        [self.buttonCategories setImage:imageTabHidden
                               forState:UIControlStateNormal];
        [self.buttonQuests setImage:imageTabSelected
                           forState:UIControlStateNormal];
        
        if ([self areAllPacksPurchased])
        {
            self.buttonStorePackages.hidden = YES;
            CGRect rectTableView = CGRectMake(0,
                                              self.buttonStorePackages.frame.origin.y,
                                              self.view.frame.size.width,
                                              self.view.frame.size.height - self.buttonStorePackages.frame.origin.y - bannerHeight);
            self.tableView.frame = rectTableView;
        }
    }
    else
    {
        CGRect rectTableView = CGRectMake(0,
                                          self.labelQuestLevelName.frame.origin.y + self.labelQuestLevelName.frame.size.height,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height - self.labelQuestLevelName.frame.origin.y - self.labelQuestLevelName.frame.size.height - bannerHeight);
        self.tableView.frame = rectTableView;
        
        self.labelQuestLevelName.hidden = NO;
        self.buttonStorePackages.hidden = YES;
        
        self.buttonCategories.enabled = YES;
        self.buttonQuests.enabled = NO;
        self.imageViewTabCategories.image = [UIImage imageNamed:@"packages_tab_active.png"];
        self.imageViewTabQuests.image = [UIImage imageNamed:@"quest_tab_inactive.png"];
        self.labelTabCategories.textColor = colorHidden;
        self.labelTabQuests.textColor = colorSelected;
        [self.buttonCategories setImage:imageTabSelected
                               forState:UIControlStateNormal];
        [self.buttonQuests setImage:imageTabHidden
                           forState:UIControlStateNormal];
    }
    
    [self.tableView reloadData];
}

- (BOOL)areAllPacksPurchased
{
    for (Category *categ in self.categories)
    {
        if (categ.bundleID.length && ![[MGIAPHelper sharedInstance] productPurchased:categ.bundleID])
        {
            return false;
        }
    }
    return true;
}

- (void)loadQuests
{
    NSSortDescriptor *sortDescriptorID = [[[NSSortDescriptor alloc] initWithKey:@"identifier"
                                                                      ascending:YES] autorelease];
    NSFetchRequest *requestQuests = [[[NSFetchRequest alloc] initWithEntityName:@"Quest"] autorelease];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == NO"];
    [requestQuests setPredicate:predicate];
    requestQuests.sortDescriptors = [NSArray arrayWithObjects:sortDescriptorID, nil];
    NSError *error2 = nil;
    NSArray *quests = [[CoreDataUtils sharedInstance].managedObjectContext executeFetchRequest:requestQuests error:&error2];
    if (!error2)
    {
        if (quests.count)
        {
            self.quests = [((Quest*)[quests objectAtIndex:0]).level.quests allObjects];
            self.quests = [self.quests sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptorID]];
        }
    }
}

- (void)doButtonSettings:(id)sender
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    SettingsViewController *settingsViewCont = [[[SettingsViewController alloc] init] autorelease];
    [self.navigationController pushViewController:settingsViewCont animated:NO];
}

- (IBAction)doButtonCategory:(id)sender
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    _tableViewType = TABLE_VIEW_TYPE_CATEGORY;
    [self refreshView];
    [self.tableView reloadData];
}

- (IBAction)doButtonQuest:(id)sender
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    _tableViewType = TABLE_VIEW_TYPE_QUEST;
    [self refreshView];
    [self loadQuests];
    self.labelQuestLevelName.text = NSLocalizedString(((Quest*)[_quests objectAtIndex:0]).level.name, nil);
    [self.tableView reloadData];
}

- (void)doButtonStore:(id)sender
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    [self.navigationController pushViewController:[StoreCoinsViewController sharedInstanceWithDelegate:nil
                                                                                    showNotEnoughCoins:NO] animated:NO];
}

- (void)doButtonQuickPlay:(id)sender
{
    
}

- (void)doButtonStorePackages:(id)sender
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    
    StorePackagesViewController *storePackages = [[[StorePackagesViewController alloc] init] autorelease];
    [self.navigationController pushViewController:storePackages animated:YES];
}

#pragma mark tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    for (Category *category in self.categories)
    {
        NSLog(@"num categ out %@", category.name);
        if (!category.bundleID.length || [[MGIAPHelper sharedInstance] productPurchased:category.bundleID])
        {
            NSLog(@"num categ in %@", category.name);
            count++;
        }
    }
    
    if (_tableViewType == TABLE_VIEW_TYPE_CATEGORY)
        return count;
    else
        return self.quests.count;
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
    if (_tableViewType == TABLE_VIEW_TYPE_CATEGORY)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TABLE_VIEW_TYPE_CATEGORY"];
        if (cell == nil) {
            [self.cellLoaderPackage instantiateWithOwner:self options:nil];
            cell = self.cellPackage;
            self.cellPackage = nil;
        }
        
        [self.cellLoaderPackage instantiateWithOwner:self options:nil];
        
        [self configurePackageCell:(HomePackageCell*)cell
                       atIndexPath:indexPath];
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TABLE_VIEW_TYPE_QUESTS"];
        if (cell == nil) {
            [self.cellLoaderQuest instantiateWithOwner:self options:nil];
            cell = self.cellQuest;
            self.cellQuest = nil;
        }
        
        [self.cellLoaderQuest instantiateWithOwner:self options:nil];
        
        [self configureQuestCell:(HomeQuestCell*)cell
                     atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableViewType != TABLE_VIEW_TYPE_CATEGORY)
    {
        return;
    }
    
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    
    int count = 0, index = 0;
    for (Category *category in self.categories)
    {
        count++;
        if (!category.bundleID.length || [[MGIAPHelper sharedInstance] productPurchased:category.bundleID])
        {
            if (index == indexPath.row)
            {
                break;
            }
            index++;
        }
    }
    Category *category = [self.categories objectAtIndex:count - 1];
    
    PackageViewController *packageViewCont = [[PackageViewController alloc] initWithCategory:category];
    [self.navigationController pushViewController:packageViewCont animated:YES];
}

- (void)configurePackageCell:(HomePackageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    int count = 0, index = 0;
    for (Category *category in self.categories)
    {
        count++;
        if (!category.bundleID.length || [[MGIAPHelper sharedInstance] productPurchased:category.bundleID])
        {
            if (index == indexPath.row)
            {
                break;
            }
            index++;
        }
    }
    Category *category = [self.categories objectAtIndex:count - 1];
    
    cell.labelName.text = NSLocalizedString(category.name, nil);
    
    int completed = 0;
    for (Game *game in category.games)
    {
        NSNumber *sum = [game.sessions valueForKeyPath:@"@sum.points"];
        
        if (sum.intValue >= GAME_TOTAL_POINTS)
        {
            completed++;
        }
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        cell.labelName.font = [UIFont fontWithName:@"Lucida Calligraphy" size:26];
        cell.labelDescription.font = [UIFont fontWithName:@"Segoe UI" size:20];
    }
    else
    {
        cell.labelName.font = [UIFont fontWithName:@"Lucida Calligraphy" size:18];
        cell.labelDescription.font = [UIFont fontWithName:@"Segoe UI" size:14];
    }
    
    cell.labelDescription.text = [NSString stringWithFormat:NSLocalizedString(@"Completed %d/%d puzzles", nil), completed, category.games.count];
    cell.labelDescription.textColor = THEME_COLOR_GRAY_TEXT;
    NSString *name = [NSString stringWithFormat:@"packages%d.png", category.identifier.intValue];
    cell.imageViewIcon.image = [UIImage imageNamed:name];
}

- (void)configureQuestCell:(HomeQuestCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Quest *quest = [self.quests objectAtIndex:indexPath.row];
    
    QuestManager *questManager = [[[QuestManager alloc] init] autorelease];
    
    float completionPercentage = [questManager getQuestCompletionPercentage:quest];
    
    cell.labelName.text = NSLocalizedString(quest.desc, nil); //[NSString stringWithFormat:@"%f - %@", completionPercentage, quest.desc];
    if (quest.completed.boolValue == YES)
    {
        cell.buttonSkip.hidden = YES;
        cell.labelCompleted.text = NSLocalizedString(@"Completed", nil);
        cell.labelCompleted.textColor = THEME_COLOR_BLUE;
    }
    else
    {
        [cell.buttonSkip setTitle:[NSString stringWithFormat:@"Skip: %d coins", quest.cost.intValue]
                         forState:UIControlStateNormal];
        cell.buttonSkip.tag = indexPath.row;
        cell.labelCompleted.text = [NSString stringWithFormat:@"%.02f%%", completionPercentage];
        cell.labelCompleted.textColor = THEME_COLOR_RED;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        cell.labelName.font = [UIFont fontWithName:@"Segoe UI" size:20];
        cell.labelCompleted.font = [UIFont fontWithName:@"Lucida Calligraphy" size:24];
    }
    else
    {
        cell.labelName.font = [UIFont fontWithName:@"Segoe UI" size:13];
        cell.labelCompleted.font = [UIFont fontWithName:@"Lucida Calligraphy" size:13];
    }
    
    cell.labelName.textColor = THEME_COLOR_GRAY_TEXT;
}

- (void)doButtonSkipQuest:(id)sender
{
    Quest *quest = [self.quests objectAtIndex:((UIButton*)sender).tag];
    
    if ([[CoinsManager sharedInstance] getCoins] < quest.cost.intValue)
    {
        [self presentViewController:[StoreCoinsViewController sharedInstanceWithDelegate:self
                                                                      showNotEnoughCoins:NO]
                           animated:YES
                         completion:^{
                             
                         }];
        return;
    }    
    [[CoinsManager sharedInstance] substractCoins:quest.cost.intValue];

    quest.completed = [NSNumber numberWithBool:YES];
    NSError *error = nil;
    [[CoreDataUtils sharedInstance].managedObjectContext save:&error];
    if (error)
    {
        NSLog(error.debugDescription);
    }
    
    //  show popups
    _questPopupManager = [[QuestPopupManager alloc] initWithFinishedQuests:[NSArray arrayWithObject:quest]
                                                                    inView:self.view];
    [_questPopupManager showPopups];
    
    [self loadQuests];
    [self.tableView reloadData];
}

#pragma mark -

#pragma mark StoreCoinsViewControllerDelegate

- (void)storeCoinsViewControllerOnClose
{
    
}

#pragma mark -

@end
