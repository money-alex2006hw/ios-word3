//
//  StorePayCoinsManager.h
//  words
//
//  Created by Marius Rott on 9/25/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^StorePayOnOK)(void);
typedef void(^StorePayOnCancel)(void);

@class StorePayCoinsPopupView;

@interface StorePayCoinsPopupManager : NSObject

@property (nonatomic, retain) IBOutlet StorePayCoinsPopupView *viewPopupPayCoins;
@property (nonatomic, retain) UINib *viewLoaderPayCoins;

+ (StorePayCoinsPopupManager*)sharedInstance;

- (BOOL)canShowPopup:(int)popupType;

- (void)showPopupType:(int)popupType
                 name:(NSString*)name
          description:(NSString*)description
                 cost:(int)cost
                image:(UIImage*)image
               inView:(UIView*)parentView
             onButton:(void (^)(BOOL, BOOL))onButton;

- (IBAction)doButtonPopupOK:(id)sender;
- (IBAction)doButtonPopupCancel:(id)sender;

@end
