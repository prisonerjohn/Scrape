//
//  ScrapeDocumentWindowController.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-28.
//  Copyright 2010-2014 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScrapeGLView.h"
#import "ASIFormDataRequest.h"


#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface ScrapeDocumentWindowController : NSWindowController {
#else
@interface ScrapeDocumentWindowController : NSWindowController <NSToolbarDelegate> {
#endif
    IBOutlet NSPopUpButton          *uploadButton;
    IBOutlet NSPopUpButton          *formatDropDown;
    IBOutlet ScrapeGLView           *glView;
    IBOutlet NSProgressIndicator    *uploadProgressIndicator;
    IBOutlet NSImageView            *uploadSuccessOverlay;
    IBOutlet NSImageView            *uploadErrorOverlay;
    
    NSDate *scrapeDate;
    BOOL    uploading;
}

- (NSString *)makeFilename;

- (IBAction)doRefresh:(id)sender;
- (IBAction)doChangeFormat:(id)sender;
- (IBAction)doSave:(id)sender;
    
- (IBAction)doUploadOnly:(id)sender;
- (IBAction)doUploadAndPost:(id)sender;
- (void)doUpload:(BOOL)andPost;
    
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
    
- (void)animationDidEnd:(NSAnimation *)animation;

@end
