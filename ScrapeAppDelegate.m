//
//  ScrapeAppDelegate.m
//  Documents
//
//  Created by Elie Zananiri on 10-02-27.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import "ScrapeAppDelegate.h"


//--------------------------------------------------------------
//--------------------------------------------------------------
@implementation ScrapeAppDelegate

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
- (void)growlNotificationWasClicked:(id)clickContext {
    if ([(NSString *)clickContext compare:@"FRONT"] == NSOrderedSame) {
        // bring Scrape to front
        [NSApp activateIgnoringOtherApps:YES];
    } else {
        NSLog(@"%@", clickContext);
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

@end
