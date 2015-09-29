//
//  PackageViewController.m
//  words
//
//  Created by Marius Rott on 9/5/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "PackageViewController.h"
#import "GameViewController.h"
#import "CoreDataUtils.h"
#import "Category.h"
#import "Game.h"
#import "PackageGameCell.h"
#import "StoreCoinsViewController.h"
#import "ImageUtils.h"
#import "configuration.h"
#import "SoundUtils.h"
#import "MGAdsManager.h"

@interface PackageViewController ()

@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSArray *games;

- (void)configureGameCell:(PackageGameCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PackageViewController

- (id)initWithCategory:(Category *)category
{
    NSString *xib = @"PackageViewController";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        xib = @"PackageViewController_iPad";
    }
    self = [super initWithNibName:xib bundle:nil];
    if (self)
    {
        self.category = category;
        
        NSSortDescriptor *sortDescriptorID = [[[NSSortDescriptor alloc] initWithKey:@"identifier"
                                                                         ascending:YES] autorelease];
        self.games = [[self.category.games allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptorID]];
        
        //  load cell
        NSString *xib = @"PackageGameCell";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            xib = @"PackageGameCell_iPad";
        }
        self.cellLoaderGame = [UINib nibWithNibName:xib bundle:nil];
    }
    return self;
}

- (void)dealloc
{
    [self.category release];
    [self.games release];
    [self.tableView release];
    [self.cellGame release];
    [self.cellLoaderGame release];
    [self.labelTitle release];
    [self.bannerView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.labelTitle.font = [UIFont fontWithName:@"Lucida Calligraphy" size:30];
    }
    else
    {
        self.labelTitle.font = [UIFont fontWithName:@"Lucida Calligraphy" size:20];
    }
    
    self.labelTitle.text = NSLocalizedString(self.category.name, nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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

- (void)doButtonBack:(id)sender
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeBack];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doButtonStore:(id)sender
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    [self.navigationController pushViewController:[StoreCoinsViewController sharedInstanceWithDelegate:nil
                                                                                    showNotEnoughCoins:NO] animated:NO];
}

#pragma mark tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.games.count;
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
    PackageGameCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PackageGameCell"];
    if (cell == nil) {
        [self.cellLoaderGame instantiateWithOwner:self options:nil];
        cell = self.cellGame;
        self.cellGame = nil;
    }
    
    [self.cellLoaderGame instantiateWithOwner:self options:nil];
    
    [self configureGameCell:cell
                atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    Game *game = [[self.games allObjects] objectAtIndex:indexPath.row];
    GameViewController *gameViewCont = [[GameViewController alloc] initWithGame:game parentViewController:self];
    [self.navigationController pushViewController:gameViewCont animated:YES];
}

- (void)configureGameCell:(PackageGameCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Game *game = [self.games objectAtIndex:indexPath.row];
    cell.labelName.text = NSLocalizedString(game.name, nil);
    
    NSNumber *sum = [game.sessions valueForKeyPath:@"@sum.points"];
//    NSString *points = [NSString stringWithFormat:@"%d", sum.intValue];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        cell.labelName.font = [UIFont fontWithName:@"Lucida Calligraphy" size:26];
    }
    else
    {
        cell.labelName.font = [UIFont fontWithName:@"Lucida Calligraphy" size:13];
    }
    
    cell.labelName.text = cell.labelName.text;// [NSString stringWithFormat:@"%@ --- %@", points, cell.labelName.text];
    cell.imageViewIcon.image = [UIImage imageNamed:@"puzzle.png"];
    
    [cell.viewStars addSubview:[ImageUtils getStarImageViewForPercentage:sum.floatValue / (float)GAME_TOTAL_POINTS]];
}

#pragma mark -


@end
