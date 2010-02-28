#import "AppController.h"

@implementation AppController

@synthesize window;

- (void) awakeFromNib {
    // Create the NSStatusBar and set its length
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength: NSSquareStatusItemLength] retain];
    
    // Allocates and loads the images into the application which will be used for our NSStatusItem
    NSBundle* bundle = [NSBundle mainBundle];
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
    
    // hide the GLView
    NSLog(@"At some point...");
    [window setIsVisible: NO];
}

- (void) dealloc {
    // Releases the 2 images we loaded into memory
    [idleImage release];
    [selectImage release];
    
    [super dealloc];
}

- (IBAction) doScrape: (id) sender {
    NSLog(@"Scrape!");
    
//    NSRect frame = NSMakeRect(100, 100, 200, 200);
//    NSUInteger styleMask =    NSBorderlessWindowMask;
//    NSRect rect = [NSWindow contentRectForFrameRect:frame styleMask:styleMask];
//    NSWindow * window =  [[NSWindow alloc] initWithContentRect:rect styleMask:styleMask backing: NSBackingStoreBuffered    defer:false];
//    [window setBackgroundColor:[NSColor blueColor]];
//    [window makeKeyAndOrderFront: window];
}

- (IBAction) doRefresh: (id) sender {
    NSLog(@"Refresh!");
}

- (IBAction) doSave: (id) sender {
    NSLog(@"Save!");
}

- (IBAction) doUpload: (id) sender {
    NSLog(@"Upload!");
}

@end
