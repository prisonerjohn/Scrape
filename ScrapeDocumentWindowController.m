//
//  ScrapeDocumentWindowController.m
//  Scrape
//
//  Created by Elie Zananiri on 10-02-28.
//  Copyright 2010-2014 silentlyCrashing::net. All rights reserved.
//

#import "ScrapeDocumentWindowController.h"
#import "ScrapeAppDelegate.h"
#import "ScrapePrefsController.h"

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
@implementation ScrapeDocumentWindowController

static NSArray *formatNames = nil;

//--------------------------------------------------------------
+ (void)initialize
{
    if (!formatNames) {
        formatNames = [[NSArray arrayWithObjects:@".rgb", @".r3g3b2", @".rgba", @".lum", @".luma", @".depth", nil] retain];
    }
}

//--------------------------------------------------------------
- (id)init
{
    self = [super initWithWindowNibName:@"ScrapeDocument"];
    uploading = NO;
    
    return self;
}

//--------------------------------------------------------------
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [uploadSuccessOverlay setHidden:YES];
    [uploadErrorOverlay   setHidden:YES];
    [uploadSuccessOverlay setAlphaValue:0.0];
    [uploadErrorOverlay   setAlphaValue:0.0];
}

//--------------------------------------------------------------
- (void)dealloc
{
    [scrapeDate release];
    [super dealloc];
}

//--------------------------------------------------------------
- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
    scrapeDate = [[NSDate date] retain];
    NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [inputFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    NSString *title = @"Scrape ";
    title = [title stringByAppendingString:[inputFormatter stringFromDate:scrapeDate]];
    
    return title;
}

//--------------------------------------------------------------
- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
    if ([ScrapePrefsController isLoggedIn] == NO || uploading == YES) {
        [uploadButton setEnabled:NO];
    }
    else {
        [uploadButton setEnabled:YES];
    }
    return YES;
}

//--------------------------------------------------------------
- (NSString *)makeFilename
{
    NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [inputFormatter setDateFormat:@".yyyyMMdd.HHmmss"];
    NSString *name = @"scrape";
    name = [name stringByAppendingString:[inputFormatter stringFromDate:scrapeDate]];
    name = [name stringByAppendingString:[formatNames objectAtIndex:[formatDropDown indexOfSelectedItem]]];
    return name;
}

//--------------------------------------------------------------
- (IBAction)doRefresh:(id)sender
{
    NSLog(@"Refreshing");
    if (scrapeDate) [scrapeDate release];
    [[self window] setTitle:[self windowTitleForDocumentDisplayName:nil]];
    [glView refresh];
}

//--------------------------------------------------------------
- (IBAction)doChangeFormat:(id)sender
{
    NSLog(@"Changing format to %@", [formatDropDown titleOfSelectedItem]);
    [glView setFormat:formats[[formatDropDown indexOfSelectedItem]]];
}

//--------------------------------------------------------------
- (IBAction)doSave:(id)sender
{
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

    [image lockFocusFlipped:YES];
    [bitmap drawInRect:NSMakeRect(0, 0, size.width, size.height)];
    [image unlockFocus];
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setTitle:@"Save Image As:"];
    [savePanel setAllowedFileTypes:@[@"tiff"]];
    [savePanel setExtensionHidden:NO];
    
    [savePanel setNameFieldStringValue:[[self makeFilename] stringByAppendingString:@".tiff"]];
    
    if ([savePanel runModal] == NSFileHandlingPanelOKButton) {
        NSData *tiffData = [image TIFFRepresentation];
        [tiffData writeToURL:[savePanel URL] atomically:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:ScrapeShowUserNotificationsKey] == YES) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"Image Saved!";
            notification.soundName = NSUserNotificationDefaultSoundName;
            notification.userInfo = @{@"url": [[savePanel URL] path]};            
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
    }
    
    [bitmap release];
    [image release];
}

//--------------------------------------------------------------
- (IBAction)doUploadOnly:(id)sender
{
    [self doUpload:NO];
}

//--------------------------------------------------------------
- (IBAction)doUploadAndPost:(id)sender
{
    [self doUpload:YES];
}

//--------------------------------------------------------------
- (void)doUpload:(BOOL)andPost
{
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
    
    [image lockFocusFlipped:YES];
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
    [imageRep release];
    
    [bitmap release];
    [image release];
    
    // upload both representations to the server
    NSLog(@"Uploading with keychain credentials");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"post": ((andPost == YES)? @"1":@"0"),
                                 @"username": ScrapeKeychainUsername,
                                 @"password": ScrapeKeychainPassword,
                                 @"filename": [self makeFilename]};
    [manager POST:[SiteRoot stringByAppendingString:@"upload.php"]
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
           [formData appendPartWithFileData:tiffData
                                       name:@"tiffData"
                                   fileName:[[self makeFilename] stringByAppendingString:@".tiff"]
                                   mimeType:@"image/tiff"];
           [formData appendPartWithFileData:pngData
                                       name:@"pngData"
                                   fileName:[[self makeFilename] stringByAppendingString:@".png"]
                                   mimeType:@"image/png"];
       }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              uploading = NO;
              [uploadProgressIndicator setDoubleValue:0];
              [uploadButton setEnabled:YES];
              
              NSString *responseString = [operation responseString];
              NSRange textRange = [responseString rangeOfString:@"ERROR"];
              if (textRange.location == NSNotFound) {
                  NSLog(@"Successfully uploaded");
                  
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  if ([defaults boolForKey:ScrapeShowUserNotificationsKey] == YES) {
                      NSUserNotification *notification = [[NSUserNotification alloc] init];
                      notification.title = @"Upload Complete!";
                      notification.informativeText = @"Your data has been uploaded to the Scrape server";
                      notification.userInfo = @{@"url": responseString};
                      [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                  }
                  
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
                  [overlayAnimation setDelegate:self];
                  [overlayAnimation startAnimation];
                  [overlayAnimation release];
                  
              } else {
                  // @TODO: Call the failure block.
//                  [self requestFailed:request];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSString *responseString = [operation responseString];
              NSLog(@"Error uploading: %@", [error localizedDescription]);
              
              NSString *descString;
              NSRange textRange = [responseString rangeOfString:@"Duplicate"];
              if (textRange.location == NSNotFound) {
                  descString = @"There was an error uploading your data to the Scrape server";
              } else {
                  descString = @"You have already uploaded this scrape to the server";
              }
              
              uploading = NO;
              [uploadProgressIndicator setDoubleValue:0];
              [uploadButton setEnabled:YES];
              
              NSLog(@"%@", [error localizedDescription]);
              
              NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
              if ([defaults boolForKey:ScrapeShowUserNotificationsKey] == YES) {
                  NSUserNotification *notification = [[NSUserNotification alloc] init];
                  notification.title = @"Upload Error";
                  notification.informativeText = descString;
                  notification.soundName = NSUserNotificationDefaultSoundName;
                  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
              }
              
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
              [overlayAnimation setDelegate:self];
              [overlayAnimation startAnimation];
              [overlayAnimation release];
          }];
    
    uploading = YES;
    [uploadProgressIndicator setDoubleValue:0];
    [uploadButton setEnabled:NO];
}

//--------------------------------------------------------------
- (void)animationDidEnd:(NSAnimation *)animation
{
    [uploadSuccessOverlay setHidden:YES];
    [uploadErrorOverlay   setHidden:YES];
}

@end
