//
//  StorePayCoinsManager.m
//  words
//
//  Created by Marius Rott on 9/25/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "StorePayCoinsPopupManager.h"
#import "StorePayCoinsPopupView.h"
#import "ImageUtils.h"
#import "configuration.h"

@interface StorePayCoinsPopupManager ()
{
    int _popupType;
    UIView *_parentView;
    NSMutableArray *_contextsPopup;
}

@property (nonatomic, copy) void(^onButton)(BOOL execute, BOOL resumeSession);

@end

static StorePayCoinsPopupManager *_instance;

@implementation StorePayCoinsPopupManager

+ (StorePayCoinsPopupManager *)sharedInstance
{
    @synchronized(self)
    {
        if (_instance == nil)
        {
            _instance = [[StorePayCoinsPopupManager alloc] init];
            
            //  load cell
            NSString *xib = @"StorePayCoinsPopupView";
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                xib = @"StorePayCoinsPopupView_iPad";
            }
            _instance.viewLoaderPayCoins = [UINib nibWithNibName:xib bundle:nil];
        }
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _contextsPopup = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_contextsPopup release];
    [self.viewLoaderPayCoins release];
    [self.viewPopupPayCoins release];
    [super dealloc];
}

- (BOOL)canShowPopup:(int)popupType
{
    for (NSNumber *num in _contextsPopup)
    {
        if (num.intValue == popupType)
        {
            return NO;
        }
    }
    return YES;
}

- (void)showPopupType:(int)popupType name:(NSString *)name description:(NSString *)description cost:(int)cost image:(UIImage *)image inView:(UIView *)parentView onButton:(void (^)(BOOL, BOOL))onButton
{
    if ([self canShowPopup:popupType])
    {
        _popupType = popupType;
        if (!self.viewPopupPayCoins)
        {
            [self.viewLoaderPayCoins instantiateWithOwner:self options:nil];
        }
        
        _parentView = parentView;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.viewPopupPayCoins.labelButtonOK.font = [UIFont fontWithName:@"Lucida Calligraphy" size:24];
            self.viewPopupPayCoins.labelButtonCancel.font = [UIFont fontWithName:@"Lucida Calligraphy" size:24];
            self.viewPopupPayCoins.labelTitle.font = [UIFont fontWithName:@"Lucida Calligraphy" size:30];
            self.viewPopupPayCoins.labelDescription.font = [UIFont fontWithName:@"Segoe UI" size:24];
            self.viewPopupPayCoins.labelCost.font = [UIFont fontWithName:@"Segoe UI" size:30];
        }
        else
        {
            CGSize viewSize = [[UIScreen mainScreen] bounds].size;
            
            UIImage *background = [UIImage imageNamed:@"popup_background.png"];
            
            self.viewPopupPayCoins.viewPopup.backgroundColor = [UIColor colorWithPatternImage:background];
            self.viewPopupPayCoins.viewPopup.center = CGPointMake(viewSize.width/2, viewSize.height/2);
            
            self.viewPopupPayCoins.labelButtonOK.font = [UIFont fontWithName:@"Lucida Calligraphy" size:16];
            self.viewPopupPayCoins.labelButtonCancel.font = [UIFont fontWithName:@"Lucida Calligraphy" size:16];
            self.viewPopupPayCoins.labelTitle.font = [UIFont fontWithName:@"Lucida Calligraphy" size:20];
            self.viewPopupPayCoins.labelDescription.font = [UIFont fontWithName:@"Segoe UI" size:16];
            self.viewPopupPayCoins.labelCost.font = [UIFont fontWithName:@"Segoe UI" size:20];
        }
        

        self.viewPopupPayCoins.labelTitle.textColor = THEME_COLOR_BLUE;
        self.viewPopupPayCoins.labelDescription.textColor = THEME_COLOR_GRAY_TEXT;
        self.viewPopupPayCoins.labelCost.textColor = THEME_COLOR_BLUE;
        
        UIImage *imageButton = [ImageUtils imageWithColor:THEME_COLOR_BLUE
                                                 rectSize:self.viewPopupPayCoins.buttonOK.frame.size];
        [self.viewPopupPayCoins.buttonOK setImage:imageButton forState:UIControlStateNormal];
        [self.viewPopupPayCoins.buttonCancel setImage:imageButton forState:UIControlStateNormal];
        
        self.viewPopupPayCoins.labelButtonOK.text = NSLocalizedString(@"OK", nil);
        self.viewPopupPayCoins.labelButtonCancel.text = NSLocalizedString(@"cancel", nil);
        
        self.viewPopupPayCoins.labelTitle.text = name;
        self.viewPopupPayCoins.labelDescription.text = description;
        self.viewPopupPayCoins.labelCost.text = [NSString stringWithFormat:NSLocalizedString(@"costCoins", nil), cost];
        self.viewPopupPayCoins.imageView.image = image;
        self.onButton = onButton;
        
        [parentView addSubview:self.viewPopupPayCoins];
    }
}

- (void)doButtonPopupOK:(id)sender
{
    [_contextsPopup addObject:[NSNumber numberWithInt:_popupType]]; //don't show this popup next time
    
    [self.viewPopupPayCoins removeFromSuperview];
    
    if (self.onButton)
    {
        self.onButton(YES, YES);
    }
}

- (void)doButtonPopupCancel:(id)sender
{
    [self.viewPopupPayCoins removeFromSuperview];
    
    if (self.onButton)
    {
        self.onButton(NO, YES);
    }
}

@end
