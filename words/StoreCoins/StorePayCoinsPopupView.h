//
//  StorePayCoinsPopupView.h
//  words
//
//  Created by Marius Rott on 9/25/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StorePayCoinsPopupView : UIView

@property (nonatomic, retain) IBOutlet UIView *viewPopup;
@property (nonatomic, retain) IBOutlet UIButton *buttonOK;
@property (nonatomic, retain) IBOutlet UIButton *buttonCancel;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonOK;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonCancel;
@property (nonatomic, retain) IBOutlet UILabel *labelTitle;
@property (nonatomic, retain) IBOutlet UILabel *labelDescription;
@property (nonatomic, retain) IBOutlet UILabel *labelCost;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end
