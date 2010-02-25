#import <Cocoa/Cocoa.h>

@interface GLView : NSOpenGLView {
    GLfloat* texCoords;
    GLfloat* verts;
}

- (void) drawRect: (NSRect) bounds;

@end
