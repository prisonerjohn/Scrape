//
//  ScrapeAppDelegate.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-27.
//  Copyright 2010-2014 silentlyCrashing::net. All rights reserved.
//

//--------------------------------------------------------------
extern NSString *ScrapeHasLaunchedBeforeKey;
extern NSString *ScrapeLastLaunchVersionKey;

extern NSString *ScrapeEnableDockIconKey;
extern NSString *ScrapeEnableMenuBarIconKey;
extern NSString *ScrapeShowUserNotificationsKey;

extern NSString *ScrapeDestroyDataOnReleaseKey;
extern NSString *ScrapeAutomaticSettingsChangedKey;
extern NSString *ScrapeAutomaticToggleKey;
extern NSString *ScrapeAutomaticMinKey;
extern NSString *ScrapeAutomaticMaxKey;

extern NSString *SiteRoot;

//--------------------------------------------------------------
@class ScrapePrefsController;

//--------------------------------------------------------------
@interface ScrapeAppDelegate : NSObject <NSApplicationDelegate>
{
    NSStatusItem    *statusItem;
    NSImage         *idleImage;
    NSImage         *selectImage;
    
    ScrapePrefsController *prefsController;
}

@property (weak) IBOutlet NSMenu *statusMenu;
    
- (void)showDockIcon;
    
- (void)scheduleAutomaticScrape;
- (void)updateTimer:(NSNotification *)notification;
- (void)newAutoScrape;

- (IBAction)newManualScrape:(id)sender;
- (IBAction)showAboutWindow:(id)sender;
- (IBAction)showPrefsWindow:(id)sender;
- (IBAction)launchScrapeWebsite:(id)sender;

@end
