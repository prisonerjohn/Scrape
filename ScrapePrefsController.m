//
//  ScrapePrefsController.m
//  Scrape
//
//  Created by Elie Zananiri on 10-03-12.
//  Copyright 2010-2014 silentlyCrashing::net. All rights reserved.
//

#import "ScrapePrefsController.h"

#import "AFNetworking.h"
#import "SSKeychain.h"

#import "ScrapeAppDelegate.h"
#import "sCLoginItemsManager.h"

//--------------------------------------------------------------
static BOOL loggedIn = NO;

NSString *const kScrapeKeychainService = @"Scrape";

NSString *ScrapeKeychainUsername = nil;
NSString *ScrapeKeychainPassword = nil;

//--------------------------------------------------------------
@implementation ScrapePrefsController

//--------------------------------------------------------------
- (id)init
{
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        [self loadWindow];
        return self;
    }
    return nil;
}

//--------------------------------------------------------------
- (void)awakeFromNib
{
    NSLog(@"Loading Preferences");
    
    // hide status labels
    [successLabel setHidden:YES];
    [errorLabel   setHidden:YES];
    
    // set login item preference
    //if ([sCLoginItemsManager loginItemExistsForAppPath:[[NSBundle mainBundle] bundlePath]]) {
    if ([sCLoginItemsManager willStartAtLogin:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]] == YES) {
        [startAtLoginSwitch setState:NSOnState];
    } else {
        [startAtLoginSwitch setState:NSOffState];
    }
    
    // set other saved preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [showInDockSwitch setState:[defaults boolForKey:ScrapeEnableDockIconKey]];
    if ([showInDockSwitch state] == NSOffState) {
        // if the dock icon is hidden, force the menu bar icon
        [showInMenuBarSwitch setState:NSOnState];
        [showInMenuBarSwitch setEnabled:NO];
    } else {
        [showInMenuBarSwitch setState:[defaults boolForKey:ScrapeEnableMenuBarIconKey]];
    }
    [showUserNotificationsSwitch setState:[defaults boolForKey:ScrapeShowUserNotificationsKey]];
    
    [automaticSwitch     setState:[defaults boolForKey:ScrapeAutomaticToggleKey]];
    [automaticMinStepper setIntegerValue:[defaults integerForKey:ScrapeAutomaticMinKey]];
    [automaticMinStepper setEnabled:[automaticSwitch state]];
    [automaticMaxStepper setIntegerValue:[defaults integerForKey:ScrapeAutomaticMaxKey]];
    [automaticMaxStepper setEnabled:[automaticSwitch state]];
    [automaticMinLabel   setIntegerValue:[defaults integerForKey:ScrapeAutomaticMinKey]];
    [automaticMinLabel   setEnabled:[automaticSwitch state]];
    [automaticMaxLabel   setIntegerValue:[defaults integerForKey:ScrapeAutomaticMaxKey]];
    [automaticMaxLabel   setEnabled:[automaticSwitch state]];
    [destroyDataSwitch   setState:[defaults boolForKey:ScrapeDestroyDataOnReleaseKey]];
    
    // try to load the credentials from the keychain
    NSArray *credentials = [SSKeychain accountsForService:kScrapeKeychainService];
    if (credentials && credentials.count) {
        NSString *username = [[credentials objectAtIndex:0] objectForKey:@"acct"];
        NSString *password = [SSKeychain passwordForService:kScrapeKeychainService
                                                    account:username];
        if (username && password) {
            NSLog(@"Successfully retrieved credentials from keychain");
            
            ScrapeKeychainUsername = username;
            ScrapeKeychainPassword = password;
            
            // update input fields
            [usernameInput setStringValue:ScrapeKeychainUsername];
            [passwordInput setStringValue:ScrapeKeychainPassword];
            
            // try logging in
            [self loginToScrape:nil];
        }
    }
}

//--------------------------------------------------------------
- (void)dealloc
{
    [super dealloc];
}

//--------------------------------------------------------------
- (IBAction)setStartAtLogin:(id)sender
{
    [sCLoginItemsManager setStartAtLogin:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]] 
                                 enabled:[sender state]];
}

//--------------------------------------------------------------
- (IBAction)setShowInDock:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender state]
               forKey:ScrapeEnableDockIconKey];
    [defaults synchronize];
    
    if ([sender state] == NSOffState) {
        // if the dock icon is hidden, force the menu bar icon
        [showInMenuBarSwitch setState:NSOnState];
        [showInMenuBarSwitch setEnabled:NO];
    } else {
        [showInMenuBarSwitch setEnabled:YES];
    }
}

