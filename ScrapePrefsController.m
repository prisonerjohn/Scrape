//
//  ScrapePrefsController.m
//  Scrape
//
//  Created by Elie Zananiri on 10-03-12.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import "ScrapePrefsController.h"
#import "ScrapeAppController.h"
#import <Growl/Growl.h>


//--------------------------------------------------------------
//--------------------------------------------------------------
static BOOL loggedIn = NO;

NSString *KeychainUsername = nil;
NSString *KeychainPassword = nil;


//--------------------------------------------------------------
//--------------------------------------------------------------
@implementation ScrapePrefsController

//--------------------------------------------------------------
- (id)init {
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        [self loadWindow];
        
        // hide status labels
        [successLabel setHidden:YES];
        [errorLabel   setHidden:YES];
        
        // set saved preferences
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [automaticSwitch     setState:[defaults boolForKey:ScrapeAutomaticToggleKey]];
        [automaticMinStepper setIntegerValue:[defaults integerForKey:ScrapeAutomaticMinKey]];
        [automaticMinStepper setEnabled:[automaticSwitch state]];
        [automaticMaxStepper setIntegerValue:[defaults integerForKey:ScrapeAutomaticMaxKey]];
        [automaticMaxStepper setEnabled:[automaticSwitch state]];
        [automaticMinLabel   setIntegerValue:[defaults integerForKey:ScrapeAutomaticMinKey]];
        [automaticMinLabel   setEnabled:[automaticSwitch state]];
        [automaticMaxLabel   setIntegerValue:[defaults integerForKey:ScrapeAutomaticMaxKey]];
        [automaticMaxLabel   setEnabled:[automaticSwitch state]];
        
        // try to load the credentials from the keychain
        NSURL *url = [NSURL URLWithString:[SiteRoot stringByAppendingString:@"verify.php"]];
        NSURLCredential *authenticationCredentials = [ASIHTTPRequest savedCredentialsForHost:[url host] port:[[url port] intValue] protocol:[url scheme] realm:nil];
        if (authenticationCredentials) {
            KeychainUsername = [authenticationCredentials user];
            KeychainPassword = [authenticationCredentials password];
            
            if (KeychainUsername && KeychainPassword) {
                NSLog(@"Successfully retrieved credentials from keychain");
                // update input fields
                [usernameInput setStringValue:KeychainUsername];
                [passwordInput setStringValue:KeychainPassword];
                // try logging in
                [self loginToScrape:nil];
            }
        }
        
        return self;
    }
    return nil;
}

//--------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticToggle:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender state]
               forKey:ScrapeAutomaticToggleKey];
    [defaults synchronize];
    
    [automaticMinLabel   setEnabled:[sender state]];
    [automaticMaxLabel   setEnabled:[sender state]];
    [automaticMinStepper setEnabled:[sender state]];
    [automaticMaxStepper setEnabled:[sender state]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChanged 
                                                        object:self];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticMinFromStepper:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMinKey];
    [defaults synchronize];
    
    [automaticMinLabel setIntValue:[sender intValue]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChanged 
                                                        object:self];
}
         
//--------------------------------------------------------------
- (IBAction)setAutomaticMinFromTextField:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMinKey];
    [defaults synchronize];
    
    [automaticMinStepper setIntValue:[sender intValue]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChanged 
                                                        object:self];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticMaxFromStepper:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMaxKey];
    [defaults synchronize];
    
    [automaticMaxLabel setIntValue:[sender intValue]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChanged 
                                                        object:self];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticMaxFromTextField:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMaxKey];
    [defaults synchronize];
    
    [automaticMaxStepper setIntValue:[sender intValue]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChanged 
                                                        object:self];
}

//--------------------------------------------------------------
- (IBAction)loginToScrape:(id)sender {
    NSURL *url = [NSURL URLWithString:[SiteRoot stringByAppendingString:@"verify.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"User-Agent" value:@"Scrape-User-Agent-1.0"];
    [request setPostValue:[usernameInput stringValue] 
                   forKey:@"username"];
    [request setPostValue:[passwordInput stringValue] 
                   forKey:@"password"];
    [request setDelegate:self];
    [request startAsynchronous];
}

//--------------------------------------------------------------
- (IBAction)signupForScrape:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[SiteRoot stringByAppendingString:@"register.php"]]];
}

//--------------------------------------------------------------
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    if ([responseString compare:@"OK"] == NSOrderedSame) {
        NSLog(@"Successfully logged in");
        [successLabel setHidden:NO];
        [errorLabel   setHidden:YES];
        
        // add the saved username and password to the keychain
        NSMutableDictionary *credentials = [[[NSMutableDictionary alloc] init] autorelease];
        [credentials setObject:[usernameInput stringValue] 
                        forKey:(NSString *)kCFHTTPAuthenticationUsername];
		[credentials setObject:[passwordInput stringValue] 
                        forKey:(NSString *)kCFHTTPAuthenticationPassword];
        [request saveCredentialsToKeychain:credentials];
        
        // save the keychain values in static variables for easy access
        KeychainUsername = [usernameInput stringValue];
        KeychainPassword = [passwordInput stringValue];
        
        [ScrapePrefsController setLoggedIn:YES];
        
        [GrowlApplicationBridge notifyWithTitle:@"Logged in to Scrape"
                                    description:nil
                               notificationName:@"Login"
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:nil];
        
    } else {
        NSLog(@"Error logging in");
        [successLabel setHidden:YES];
        [errorLabel   setHidden:NO];
        
        [ScrapePrefsController setLoggedIn:NO];
    }
}

//--------------------------------------------------------------
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"%@", [error localizedDescription]);
}

//--------------------------------------------------------------
+ (void)setLoggedIn:(BOOL)val {
    loggedIn = val;
}

//--------------------------------------------------------------
+ (BOOL)isLoggedIn {
    return loggedIn;
}

@end
