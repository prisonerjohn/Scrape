//
//  ScrapeAppController.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-25.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


extern NSString *ScrapeAutomaticSettingsChanged;
extern NSString *ScrapeAutomaticToggleKey;
extern NSString *ScrapeAutomaticMinKey;
extern NSString *ScrapeAutomaticMaxKey;

extern NSString *SiteRoot;

@class ScrapePrefsController;

@interface ScrapeAppController : NSObject {
    IBOutlet NSMenu *statusMenu;
    
    NSStatusItem    *statusItem;
    NSImage         *idleImage;
    NSImage         *selectImage;
    
    ScrapePrefsController   *prefsController;
}

- (void)scheduleAutomaticScrape;
- (void)doScrape;
- (void)updateTimer:(NSNotification *)notification;

- (IBAction)showPrefsWindow:(id)sender;

@end
