//
//  ScrapeAppDelegate.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-27.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>


extern NSString *ScrapeEnableDockIconKey;
extern NSString *ScrapeHasLaunchedBeforeKey;
extern NSString *ScrapeLastLaunchVersionKey;
extern NSString *ScrapeAutomaticSettingsChangedKey;
extern NSString *ScrapeAutomaticToggleKey;
extern NSString *ScrapeAutomaticMinKey;
extern NSString *ScrapeAutomaticMaxKey;

extern NSString *SiteRoot;

@class ScrapePrefsController;


#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface ScrapeAppDelegate : NSObject <GrowlApplicationBridgeDelegate> {
#else
@interface ScrapeAppDelegate : NSObject <GrowlApplicationBridgeDelegate, NSApplicationDelegate> {
#endif
    IBOutlet NSMenu *statusMenu;
    
    NSStatusItem    *statusItem;
    NSImage         *idleImage;
    NSImage         *selectImage;
    
    ScrapePrefsController   *prefsController;
}
    
- (void)showDockIcon;
    
- (void)scheduleAutomaticScrape;
- (void)updateTimer:(NSNotification *)notification;
- (void)newAutoScrape;

- (IBAction)newManualScrape:(id)sender;
- (IBAction)showAboutWindow:(id)sender;
- (IBAction)showPrefsWindow:(id)sender;
- (IBAction)launchScrapeWebsite:(id)sender;

@end
