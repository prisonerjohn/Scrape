//
//  ScrapeAppController.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-25.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ScrapeAppController : NSObject {
    IBOutlet NSMenu*    statusMenu;
    
    NSStatusItem*       statusItem;
    NSImage*            idleImage;
    NSImage*            selectImage;
}

@end
