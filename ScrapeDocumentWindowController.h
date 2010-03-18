//
//  ScrapeDocumentWindowController.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-28.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScrapeGLView.h"
#import "ASIFormDataRequest.h"


#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface ScrapeDocumentWindowController : NSWindowController {
#else
@interface ScrapeDocumentWindowController : NSWindowController <NSToolbarDelegate> {
#endif
    IBOutlet NSToolbarItem *uploadButton;
    IBOutlet NSPopUpButton *formatDropDown;
    IBOutlet ScrapeGLView  *glView;
    
    NSDate *scrapeDate;
}

- (NSString *)makeFilename;

- (IBAction)doRefresh:(id)sender;
- (IBAction)doChangeFormat:(id)sender;
- (IBAction)doSave:(id)sender;
- (IBAction)doUpload:(id)sender;
    
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end
