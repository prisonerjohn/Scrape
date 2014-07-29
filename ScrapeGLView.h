//
//  ScrapeGLView.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-27.
//  Copyright 2010-2014 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

#define NUM_TEXTURES 32


@interface ScrapeGLView : NSOpenGLView {
    GLuint  texHandle;
    GLint   texFormat;
}

- (void)refresh;
- (void)setFormat:(GLint)format;

- (void)allocateData;
- (void)destroyCurrentData;

- (void)drawRect:(NSRect)bounds;

@end
