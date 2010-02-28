#import "ScrapeGLView.h"
#include <OpenGL/gl.h>

//--------------------------------------------------------------
//--------------------------------------------------------------
// STATIC CONSTANTS
const int texSize   = 512;
const int texTarget = GL_TEXTURE_2D;

const GLfloat texCoords[] = {
    0, 0,
    1, 0,
    1, 1,
    0, 1
};

const GLfloat verts[] = {
    -1, -1,
     1, -1,
     1,  1,
    -1,  1
};


//--------------------------------------------------------------
//--------------------------------------------------------------
@implementation ScrapeGLView

//--------------------------------------------------------------
- (void) drawRect: (NSRect) bounds {
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // alloc
    GLuint texHandle;
    glGenTextures(1, &texHandle);
    glEnable(texTarget);
    glBindTexture(texTarget, texHandle);
    
    // init
    glTexImage2D(texTarget, 0, GL_RGBA8, texSize, texSize, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    
    glTexParameterf(texTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(texTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    // draw
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glEnableClientState(GL_VERTEX_ARRAY);		
    glVertexPointer(2, GL_FLOAT, 0, verts);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glDisable(texTarget);
    
    glFlush();
}

@end
