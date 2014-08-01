//
//  ScrapeDocument.m
//  Scrape
//
//  Created by Elie Zananiri on 10-02-28.
//  Copyright 2010-2014 silentlyCrashing::net. All rights reserved.
//

#import "ScrapeDocument.h"
#import "ScrapeDocumentWindowController.h"

//--------------------------------------------------------------
//--------------------------------------------------------------
@implementation ScrapeDocument

//--------------------------------------------------------------
- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
}

//--------------------------------------------------------------
- (void)makeWindowControllers
{
    ScrapeDocumentWindowController *winController = [[ScrapeDocumentWindowController alloc] init];
    [self addWindowController:winController];
}

@end
