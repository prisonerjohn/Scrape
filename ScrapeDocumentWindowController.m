//
//  ScrapeDocumentWindowController.m
//  Scrape
//
//  Created by Elie Zananiri on 10-02-28.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import "ScrapeDocumentWindowController.h"
#import "ScrapeAppDelegate.h"
#import "ScrapePrefsController.h"
#import <Growl/Growl.h>


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

static NSArray *formatNames = nil;

//--------------------------------------------------------------
+ (void)initialize {
    if (!formatNames) {
        formatNames = [[NSArray arrayWithObjects:@".rgb", @".r3g3b2", @".rgba", @".lum", @".luma", @".depth", nil] retain];
    }
}

//--------------------------------------------------------------
- (id)init {
    self = [super initWithWindowNibName:@"ScrapeDocument"];
    uploading = NO;
    
    return self;
}

//--------------------------------------------------------------
- (void)windowDidLoad {
    [uploadSuccessOverlay setAlphaValue:0.0];
    [uploadErrorOverlay   setAlphaValue:0.0];
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
- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem {
    if (toolbarItem == uploadButton && ([ScrapePrefsController isLoggedIn] == NO || uploading == YES)) {
        return NO;
    }
	return YES;
}

//--------------------------------------------------------------
- (NSString *)makeFilename {
    NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [inputFormatter setDateFormat:@".yyyyMMdd.HHmmss"];
    NSString *name = @"scrape";
    name = [name stringByAppendingString:[inputFormatter stringFromDate:scrapeDate]];
    name = [name stringByAppendingString:[formatNames objectAtIndex:[formatDropDown indexOfSelectedItem]]];
    return name;
}

//--------------------------------------------------------------
- (IBAction)doRefresh:(id)sender {
    NSLog(@"Refreshing");
    if (scrapeDate) [scrapeDate release];
    [[self window] setTitle:[self windowTitleForDocumentDisplayName:nil]];
    [glView refresh];
}

//--------------------------------------------------------------
- (IBAction)doChangeFormat:(id)sender {
    NSLog(@"Changing format to %@", [formatDropDown titleOfSelectedItem]);
    [glView setFormat:formats[[formatDropDown indexOfSelectedItem]]];
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
    [savePanel setExtensionHidden:NO];
    
    [savePanel setNameFieldStringValue:[[self makeFilename] stringByAppendingString:@".tiff"]];
    
    if ([savePanel runModal] == NSFileHandlingPanelOKButton) {
        NSData *tiffData = [image TIFFRepresentation];
        [tiffData writeToFile:[savePanel filename] atomically:YES];
        
        [GrowlApplicationBridge notifyWithTitle:@"Image Saved!"
                                    description:nil
                               notificationName:@"Save"
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:[[savePanel URL] path]];
    }
}

//--------------------------------------------------------------
- (IBAction)doUpload:(id)sender {
    NSLog(@"Uploading image");
    
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
    
    // generate TIFF representation of image
    NSData *tiffData = [image TIFFRepresentation];
    
    // generate PNG representation of image
    NSArray *keys = [NSArray arrayWithObject:@"NSImageCompressionFactor"];
    NSArray *objects = [NSArray arrayWithObject:@"1.0"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:tiffData];
    NSData *pngData = [imageRep representationUsingType:NSPNGFileType properties:dictionary];
    
    // upload both representations to the server
    NSLog(@"Uploading with keychain credentials");
    NSURL *url = [NSURL URLWithString:[SiteRoot stringByAppendingString:@"upload.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"User-Agent" value:@"Scrape-User-Agent-1.0"];
    [request setPostValue:KeychainUsername
                   forKey:@"username"];
    [request setPostValue:KeychainPassword
                   forKey:@"password"];
    [request setPostValue:[self makeFilename]
                   forKey:@"filename"];
    [request setData:tiffData 
        withFileName:[[self makeFilename] stringByAppendingString:@".tiff"] 
      andContentType:@"image/tiff" 
              forKey:@"tiffData"]; 
    [request setData:pngData 
        withFileName:[[self makeFilename] stringByAppendingString:@".png"] 
      andContentType:@"image/png" 
              forKey:@"pngData"];
    [request setDelegate:self];
    [request setUploadProgressDelegate:uploadProgressIndicator];
    [request startAsynchronous];
    
    uploading = YES;
    [uploadProgressIndicator setDoubleValue:0];
    [uploadButton validate];
}

//--------------------------------------------------------------
- (void)requestFinished:(ASIHTTPRequest *)request {
    uploading = NO;
    [uploadProgressIndicator setDoubleValue:0];
    [uploadButton validate];
    
    NSString *responseString = [request responseString];
    NSRange textRange = [responseString rangeOfString:@"ERROR"];
    if (textRange.location == NSNotFound) {
        NSLog(@"Successfully uploaded");
        
        // display a Growl notification
        [GrowlApplicationBridge notifyWithTitle:@"Upload Complete!"
                                    description:@"Your data has been uploaded to the Scrape server"
                               notificationName:@"Upload Success"
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:responseString];
        
        // display the success overlay 
        [uploadSuccessOverlay setHidden:NO];
        NSMutableDictionary *animParams = [NSMutableDictionary dictionaryWithCapacity:2];
        [animParams setObject:uploadSuccessOverlay 
                       forKey:NSViewAnimationTargetKey];
        [animParams setObject:NSViewAnimationFadeInEffect 
                       forKey:NSViewAnimationEffectKey];
        NSAnimation *overlayAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:animParams, nil]];
        [overlayAnimation setDuration:1.5];
        [overlayAnimation setAnimationCurve:NSAnimationEaseOut];
        [overlayAnimation startAnimation];
        [overlayAnimation release];
        
    } else {
        [self requestFailed:request];
    }
}

//--------------------------------------------------------------
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    NSLog(@"Error uploading: %@", responseString);
    
    NSString *descString;
    NSRange textRange = [responseString rangeOfString:@"Duplicate"];
    if (textRange.location == NSNotFound) {
        descString = @"There was an error uploading your data to the Scrape server";
    } else {
        descString = @"You have already uploaded this scrape to the server";
    }
    
    uploading = NO;
    [uploadProgressIndicator setDoubleValue:0];
    [uploadButton validate];
        
    // display a Growl notification
    NSError *error = [request error];
    NSLog(@"%@", [error localizedDescription]);
    [GrowlApplicationBridge notifyWithTitle:@"Upload Error"
                                description:descString
                           notificationName:@"Upload Fail"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
    
    // display the error overlay
    [uploadErrorOverlay setHidden:NO];
    NSMutableDictionary *animParams = [NSMutableDictionary dictionaryWithCapacity:2];
    [animParams setObject:uploadErrorOverlay 
                   forKey:NSViewAnimationTargetKey];
    [animParams setObject:NSViewAnimationFadeInEffect 
                   forKey:NSViewAnimationEffectKey];
    NSAnimation *overlayAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:animParams, nil]];
    [overlayAnimation setDuration:1.5];
    [overlayAnimation setAnimationCurve:NSAnimationEaseOut];
    [overlayAnimation startAnimation];
    [overlayAnimation release];
}

@end
