//
//  ScrapeDocumentWindowController.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-28.
//  Copyright 2010-2014 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScrapeGLView.h"
#import "AFNetworking.h"

//--------------------------------------------------------------
@interface ScrapeDocumentWindowController : NSWindowController <NSToolbarDelegate, NSAnimationDelegate>

@property (weak) IBOutlet NSPopUpButton *formatButton;
@property (weak) IBOutlet NSPopUpButton *uploadButton;

@property (weak) IBOutlet ScrapeGLView *glView;
@property (weak) IBOutlet NSProgressIndicator *uploadProgressIndicator;
@property (weak) IBOutlet NSImageView *uploadErrorImageView;
@property (weak) IBOutlet NSImageView *uploadSuccessImageView;

- (NSString *)makeFilename;

- (IBAction)doRefresh:(id)sender;
- (IBAction)doChangeFormat:(id)sender;
- (IBAction)doSave:(id)sender;
    
- (IBAction)doUploadOnly:(id)sender;
- (IBAction)doUploadAndPost:(id)sender;
- (void)doUpload:(BOOL)andPost;

- (void)animationDidEnd:(NSAnimation *)animation;

@end
