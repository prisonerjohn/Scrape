#import <Cocoa/Cocoa.h>

@interface ScrapeAppController : NSObject {
    NSWindow* window;
    
    IBOutlet NSMenu*    statusMenu;
    
    NSStatusItem*       statusItem;
    NSImage*            idleImage;
    NSImage*            selectImage;
}

@property (assign) IBOutlet NSWindow* window;

- (IBAction) doScrape: (id) sender;
- (IBAction) doRefresh: (id) sender;
- (IBAction) doSave: (id) sender;
- (IBAction) doUpload: (id) sender;

@end
