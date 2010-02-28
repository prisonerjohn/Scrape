//
//  ScrapeAppController.m
//  Scrape
//
//  Created by Elie Zananiri on 10-02-25.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import "ScrapeAppController.h"


@implementation ScrapeAppController

- (void)awakeFromNib {
    // Create the NSStatusBar and set its length
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength: NSSquareStatusItemLength] retain];
    
    // Allocates and loads the images into the application which will be used for our NSStatusItem
    NSBundle *bundle = [NSBundle mainBundle];
    idleImage   = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"idle" 
                                                                            ofType: @"png"]];
    selectImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"select" 
                                                                            ofType: @"png"]];
    
    // Sets the images in our NSStatusItem
    [statusItem setImage: idleImage];
    [statusItem setAlternateImage: selectImage];
    
    // Tells the NSStatusItem what menu to load
    [statusItem setMenu: statusMenu];
    // Sets the tooltip for our item
    [statusItem setToolTip: @"Scrape"];
    // Enables highlighting
    [statusItem setHighlightMode: YES];
}

- (void)dealloc {
    // Releases the 2 images we loaded into memory
    [idleImage release];
    [selectImage release];
    
    [super dealloc];
}

@end
