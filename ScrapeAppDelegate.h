//
//  ScrapeAppDelegate.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-27.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>


#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface ScrapeAppDelegate : NSObject <GrowlApplicationBridgeDelegate> {
#else
@interface ScrapeAppDelegate : NSObject <GrowlApplicationBridgeDelegate, NSApplicationDelegate> {
#endif

}

@end
