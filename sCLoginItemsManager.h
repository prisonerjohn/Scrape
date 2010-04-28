//
//  sCLoginItemsManager.h
//  Scrape
//
//  Created by Elie Zananiri on 10-04-27.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface sCLoginItemsManager : NSObject {

}

+ (BOOL)willStartAtLogin:(NSURL *)itemURL;
+ (void)setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;

@end
