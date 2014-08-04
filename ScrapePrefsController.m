//
//  ScrapePrefsController.m
//  Scrape
//
//  Created by Elie Zananiri on 10-03-12.
//  Copyright 2010-2014 silentlyCrashing::net. All rights reserved.
//

#import "ScrapePrefsController.h"

#import "AFNetworking.h"
#import "ScrapeAppDelegate.h"
#import "sCLoginItemsManager.h"
#import "SSKeychain.h"

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
    NSLog(@"Loading preferences.");
    
    // hide status labels
    [_successLabel setHidden:YES];
    [_errorLabel   setHidden:YES];
    
    // set login item preference
    //if ([sCLoginItemsManager loginItemExistsForAppPath:[[NSBundle mainBundle] bundlePath]]) {
    if ([sCLoginItemsManager willStartAtLogin:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]] == YES) {
        [_startAtLoginToggle setState:NSOnState];
    } else {
        [_startAtLoginToggle setState:NSOffState];
    }
    
    // set other saved preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [_showInDockToggle setState:[defaults boolForKey:ScrapeEnableDockIconKey]];
    if ([_showInDockToggle state] == NSOffState) {
        // if the dock icon is hidden, force the menu bar icon
        [_showInMenuBarToggle setState:NSOnState];
        [_showInMenuBarToggle setEnabled:NO];
    } else {
        [_showInMenuBarToggle setState:[defaults boolForKey:ScrapeEnableMenuBarIconKey]];
    }
    [_showUserNotificationsToggle setState:[defaults boolForKey:ScrapeShowUserNotificationsKey]];
    
    [_autoScrapeToggle setState:[defaults boolForKey:ScrapeAutomaticToggleKey]];
    [_autoScrapeMinStepper setIntegerValue:[defaults integerForKey:ScrapeAutomaticMinKey]];
    [_autoScrapeMinStepper setEnabled:[_autoScrapeToggle state]];
    [_autoScrapeMaxStepper setIntegerValue:[defaults integerForKey:ScrapeAutomaticMaxKey]];
    [_autoScrapeMaxStepper setEnabled:[_autoScrapeToggle state]];
    [_autoScrapeMinTextField setIntegerValue:[defaults integerForKey:ScrapeAutomaticMinKey]];
    [_autoScrapeMinTextField setEnabled:[_autoScrapeToggle state]];
    [_autoScrapeMaxTextField setIntegerValue:[defaults integerForKey:ScrapeAutomaticMaxKey]];
    [_autoScrapeMaxTextField setEnabled:[_autoScrapeToggle state]];
    [_destroyDataToggle setState:[defaults boolForKey:ScrapeDestroyDataOnReleaseKey]];
    
    // try to load the credentials from the keychain
    NSArray *credentials = [SSKeychain accountsForService:kScrapeKeychainService];
    if (credentials && credentials.count) {
        NSString *username = [[credentials objectAtIndex:0] objectForKey:@"acct"];
        NSString *password = [SSKeychain passwordForService:kScrapeKeychainService
                                                    account:username];
        if (username && password) {
            NSLog(@"Successfully retrieved credentials from keychain!");
            
            ScrapeKeychainUsername = username;
            ScrapeKeychainPassword = password;
            
            // update input fields
            [_usernameTextField setStringValue:ScrapeKeychainUsername];
            [_passwordTextField setStringValue:ScrapeKeychainPassword];
            
            // try logging in
            [self loginToScrape:nil];
        }
    }
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
        [_showInMenuBarToggle setState:NSOnState];
        [_showInMenuBarToggle setEnabled:NO];
    } else {
        [_showInMenuBarToggle setEnabled:YES];
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
    
    [_autoScrapeMinTextField setEnabled:[sender state]];
    [_autoScrapeMaxTextField setEnabled:[sender state]];
    [_autoScrapeMinStepper setEnabled:[sender state]];
    [_autoScrapeMaxStepper setEnabled:[sender state]];
    
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
    
    [_autoScrapeMinTextField setIntValue:[sender intValue]];
    
    [_autoScrapeMaxStepper setMinValue:([sender intValue] + 1)];
    [[_autoScrapeMaxTextField formatter] setMinimum:[NSNumber numberWithInt:([sender intValue] + 1)]];
    
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
    
    [_autoScrapeMinStepper setIntValue:[sender intValue]];
    
    [_autoScrapeMaxStepper setMinValue:([sender intValue] + 1)];
    [[_autoScrapeMaxTextField formatter] setMinimum:[NSNumber numberWithInt:([sender intValue] + 1)]];
    
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
    
    [_autoScrapeMaxTextField setIntValue:[sender intValue]];
    
    [_autoScrapeMinStepper setMaxValue:([sender intValue] - 1)];
    [[_autoScrapeMinTextField formatter] setMaximum:[NSNumber numberWithInt:([sender intValue] - 1)]];
    
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
    
    [_autoScrapeMaxStepper setIntValue:[sender intValue]];
    
    [_autoScrapeMinStepper setMaxValue:([sender intValue] - 1)];
    [[_autoScrapeMinTextField formatter] setMaximum:[NSNumber numberWithInt:([sender intValue] - 1)]];
    
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username": [_usernameTextField stringValue],
                                 @"password": [_passwordTextField stringValue]};
    [manager POST:[SiteRoot stringByAppendingString:@"verify.php"]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSString *resultString = [responseObject objectForKey:@"res"];
              if ([resultString compare:@"OK"] == NSOrderedSame) {
                  NSLog(@"Successfully logged in!");
                  [_successLabel setHidden:NO];
                  [_errorLabel   setHidden:YES];
                  
                  // add the saved username and password to the keychain
                  NSError *error = nil;
                 [SSKeychain setPassword:[_passwordTextField stringValue]
                              forService:@"Scrape"
                                 account:[_usernameTextField stringValue]
                                   error:&error];
                  if (error) {
                      NSLog(@"Error saving credentials to keychain: %@", [error localizedDescription]);
                  }
                  
                  // save the keychain values in static variables for easy access
                  ScrapeKeychainUsername = [_usernameTextField stringValue];
                  ScrapeKeychainPassword = [_passwordTextField stringValue];
                  
                  [ScrapePrefsController setLoggedIn:YES];
                  
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  if ([defaults boolForKey:ScrapeShowUserNotificationsKey] == YES) {
                      NSUserNotification *notification = [[NSUserNotification alloc] init];
                      notification.title = @"Logged in to Scrape";
                      [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                  }
                  
              }
              else {
                  NSLog(@"Error logging in: %@", resultString);
                  [_successLabel setHidden:YES];
                  [_errorLabel   setHidden:NO];
                  
                  [ScrapePrefsController setLoggedIn:NO];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error logging in: %@", [error localizedDescription]);
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
