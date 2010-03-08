//
//  ScrapeDocumentWindowController.m
//  Scrape
//
//  Created by Elie Zananiri on 10-02-28.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import "ScrapeDocumentWindowController.h"


//--------------------------------------------------------------
//--------------------------------------------------------------
// STATIC CONSTANTS
static const GLint formats[] = {
    GL_RGB, 
    GL_R3_G3_B2, 
    GL_RGBA, 
    GL_LUMINANCE,
    GL_LUMINANCE_ALPHA,
    GL_DEPTH_COMPONENT
};


//--------------------------------------------------------------
//--------------------------------------------------------------
@implementation ScrapeDocumentWindowController

//--------------------------------------------------------------
- (id)init {
    self = [super initWithWindowNibName:@"ScrapeDocument"];
    [NSApp activateIgnoringOtherApps:YES];
    //[NSApp arrangeInFront:self];
    return self;
}

//--------------------------------------------------------------
- (void)dealloc {
    [scrapeDate release];
    [super dealloc];
}

//--------------------------------------------------------------
- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
    scrapeDate = [[NSDate date] retain];
    NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [inputFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    NSString *title = @"Scrape ";
    title = [title stringByAppendingString:[inputFormatter stringFromDate:scrapeDate]];
    
    return title;
}

//--------------------------------------------------------------
- (IBAction)doRefresh:(id)sender {
    NSLog(@"Refreshing");
    [glView refresh];
}

//--------------------------------------------------------------
- (IBAction)doSave:(id)sender {
    NSLog(@"Saving image");
    
    unsigned char* planes[1];
    NSSize size;
    NSBitmapImageRep *bitmap;
    NSImage *image;
    
    size = [glView bounds].size;
    NSMutableData *buffer = [NSMutableData dataWithLength:size.width*size.height*4];
    glReadBuffer(GL_BACK);
    glReadPixels(0, 0, size.width, size.height, GL_RGBA, GL_UNSIGNED_BYTE, [buffer mutableBytes]);
    planes[0] = [buffer mutableBytes];
    bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:planes
                                                     pixelsWide:size.width pixelsHigh:size.height bitsPerSample:8
                                                samplesPerPixel:4 hasAlpha:YES isPlanar:NO
                                                 colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:(size.width * 4)
                                                   bitsPerPixel:32];
    
    image = [[NSImage alloc] initWithSize:size];

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
    [image setFlipped:YES];
    [image lockFocus];
#else
    [image lockFocusFlipped:YES];
#endif
    [bitmap drawInRect:NSMakeRect(0, 0, size.width, size.height)];
    [image unlockFocus];
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setTitle:@"Save Image As:"];
    [savePanel setRequiredFileType:@"tiff"];
    
    NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [inputFormatter setDateFormat:@".yyyyMMdd.HHmmss"];
    NSString *name = @"scrape";
    name = [name stringByAppendingString:[inputFormatter stringFromDate:scrapeDate]];
    [savePanel setNameFieldStringValue:name];
    
    if ([savePanel runModal] == NSFileHandlingPanelOKButton) {
        NSData *tiffData = [image TIFFRepresentation];
        [tiffData writeToFile:[savePanel filename] atomically:YES];
    }
}

//--------------------------------------------------------------
- (IBAction)doUpload:(id)sender {
    NSLog(@"Upload!");
}

//--------------------------------------------------------------
- (IBAction)doChangeFormat:(id)sender {
    NSLog(@"Changing format to %@", [formatDropDown titleOfSelectedItem]);
    [glView setFormat:formats[[formatDropDown indexOfSelectedItem]]];
}

@end
