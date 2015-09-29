//
//  QuestPopupView.h
//  words
//
//  Created by Marius Rott on 9/13/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestPopupView : UIView

@property (nonatomic, retain) IBOutlet UIView *viewPopup;
@property (nonatomic, retain) IBOutlet UILabel *labelTitle;
@property (nonatomic, retain) IBOutlet UILabel *labelQuest;
@property (nonatomic, retain) IBOutlet UILabel *labelButtonOK;
@property (nonatomic, retain) IBOutlet UIButton *buttonOK;

@end
