//
//  MGShare.m
//  TabBarTutorial
//
//  Created by marius on 2/17/13.
//
//

#import "MGShare.h"
#import <Social/Social.h>

@interface MGShare ()

@property (nonatomic, copy) void(^completionShare)(bool completed);

- (void)shareTwitter;
- (void)shareFacebook;
- (void)shareEmail;

@end

@implementation MGShare

+ (MGShare *)sharedInstance
{
    static MGShare *instance;
    if (instance == nil)
    {
        instance = [[MGShare alloc] init];
        
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    [self.stringTitle release];
    [self.stringMessage release];
    [self.stringURL release];
    [self.stringPathToLocalImage release];
    [super dealloc];
}

- (void)shareString:(NSString *)message fromTabBarInViewController:(UIViewController *)viewController
{
    if (message)
    {
        self.stringMessage = message;
    }
    self.parentViewController = viewController;
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Share with:"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:  @"Facebook",
                                                                        @"Twitter",
                                                                        @"Email",
                                                                        nil] autorelease];
    [actionSheet showFromTabBar:viewController.tabBarController.tabBar];
}

- (void)shareString:(NSString *)message fromViewController:(UIViewController *)viewController
{
    if (message)
    {
        self.stringMessage = message;
    }
    self.parentViewController = viewController;
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Share with:"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:  @"Facebook",
                                   @"Twitter",
                                   @"Email",
                                   nil] autorelease];
    [actionSheet showInView:self.parentViewController.view];
}

- (void)shareString:(NSString *)message fromView:(UIView *)view inViewController:(UIViewController *)viewController
{
    if (message)
    {
        self.stringMessage = message;
    }
    self.parentViewController = viewController;
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Share with:"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:  @"Facebook",
                                   @"Twitter",
                                   @"Email",
                                   nil] autorelease];
    [actionSheet showInView:view];
}

- (void)facebookShareString:(NSString*)message fromViewController:(UIViewController*)viewController completion:(void (^)(bool))completion
{
    self.stringMessage = message;
    self.parentViewController = viewController;
    self.completionShare = completion;
    [self shareFacebook];
}

- (void)twitterShareString:(NSString*)message fromViewController:(UIViewController*)viewController completion:(void (^)(bool))completion
{
    self.stringMessage = message;
    self.parentViewController = viewController;
    self.completionShare = completion;
    [self shareTwitter];
}

- (void)shareTwitter
{
    NSLog(@"twitter");
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:self.stringMessage];
        [tweetSheet addURL:[NSURL URLWithString:self.stringURL]];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    if (self.completionShare)
                    {
                        self.completionShare(NO);
                    }
                    break;
                case SLComposeViewControllerResultDone:
                    if (self.completionShare)
                    {
                        self.completionShare(YES);
                    }
                    break;
                default:
                    break;
            }
        };
        
        tweetSheet.completionHandler = myBlock;
        [self.parentViewController presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)shareFacebook
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeFacebook];
        [tweetSheet setInitialText:self.stringMessage];
        [tweetSheet addURL:[NSURL URLWithString:self.stringURL]];
        [tweetSheet addImage:[UIImage imageNamed:self.stringPathToLocalImage]];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            NSString *output= nil;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    if (self.completionShare)
                    {
                        self.completionShare(NO);
                    }
                    break;
                case SLComposeViewControllerResultDone:
                    if (self.completionShare)
                    {
                        self.completionShare(YES);
                    }
                    break;
                default:
                    break;
            }
        };
        
        tweetSheet.completionHandler = myBlock;
        [self.parentViewController presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"You can't send share on Facebook right now, make sure your device has an internet connection and you have at least one Facebook account setup"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)shareEmail
{
    NSLog(@"email");
    
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        if(mailController!=nil) {
            mailController.mailComposeDelegate = self;
            NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:self.stringPathToLocalImage]);
            [mailController addAttachmentData:imageData mimeType:@"image/png" fileName:@"MyImageName"];
            [mailController setSubject:self.stringTitle];
            [mailController setMessageBody:[NSString stringWithFormat:@"%@ <br/><br/> %@", self.stringMessage, self.stringURL] isHTML:YES];
            [self.parentViewController presentViewController:mailController
                                                    animated:YES
                                                  completion:^{
                                                      
                                                  }];
            [mailController release];
        }
        else
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Device error"
                                                             message:@"This device is not configured to send email!"
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"OK", nil] autorelease];
            [alert show];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self shareFacebook];
            break;
        case 1:
            [self shareTwitter];
            break;
        case 2:
            [self shareEmail];
            break;
    }
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the
// message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	
    if (result == MFMailComposeResultSent)
    {
    }
    
	[self.parentViewController dismissViewControllerAnimated:YES
                                                  completion:^{}];
}

@end