//--------------------------------------------------------------
- (IBAction)setShowInMenuBar:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender state]
               forKey:ScrapeEnableMenuBarIconKey];
    [defaults synchronize];
}

//--------------------------------------------------------------
- (IBAction)setShowUserNotifications:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender state]
               forKey:ScrapeShowUserNotificationsKey];
    [defaults synchronize];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticToggle:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender state]
               forKey:ScrapeAutomaticToggleKey];
    [defaults synchronize];
    
    [automaticMinLabel   setEnabled:[sender state]];
    [automaticMaxLabel   setEnabled:[sender state]];
    [automaticMinStepper setEnabled:[sender state]];
    [automaticMaxStepper setEnabled:[sender state]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChangedKey 
                                                        object:self];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticMinFromStepper:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMinKey];
    [defaults synchronize];
    
    [automaticMinLabel setIntValue:[sender intValue]];
    
    [automaticMaxStepper setMinValue:([sender intValue] + 1)];
    [[automaticMaxLabel formatter] setMinimum:[NSNumber numberWithInt:([sender intValue] + 1)]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChangedKey 
                                                        object:self];
}
         
//--------------------------------------------------------------
- (IBAction)setAutomaticMinFromTextField:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMinKey];
    [defaults synchronize];
    
    [automaticMinStepper setIntValue:[sender intValue]];
    
    [automaticMaxStepper setMinValue:([sender intValue] + 1)];
    [[automaticMaxLabel formatter] setMinimum:[NSNumber numberWithInt:([sender intValue] + 1)]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChangedKey 
                                                        object:self];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticMaxFromStepper:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMaxKey];
    [defaults synchronize];
    
    [automaticMaxLabel setIntValue:[sender intValue]];
    
    [automaticMinStepper setMaxValue:([sender intValue] - 1)];
    [[automaticMinLabel formatter] setMaximum:[NSNumber numberWithInt:([sender intValue] - 1)]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChangedKey 
                                                        object:self];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticMaxFromTextField:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMaxKey];
    [defaults synchronize];
    
    [automaticMaxStepper setIntValue:[sender intValue]];
    
    [automaticMinStepper setMaxValue:([sender intValue] - 1)];
    [[automaticMinLabel formatter] setMaximum:[NSNumber numberWithInt:([sender intValue] - 1)]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChangedKey 
                                                        object:self];
}

//--------------------------------------------------------------
- (IBAction)setDestroyData:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender state]
               forKey:ScrapeDestroyDataOnReleaseKey];
    [defaults synchronize];
}

//--------------------------------------------------------------
- (IBAction)loginToScrape:(id)sender
{
    // @TODO: Set request header @"User-Agent" to @"Scrape-User-Agent-1.0"
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username": [usernameInput stringValue],
                                 @"password": [passwordInput stringValue]};
    [manager POST:[SiteRoot stringByAppendingString:@"verify.php"]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSString *responseString = [operation responseString];
              if ([responseString compare:@"OK"] == NSOrderedSame) {
                  NSLog(@"Successfully logged in");
                  [successLabel setHidden:NO];
                  [errorLabel   setHidden:YES];
                  
                  // add the saved username and password to the keychain
                  NSError *error = nil;
                 [SSKeychain setPassword:[passwordInput stringValue]
                              forService:@"Scrape"
                                 account:[usernameInput stringValue]
                                   error:&error];
                  if (error) {
                      NSLog(@"Error saving credentials to keychain: %@", [error localizedDescription]);
                  }
                  
                  // save the keychain values in static variables for easy access
                  ScrapeKeychainUsername = [usernameInput stringValue];
                  ScrapeKeychainPassword = [passwordInput stringValue];
                  
                  [ScrapePrefsController setLoggedIn:YES];
                  
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  if ([defaults boolForKey:ScrapeShowUserNotificationsKey] == YES) {
                      NSUserNotification *notification = [[NSUserNotification alloc] init];
                      notification.title = @"Logged in to Scrape";
                      [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                  }
                  
              }
              else {
                  NSLog(@"Error logging in");
                  [successLabel setHidden:YES];
                  [errorLabel   setHidden:NO];
                  
                  [ScrapePrefsController setLoggedIn:NO];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@", [error localizedDescription]);
          }];
}

//--------------------------------------------------------------
- (IBAction)signupForScrape:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[SiteRoot stringByAppendingString:@"register.php"]]];
}

//--------------------------------------------------------------
+ (void)setLoggedIn:(BOOL)val
{
    loggedIn = val;
}

//--------------------------------------------------------------
+ (BOOL)isLoggedIn
{
    return loggedIn;
}

@end
