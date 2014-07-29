//
//  ScrapePrefsController.h
//  Scrape
//
//  Created by Elie Zananiri on 10-03-12.
//  Copyright 2010-2014 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *KeychainUsername;
extern NSString *KeychainPassword;

//--------------------------------------------------------------
@interface ScrapePrefsController : NSWindowController
{
    IBOutlet NSButton           *automaticSwitch;
    IBOutlet NSStepper          *automaticMinStepper;
    IBOutlet NSStepper          *automaticMaxStepper;
    IBOutlet NSTextField        *automaticMinLabel;
    IBOutlet NSTextField        *automaticMaxLabel;
    IBOutlet NSButton           *destroyDataSwitch;
    
    IBOutlet NSButton           *startAtLoginSwitch;
    IBOutlet NSButton           *showInDockSwitch;
    IBOutlet NSButton           *showInMenuBarSwitch;
    IBOutlet NSButton           *showUserNotificationsSwitch;
    
    IBOutlet NSTextField        *usernameInput;
    IBOutlet NSSecureTextField  *passwordInput;
    IBOutlet NSButton           *loginButton;
    IBOutlet NSButton           *signupButton;
    IBOutlet NSTextField        *successLabel;
    IBOutlet NSTextField        *errorLabel;
}

- (IBAction)setStartAtLogin:(id)sender;
- (IBAction)setShowInDock:(id)sender;
- (IBAction)setShowInMenuBar:(id)sender;
- (IBAction)setShowUserNotifications:(id)sender;

- (IBAction)setAutomaticToggle:(id)sender;
- (IBAction)setAutomaticMinFromStepper:(id)sender;
- (IBAction)setAutomaticMaxFromStepper:(id)sender;
- (IBAction)setAutomaticMinFromTextField:(id)sender;
- (IBAction)setAutomaticMaxFromTextField:(id)sender;

- (IBAction)setDestroyData:(id)sender;

- (IBAction)loginToScrape:(id)sender;
- (IBAction)signupForScrape:(id)sender;

+ (void)setLoggedIn:(BOOL)val;
+ (BOOL)isLoggedIn;

@end
