#import "GLView.h"
#include <OpenGL/gl.h>

@implementation GLView

static void drawAnObject() {
    glColor3f(1.f, .85f, .35f);
    glBegin(GL_TRIANGLES);
    {
        glVertex3f( 0.0,  0.6, 0.0);
        glVertex3f(-0.2, -0.3, 0.0);
        glVertex3f( 0.2, -0.3 ,0.0);
    }
    glEnd();
}

- (void) drawRect: (NSRect) bounds {
    NSLog(@"Anything?", bounds.size.width, bounds.size.height);
    
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    int texSize = 512;
    int texTarget = GL_TEXTURE_2D;
    
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
    GLfloat tex_coords[] = {
        0, 0,
        1, 0,
        1, 1,
        0, 1
    };
    GLfloat verts[] = {
        -1, -1,
         1, -1,
         1,  1,
        -1,  1
    };
//    GLfloat tex_coords[] = {
//        0,0,
//        texSize,0,
//        texSize,texSize,
//        0,texSize
//    };
//    GLfloat verts[] = {
//        -texSize/2, -texSize/2,
//         texSize/2, -texSize/2,
//         texSize/2,  texSize/2,
//        -texSize/2,  texSize/2
//    };
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, tex_coords);
    glEnableClientState(GL_VERTEX_ARRAY);		
    glVertexPointer(2, GL_FLOAT, 0, verts);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glDisable(texTarget);
    
    //drawAnObject();
    
    glFlush();
}

@end
