//
//  ScrapeAppController.m
//  Scrape
//
//  Created by Elie Zananiri on 10-02-25.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import "ScrapeAppController.h"
#import "ScrapePrefsController.h"
#import <Growl/Growl.h>


//--------------------------------------------------------------
//--------------------------------------------------------------
NSString *ScrapeAutomaticSettingsChanged = @"Automatic Settings Changed";
NSString *ScrapeAutomaticToggleKey       = @"Automatic Toggle";
NSString *ScrapeAutomaticMinKey          = @"Automatic Min";
NSString *ScrapeAutomaticMaxKey          = @"Automatic Max";

NSString *SiteRoot = @"http://labs.silentlycrashing.net/scrape/";


//--------------------------------------------------------------
//--------------------------------------------------------------
@implementation ScrapeAppController

//--------------------------------------------------------------
+ (void)initialize {
    // initialize random seed
    srand(time(NULL));
    
    // register preferences
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    [defaultValues setObject:[NSNumber numberWithBool:YES]
                      forKey:ScrapeAutomaticToggleKey];
    [defaultValues setObject:[NSNumber numberWithInt:1]
                      forKey:ScrapeAutomaticMinKey];
    [defaultValues setObject:[NSNumber numberWithInt:120]
                      forKey:ScrapeAutomaticMaxKey];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:defaultValues];
}

//--------------------------------------------------------------
- (void)awakeFromNib {
    // create the status bar item
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    NSBundle *bundle = [NSBundle mainBundle];
    idleImage   = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"idle" 
                                                                           ofType:@"png"]];
    selectImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"select" 
                                                                           ofType:@"png"]];
    [statusItem setImage:idleImage];
    [statusItem setAlternateImage:selectImage];
    
    [statusItem setHighlightMode:YES];
    [statusItem setToolTip:@"Scrape"];
    
    [statusItem setMenu:statusMenu];
    
    // create the preferences window
    prefsController = [[ScrapePrefsController alloc] init];
    
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateTimer:) 
                                                 name:ScrapeAutomaticSettingsChanged
                                               object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:ScrapeAutomaticToggleKey] == YES) {
        // schedule the first automatic scrape
        [self scheduleAutomaticScrape];
    }
}

//--------------------------------------------------------------
- (void)scheduleAutomaticScrape {
    // make a random time interval based on user preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int min = [defaults integerForKey:ScrapeAutomaticMinKey];
    int max = [defaults integerForKey:ScrapeAutomaticMaxKey];
    int delay = rand()%(max - min) + min;
    NSLog(@"Next automatic scrape scheduled in %d minutes", delay);
    
    [self performSelector:@selector(newAutoScrape)
               withObject:nil
               afterDelay:(delay * 60)];
}

//--------------------------------------------------------------
- (void)updateTimer:(NSNotification *)notification {
    // cancel the last scheduled automatic scrape
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(newAutoScrape)
                                               object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:ScrapeAutomaticToggleKey] == YES) {
        // schedule a new automatic scrape
        [self scheduleAutomaticScrape];
    }
}

//--------------------------------------------------------------
- (void)newAutoScrape {
    NSLog(@"Automatic scrape");
    
    [[NSDocumentController sharedDocumentController] newDocument:self];
    
    [GrowlApplicationBridge notifyWithTitle:@"New Scrape"
                                description:@"A new data Scrape has been generated"
                           notificationName:@"New Auto"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@"FRONT"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:ScrapeAutomaticToggleKey] == YES) {
        // schedule a new automatic scrape
        [self scheduleAutomaticScrape];
    }
}

//--------------------------------------------------------------
- (IBAction)newManualScrape:(id)sender {
    NSLog(@"Scrape");
    
    // bring app to front
    [NSApp activateIgnoringOtherApps:YES];
    
    [[NSDocumentController sharedDocumentController] newDocument:self];
    
    [GrowlApplicationBridge notifyWithTitle:@"New Scrape"
                                description:@"A new data Scrape has been generated"
                           notificationName:@"New Manual"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
}

//--------------------------------------------------------------
- (IBAction)showAboutWindow:(id)sender {
    // bring application to front
    [NSApp activateIgnoringOtherApps:YES];
    
    [NSApp orderFrontStandardAboutPanel:sender];
}

//--------------------------------------------------------------
- (IBAction)showPrefsWindow:(id)sender {
    // bring application to front
    [NSApp activateIgnoringOtherApps:YES];
    
    [prefsController showWindow:self];
}

//--------------------------------------------------------------
- (void)dealloc {
    // release the 2 images we loaded into memory
    [idleImage release];
    [selectImage release];
    
    // release the prefs window
    [prefsController release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end
