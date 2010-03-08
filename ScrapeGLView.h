//
//  ScrapeGLView.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-27.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

#define NUM_TEXTURES 5


@interface ScrapeGLView : NSOpenGLView {
    int             currHandle;
    GLuint          *texHandles;
    GLint           texFormat;
}

- (void)refresh;
- (void)setFormat:(GLint)format;

- (void)drawRect:(NSRect)bounds;

@end
