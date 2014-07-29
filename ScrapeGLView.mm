//
//  ScrapeGLView.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-27.
//  Copyright 2010-2014 silentlyCrashing::net. All rights reserved.
//

#import "ScrapeGLView.h"
#import "ScrapeAppDelegate.h"


//--------------------------------------------------------------
//--------------------------------------------------------------
// STATIC CONSTANTS
static const int texSize   = 512;
static const int texTarget = GL_TEXTURE_2D;

static const GLfloat texCoords[] = {
    0, 0,
    1, 0,
    1, 1,
    0, 1
};

static const GLfloat verts[] = {
    -1,  1,
     1,  1,
     1, -1,
    -1, -1
};


//--------------------------------------------------------------
//--------------------------------------------------------------
@implementation ScrapeGLView

static NSBitmapImageRep *destroyData;

//--------------------------------------------------------------
+ (void)initialize {
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage *destroyImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"destroy" 
                                                                                     ofType:@"png"]];
    NSSize imgSize = [destroyImage size];
    
    [destroyImage lockFocus];
    destroyData = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, imgSize.width, imgSize.height)];
    [destroyImage unlockFocus];
    
    [destroyImage release];
}

//--------------------------------------------------------------
- (void)awakeFromNib {
    texFormat  = GL_RGB;
    texHandle  = 0;
}

//--------------------------------------------------------------
- (void)dealloc {
    glDeleteTextures(1, &texHandle);
    [super dealloc];
}

//--------------------------------------------------------------
- (void)refresh {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:ScrapeDestroyDataOnReleaseKey] == YES) {
        // destroy the current texture data before moving over to the next one
        [self destroyCurrentData];
    }
    
    [self allocateData];
    [self display];
}

//--------------------------------------------------------------
- (void)setFormat:(GLint)format {
    texFormat = format;
    [self allocateData];
    [self display];   
}

//--------------------------------------------------------------
- (void)allocateData {
    NSLog(@"Allocating data");
    
    // alloc
    glGenTextures(1, &texHandle);
    
    glEnable(texTarget);
    {
        glBindTexture(texTarget, texHandle);

        // init
        glTexImage2D(texTarget, 0, texFormat, texSize, texSize, 0, (texFormat == GL_R3_G3_B2)? GL_RGBA:texFormat, GL_UNSIGNED_BYTE, 0);
    }
    glDisable(texTarget);
}

//--------------------------------------------------------------
- (void)drawRect:(NSRect)bounds {
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (texHandle == 0) {
        [self allocateData];
    }
    
    glEnable(texTarget);
    {
        glBindTexture(texTarget, texHandle);
        
        glTexParameterf(texTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(texTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        
        // draw
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
        glEnableClientState(GL_VERTEX_ARRAY);		
        glVertexPointer(2, GL_FLOAT, 0, verts);
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    glDisable(texTarget);
    
    glFlush();
}

//--------------------------------------------------------------
- (void)destroyCurrentData {
    if (texHandle == 0) {
        // texture handle is null, ignore it
        return;
    }
    
    NSLog(@"Destroying current data");
    glEnable(texTarget);
    {
        glBindTexture(texTarget, texHandle);
        
        glTexParameteri(texTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(texTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        
        glTexSubImage2D(texTarget, 0, 0, 0, [destroyData pixelsWide], [destroyData pixelsHigh], GL_RGBA, GL_UNSIGNED_BYTE, [destroyData bitmapData]);            
    }
    glDisable(texTarget);
}

@end
