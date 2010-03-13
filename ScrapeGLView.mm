//
//  ScrapeGLView.h
//  Scrape
//
//  Created by Elie Zananiri on 10-02-27.
//  Copyright 2010 silentlyCrashing::net. All rights reserved.
//

#import "ScrapeGLView.h"


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

//--------------------------------------------------------------
- (void)awakeFromNib {
    texFormat    = GL_RGB;
    texHandles = new GLuint[NUM_TEXTURES];
}

//--------------------------------------------------------------
//- (void)initGL {
//    // allocate texture
//    GLuint tmpHandle;
//    glGenTextures(1, &tmpHandle);
//    
//    glEnable(texTarget);
//    {
//        glBindTexture(texTarget, tmpHandle);
//    
//        // initialize it to nothing
//        glTexImage2D(texTarget, 0, GL_RGBA, texSize, texSize, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
//        glTexParameterf(texTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameterf(texTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        
//        // draw it in the buffer
//        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
//        glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
//        glEnableClientState(GL_VERTEX_ARRAY);		
//        glVertexPointer(2, GL_FLOAT, 0, verts);
//        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//        
//        // retrieve the pixels from memory
//        srcData = [[NSMutableData dataWithLength:texSize*texSize*4] retain];
//        glReadBuffer(GL_BACK);
//        glReadPixels(0, 0, texSize, texSize, GL_RGBA, GL_UNSIGNED_BYTE, [srcData mutableBytes]);
//    }
//    glDisable(texTarget);
//    
//    glDeleteTextures(1, &tmpHandle);
//    
//    [self interpret:GL_RGBA];
//    
//    initialized = YES;
//}

//--------------------------------------------------------------
- (void)dealloc {
    glDeleteTextures(NUM_TEXTURES, texHandles);
    delete [] texHandles;
    [super dealloc];
}

//--------------------------------------------------------------
- (void)refresh {
    currHandle = (currHandle+1)%NUM_TEXTURES;
    [self display];
}

//--------------------------------------------------------------
- (void)setFormat:(GLint)format {
    texFormat = format;
    [self display];   
}

//--------------------------------------------------------------
- (void)drawRect:(NSRect)bounds {
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // clear the old texture first
//    if (releaseFirst && texHandle) {
//        glDeleteTextures(1, &texHandle);
//    }
    // alloc
    //int newTexHandle;
    glGenTextures(1, &texHandles[currHandle]);
    glEnable(texTarget);
    {
        glBindTexture(texTarget, texHandles[currHandle]);
        
        // init
        glTexImage2D(texTarget, 0, texFormat, texSize, texSize, 0, (texFormat == GL_R3_G3_B2)? GL_RGBA:texFormat, GL_UNSIGNED_BYTE, 0);
        
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
    
    // clear the old texture after
//    if (!releaseFirst && texHandle) {
//        glDeleteTextures(1, &texHandle);
//        releaseFirst = YES;
//    }
//    texHandle = newTexHandle;
    
    glFlush();
}

@end
