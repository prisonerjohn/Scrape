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
	// Insert code here to initialize your application
//    [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask 
//                                           handler:^(NSEvent *event) {
//        if ([event modifierFlags] & NSControlKeyMask) {
//            NSLog(@"SSSSS!");
//        }
//    }];
}

//--------------------------------------------------------------
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

@end
