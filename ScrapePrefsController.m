//
//  ScrapePrefsController.m
//  Scrape
//
//  Created by Elie Zananiri on 10-03-12.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import "ScrapePrefsController.h"


//--------------------------------------------------------------
//--------------------------------------------------------------
NSString *ScrapeAutomaticSettingsChanged = @"Automatic Settings Changed";
NSString *ScrapeAutomaticToggleKey       = @"Automatic Toggle";
NSString *ScrapeAutomaticMinKey          = @"Automatic Min";
NSString *ScrapeAutomaticMaxKey          = @"Automatic Max";


//--------------------------------------------------------------
//--------------------------------------------------------------
@implementation ScrapePrefsController

//--------------------------------------------------------------
- (id)init {
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        return self;
    }
    return nil;
}

//--------------------------------------------------------------
- (void)windowDidLoad {
    // set saved preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [automaticSwitch     setState:[defaults boolForKey:ScrapeAutomaticToggleKey]];
    [automaticMinStepper setIntegerValue:[defaults integerForKey:ScrapeAutomaticMinKey]];
    [automaticMinStepper setEnabled:[automaticSwitch state]];
    [automaticMaxStepper setIntegerValue:[defaults integerForKey:ScrapeAutomaticMaxKey]];
    [automaticMaxStepper setEnabled:[automaticSwitch state]];
    [automaticMinLabel   setIntegerValue:[defaults integerForKey:ScrapeAutomaticMinKey]];
    [automaticMinLabel   setEnabled:[automaticSwitch state]];
    [automaticMaxLabel   setIntegerValue:[defaults integerForKey:ScrapeAutomaticMaxKey]];
    [automaticMaxLabel   setEnabled:[automaticSwitch state]];
}

//--------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticToggle:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender state]
               forKey:ScrapeAutomaticToggleKey];
    [defaults synchronize];
    
    [automaticMinLabel   setEnabled:[sender state]];
    [automaticMaxLabel   setEnabled:[sender state]];
    [automaticMinStepper setEnabled:[sender state]];
    [automaticMaxStepper setEnabled:[sender state]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChanged 
                                                        object:self];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticMinFromStepper:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMinKey];
    [defaults synchronize];
    
    [automaticMinLabel setIntValue:[sender intValue]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChanged 
                                                        object:self];
}
         
//--------------------------------------------------------------
- (IBAction)setAutomaticMinFromTextField:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMinKey];
    [defaults synchronize];
    
    [automaticMinStepper setIntValue:[sender intValue]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChanged 
                                                        object:self];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticMaxFromStepper:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMaxKey];
    [defaults synchronize];
    
    [automaticMaxLabel setIntValue:[sender intValue]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChanged 
                                                        object:self];
}

//--------------------------------------------------------------
- (IBAction)setAutomaticMaxFromTextField:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[sender intValue]
                  forKey:ScrapeAutomaticMaxKey];
    [defaults synchronize];
    
    [automaticMaxStepper setIntValue:[sender intValue]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrapeAutomaticSettingsChanged 
                                                        object:self];
}

@end
