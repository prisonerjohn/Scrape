//
//  ScrapePrefsController.h
//  Scrape
//
//  Created by Elie Zananiri on 10-03-12.
//  Copyright 2010-2014 silentlyCrashing::net. All rights reserved.
//

extern NSString *const kScrapeKeychainService;

extern NSString *ScrapeKeychainUsername;
extern NSString *ScrapeKeychainPassword;

//--------------------------------------------------------------
@interface ScrapePrefsController : NSWindowController

@property (weak) IBOutlet NSButton *autoScrapeToggle;
@property (weak) IBOutlet NSTextField *autoScrapeMinTextField;
@property (weak) IBOutlet NSStepper *autoScrapeMinStepper;
@property (weak) IBOutlet NSTextField *autoScrapeMaxTextField;
@property (weak) IBOutlet NSStepper *autoScrapeMaxStepper;
@property (weak) IBOutlet NSButton *destroyDataToggle;

@property (weak) IBOutlet NSButton *startAtLoginToggle;
@property (weak) IBOutlet NSButton *showInDockToggle;
@property (weak) IBOutlet NSButton *showInMenuBarToggle;
@property (weak) IBOutlet NSButton *showUserNotificationsToggle;

@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSButton *signUpButton;
@property (weak) IBOutlet NSTextField *successLabel;
@property (weak) IBOutlet NSTextField *errorLabel;

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
