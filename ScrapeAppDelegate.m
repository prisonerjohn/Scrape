//
//  ScrapeAppDelegate.m
//  Documents
//
//  Created by Elie Zananiri on 10-02-27.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import "ScrapeAppDelegate.h"
#import "ScrapePrefsController.h"


//--------------------------------------------------------------
//--------------------------------------------------------------
NSString *ScrapeEnableDockIconKey           = @"ScrapeEnableDockIcon";
NSString *ScrapeHasLaunchedBeforeKey        = @"ScrapeHasLaunchedBefore";
NSString *ScrapeLastLaunchVersionKey        = @"ScrapeLastLaunchVersion";
NSString *ScrapeAutomaticToggleKey          = @"DoAutomaticScrapes";
NSString *ScrapeAutomaticMinKey             = @"AutomaticScrapesMinInterval";
NSString *ScrapeAutomaticMaxKey             = @"AutomaticScrapesMaxInterval";
NSString *ScrapeAutomaticSettingsChangedKey = @"Automatic Settings Changed";

NSString *SiteRoot = @"http://www.silentlycrashing.net/scrape/";


//--------------------------------------------------------------
//--------------------------------------------------------------
@implementation ScrapeAppDelegate

//--------------------------------------------------------------
+ (void)initialize {
    // initialize random seed
    srand(time(NULL));
    
    // register preferences
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    [defaultValues setObject:[NSNumber numberWithBool:YES]
                      forKey:ScrapeEnableDockIconKey];
    [defaultValues setObject:[NSNumber numberWithBool:NO]
                      forKey:ScrapeHasLaunchedBeforeKey];
    [defaultValues setObject:[NSNumber numberWithInt:0]
                      forKey:ScrapeLastLaunchVersionKey];
    [defaultValues setObject:[NSNumber numberWithBool:YES]
                      forKey:ScrapeAutomaticToggleKey];
    [defaultValues setObject:[NSNumber numberWithInt:1]
                      forKey:ScrapeAutomaticMinKey];
    [defaultValues setObject:[NSNumber numberWithInt:120]
                      forKey:ScrapeAutomaticMaxKey];
    [defaultValues setObject:[NSNumber numberWithInt:120]
                      forKey:ScrapeAutomaticMaxKey];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:defaultValues];
}

//--------------------------------------------------------------
- (id)init {
    self = [super init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:ScrapeEnableDockIconKey] == YES) {
        [self showDockIcon];
    }
    
    return self;
}

//--------------------------------------------------------------
- (void)showDockIcon {
    // CocoaDev magic: http://www.cocoadev.com/index.pl?TransformProcessType
    ProcessSerialNumber psn = { 0, kCurrentProcess }; 
    OSStatus returnCode = TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    if( returnCode == 0) {
        // bring the app to the front (no idea what's going on here...)
        ProcessSerialNumber psnx = { 0, kNoProcess };
        GetNextProcess(&psnx);
        SetFrontProcess(&psnx);
        ProcessSerialNumber psn = { 0, kCurrentProcess };
        SetFrontProcess(&psn);	
    } else {
        NSLog(@"Could not bring the application to front. Error %d", returnCode);
    }
}

//--------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // init Growl
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *growlPath = [[bundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
    if (growlBundle && [growlBundle load]) {
        NSLog(@"Growl loaded");
        [GrowlApplicationBridge setGrowlDelegate:self];
    }
}

//--------------------------------------------------------------
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
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
                                                 name:ScrapeAutomaticSettingsChangedKey
                                               object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int currVersion = [[[bundle infoDictionary] objectForKey:@"CFBundleVersion"] intValue];
    
    if ([defaults integerForKey:ScrapeLastLaunchVersionKey] != currVersion) {
        // show the preferences window
        [self showPrefsWindow:nil];
        
        [defaults setInteger:currVersion
                      forKey:ScrapeLastLaunchVersionKey];
        [defaults synchronize];
    }
    
    if ([defaults boolForKey:ScrapeAutomaticToggleKey] == YES) {
        // schedule the first automatic scrape
        [self scheduleAutomaticScrape];
    }
    
    [defaults setBool:YES
               forKey:ScrapeHasLaunchedBeforeKey];
    [defaults synchronize];
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
- (IBAction)launchScrapeWebsite:(id)sender {
    if ([ScrapePrefsController isLoggedIn] == YES) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[SiteRoot stringByAppendingString:@"home.php"]]];
    } else {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[SiteRoot stringByAppendingString:@"index.php"]]];
    }
}

//--------------------------------------------------------------
- (void)growlNotificationWasClicked:(id)clickContext {
    if ([(NSString *)clickContext compare:@"FRONT"] == NSOrderedSame) {
        // bring Scrape to front
        [NSApp activateIgnoringOtherApps:YES];
    } else {
        NSRange textRange = [(NSString *)clickContext rangeOfString:@"http"];
        if (textRange.location == NSNotFound) {
            // assume we received a file path and reveal it in the Finder
            [[NSWorkspace sharedWorkspace] selectFile:(NSString *)clickContext 
                             inFileViewerRootedAtPath:@""];
        } else {
            // assume we received a URL and open it
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:clickContext]];
        }
    }
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
