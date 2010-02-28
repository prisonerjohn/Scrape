//
//  ScrapeDocumentWindowController.m
//  Scrape
//
//  Created by Elie Zananiri on 10-02-28.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import "ScrapeDocumentWindowController.h"


@implementation ScrapeDocumentWindowController

- (id)init {
    self = [super initWithWindowNibName:@"ScrapeDocument"];
    return self;
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
    NSDate *now = [NSDate date];
    NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [inputFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    NSString *title = @"Scrape ";
    title = [title stringByAppendingString:[inputFormatter stringFromDate:now]];
    
    return title;
}

@end
