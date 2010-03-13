//
//  ScrapePrefsController.h
//  Scrape
//
//  Created by Elie Zananiri on 10-03-12.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


extern NSString *ScrapeAutomaticSettingsChanged;
extern NSString *ScrapeAutomaticToggleKey;
extern NSString *ScrapeAutomaticMinKey;
extern NSString *ScrapeAutomaticMaxKey;


@interface ScrapePrefsController : NSWindowController {
    IBOutlet NSButton       *automaticSwitch;
    IBOutlet NSStepper      *automaticMinStepper;
    IBOutlet NSStepper      *automaticMaxStepper;
    IBOutlet NSTextField    *automaticMinLabel;
    IBOutlet NSTextField    *automaticMaxLabel;
}

- (IBAction)setAutomaticToggle:(id)sender;
- (IBAction)setAutomaticMinFromStepper:(id)sender;
- (IBAction)setAutomaticMaxFromStepper:(id)sender;
- (IBAction)setAutomaticMinFromTextField:(id)sender;
- (IBAction)setAutomaticMaxFromTextField:(id)sender;

@end
