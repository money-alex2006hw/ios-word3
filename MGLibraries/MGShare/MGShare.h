//
//  MGShare.h
//  TabBarTutorial
//
//  Created by marius on 2/17/13.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

typedef void (^ShareCompletionBlock)();

@interface MGShare : NSObject <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) NSString *stringTitle;
@property (nonatomic, retain) NSString *stringMessage;
@property (nonatomic, retain) NSString *stringURL;
@property (nonatomic, retain) NSString *stringPathToLocalImage;

@property (nonatomic, retain) UIViewController *parentViewController;

+ (MGShare*)sharedInstance;

- (void)shareString:(NSString*)message fromTabBarInViewController:(UIViewController*)viewController;
- (void)shareString:(NSString*)message fromViewController:(UIViewController*)viewController;
- (void)shareString:(NSString*)message fromView:(UIView*)view inViewController:(UIViewController*)viewController;

- (void)facebookShareString:(NSString*)message fromViewController:(UIViewController*)viewController completion:(void (^)(bool completed))completion;
- (void)twitterShareString:(NSString*)message fromViewController:(UIViewController*)viewController completion:(void (^)(bool completed))completion;

@end
