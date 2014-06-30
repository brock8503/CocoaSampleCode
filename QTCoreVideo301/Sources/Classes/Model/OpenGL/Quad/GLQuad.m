/*
     File: GLQuad.m
 Abstract: 
 Utility bass class for constructing a VBO quad.
 
  Version: 2.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#pragma mark -
#pragma mark Private - Headers

#import "GLQuad.h"

#pragma mark -
#pragma mark Private - Data Structures

struct GLQuadData
{
    BOOL      resize;       // Flag to indicate if quad size changed
	GLuint    buffer;       // buffer identifier
	GLuint    count;		// vertex count
	GLuint    size;			// size of vertices or texture coordinates
	GLuint    capacity;		// vertex size + texture coordinate size
	GLsizei   stride;		// vbo stride
	GLenum    target;       // vbo target
	GLenum    usage;		// vbo usage
	GLenum    type;			// vbo type
	GLenum    mode;			// vbo mode
	GLfloat   width;		// quad width
	GLfloat   height;		// quad height
	GLfloat   aspect;		// aspect ratio
	GLfloat  *data;			// vbo data
	GLenum    quadType;		// vbo quad type
    GLfloat   vertices[8];  // Quad vertices
    GLfloat   texCoords[8]; // Quad texture coordinates
};

typedef struct GLQuadData  GLQuadData;

#pragma mark -
#pragma mark Private - Macros

#define BUFFER_OFFSET(i) ((GLchar *)NULL + (i))

#pragma mark -
#pragma mark Private - Accessors

static BOOL GLQuadSetSize(const NSSize *pSize,
                          GLQuadDataRef pQuad)
{
    BOOL bSuccess = (pSize != NULL);
    
    if(bSuccess)
    {
        pQuad->resize = (pQuad->width != pSize->height) || (pQuad->width != pSize->height);
        
        if(pQuad->resize)
        {
            pQuad->width  = pSize->width;
            pQuad->height = pSize->height;
            pQuad->aspect = pSize->width / pSize->height;
        } // if
    } // if
    else
    {
        pQuad->width  = 1920.0f;
        pQuad->height = 1080.0f;
        pQuad->aspect = pQuad->width / pQuad->height;
    } // else
    
    return(bSuccess && pQuad->resize);
} // GLQuadSetSize

static void GLQuadSetDefaults(GLQuadDataRef pQuad)
{
	pQuad->count    = 4;
	pQuad->size     = 8 * sizeof(GLfloat);
	pQuad->capacity = 2 * pQuad->size;
	pQuad->usage    = GL_STATIC_DRAW;
	pQuad->type     = GL_FLOAT;
	pQuad->mode     = GL_QUADS;
	pQuad->target   = GL_ARRAY_BUFFER;
} // GLQuadSetDefaults

static BOOL GLQuadSetTextureCoordinates(const GLfloat *pTexCoords,
                                        GLQuadDataRef pQuad)
{
    BOOL success = pTexCoords != NULL;
    
    if(success)
    {
        pQuad->texCoords[0] = pTexCoords[0];
        pQuad->texCoords[1] = pTexCoords[1];
        pQuad->texCoords[2] = pTexCoords[2];
        pQuad->texCoords[3] = pTexCoords[3];
        pQuad->texCoords[4] = pTexCoords[4];
        pQuad->texCoords[5] = pTexCoords[5],
        pQuad->texCoords[6] = pTexCoords[6];
        pQuad->texCoords[7] = pTexCoords[7];
    } // if
    
    return(success);
} // GLQuadSetTextureCoordinates

static BOOL GLQuadSetVertexArray(const GLfloat *pVertices,
                                 GLQuadDataRef pQuad)
{
    BOOL success = pVertices != NULL;
    
    if(success)
    {
        pQuad->vertices[0] = pVertices[0];
        pQuad->vertices[1] = pVertices[1];
        pQuad->vertices[2] = pVertices[2];
        pQuad->vertices[3] = pVertices[3];
        pQuad->vertices[4] = pVertices[4];
        pQuad->vertices[5] = pVertices[5],
        pQuad->vertices[6] = pVertices[6];
        pQuad->vertices[7] = pVertices[7];
    } // if
    
    return(success);
} // GLQuadSetVertexArray

#pragma mark -
#pragma mark Private - Initializers

static void GLQuadInitArrays(GLQuadDataRef pQuad)
{
    pQuad->texCoords[0]  = 0.0f;
    pQuad->texCoords[1]  = 0.0f;
    pQuad->texCoords[2]  = 0.0f;
    pQuad->texCoords[3]  = 1.0f;
    pQuad->texCoords[4]  = 1.0f;
    pQuad->texCoords[5]  = 1.0f;
    pQuad->texCoords[6]  = 1.0f;
    pQuad->texCoords[7]  = 0.0f;
    
    pQuad->vertices[0]  = -1.0f;
    pQuad->vertices[1]  = -1.0f;
    pQuad->vertices[2]  = -1.0f;
    pQuad->vertices[3]  =  1.0f;
    pQuad->vertices[4]  =  1.0f;
    pQuad->vertices[5]  =  1.0f;
    pQuad->vertices[6]  =  1.0f;
    pQuad->vertices[7]  = -1.0f;
} // GLQuadInitArrays

#pragma mark -
#pragma mark Private - Constructor

static GLQuadDataRef GLQuadCreate(const NSSize *pSize,
                                  const GLenum target)
{
    GLQuadDataRef pQuad = (GLQuadDataRef)calloc(1, sizeof(GLQuadData));
    
    if(pQuad != NULL)
    {
        GLQuadSetSize(pSize, pQuad);
        GLQuadSetDefaults(pQuad);
        GLQuadInitArrays(pQuad);
    } // if
    else
    {
        NSLog(@">> ERROR: OpenGL Quad - Failure Allocating Memory For Data!");
    }  // else
	
	return(pQuad);
} // GLQuadCreate

#pragma mark -
#pragma mark Private - Destructors

static inline void GLQuadDeleteVertexBuffer(GLQuadDataRef pQuad)
{
    if(pQuad->buffer)
    {
        glDeleteBuffers(1, &pQuad->buffer);
    } // if
} // GLQuadDeleteVertexBuffer

static void GLQuadDelete(GLQuadDataRef pQuad)
{
	if(pQuad != NULL)
	{
        GLQuadDeleteVertexBuffer(pQuad);
		
		free(pQuad);
		
		pQuad = NULL;
	} // if
} // GLQuadDelete

#pragma mark -
#pragma mark Private - Utilities

static BOOL GLQuadAcquire(GLQuadDataRef pQuad)
{
    if(!pQuad->buffer)
    {
        glGenBuffers(1, &pQuad->buffer);
        
        if(pQuad->buffer)
        {
            glBindBuffer(pQuad->target, pQuad->buffer);
            {
                glBufferData(pQuad->target, pQuad->capacity, NULL, pQuad->usage);
                
                glBufferSubData(pQuad->target, 0, pQuad->size, pQuad->vertices);
                glBufferSubData(pQuad->target, pQuad->size, pQuad->size, pQuad->texCoords);
                
                glVertexPointer(2, pQuad->type, pQuad->stride, BUFFER_OFFSET(0));
                glTexCoordPointer(2, pQuad->type, pQuad->stride, BUFFER_OFFSET(pQuad->size));
            }
            glBindBuffer(pQuad->target, 0);
        } // if
    } // if
    
    return(pQuad->buffer != 0);
} // GLQuadAcquire

static BOOL GLQuadUpdate(GLQuadDataRef pQuad)
{
    BOOL bSuccess = pQuad->resize;
    
    if(bSuccess)
    {
        glBindBuffer(pQuad->target,
                     pQuad->buffer);
        {
            glBufferData(pQuad->target,
                         pQuad->capacity,
                         NULL,
                         pQuad->usage);
            
            pQuad->data = (GLfloat *)glMapBuffer(pQuad->target, GL_WRITE_ONLY);
            
            if(pQuad->data != NULL)
            {
                // Vertices
                
                pQuad->data[0] = pQuad->vertices[0];
                pQuad->data[1] = pQuad->vertices[1];
                pQuad->data[2] = pQuad->vertices[2];
                pQuad->data[3] = pQuad->vertices[3];
                pQuad->data[4] = pQuad->vertices[4];
                pQuad->data[5] = pQuad->vertices[5],
                pQuad->data[6] = pQuad->vertices[6];
                pQuad->data[7] = pQuad->vertices[7];
                
                // Texture coordinates
                
                pQuad->data[8]  = pQuad->texCoords[0];
                pQuad->data[9]  = pQuad->texCoords[1];
                pQuad->data[10] = pQuad->texCoords[2];
                pQuad->data[11] = pQuad->texCoords[3];
                pQuad->data[12] = pQuad->texCoords[4];
                pQuad->data[13] = pQuad->texCoords[5],
                pQuad->data[14] = pQuad->texCoords[6];
                pQuad->data[15] = pQuad->texCoords[7];
            } // if
            
            bSuccess = glUnmapBuffer(pQuad->target);
        }
        glBindBuffer(pQuad->target, 0);
    } // if
    
    return(bSuccess);
} // GLQuadUpdate

static void GLQuadDisplay(GLQuadDataRef pQuad)
{
	glBindBuffer(pQuad->target, pQuad->buffer);
	{
        glPushMatrix();
        {
            glScalef(pQuad->aspect, 1.0f, 1.0f);
            
            glDrawArrays(pQuad->mode, 0, pQuad->count);
        }
        glPopMatrix();
	}
	glBindBuffer(pQuad->target, 0);
} // GLQuadDisplay

#pragma mark -

@implementation GLQuad

#pragma mark -
#pragma mark Public - Designated Initializer

// Initialize
- (id) init
{
	self = [super init];
	
	if(self)
	{
		mpQuad = GLQuadCreate(NULL, GL_TEXTURE_2D);
	} // if
	
	return(self);
} // init

- (id) initQuadWithSize:(const NSSize *)theSize
                 target:(const GLenum)theTarget
{
	self = [super init];
	
	if(self)
	{
		mpQuad = GLQuadCreate(theSize, theTarget);
	} // if
	
	return(self);
} // initQuadWithSize

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
	GLQuadDelete(mpQuad);
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Accessors - Getters

- (GLuint) buffer
{
    return(mpQuad->buffer);
} // buffer

- (GLuint) count
{
    return(mpQuad->count);
} // count

- (GLuint) size
{
    return(mpQuad->size);
} // size

- (GLenum) target
{
    return(mpQuad->target);
} // target

- (GLenum) type
{
    return(mpQuad->type);
} // type

- (GLenum) mode
{
    return(mpQuad->mode);
} // mode

- (GLsizei) stride
{
    return(mpQuad->stride);
} // stride

- (GLfloat) aspect
{
    return(mpQuad->aspect);
} // aspect

- (GLfloat) width
{
    return(mpQuad->width);
} // aspect

- (GLfloat) height
{
    return(mpQuad->height);
} // height

#pragma mark -
#pragma mark Public - Accessors - Setters

- (BOOL) setTexCoords:(const GLfloat *)theTexCoords
{
    return(GLQuadSetTextureCoordinates(theTexCoords, mpQuad));
} // setTexCoords

- (BOOL) setVertices:(const GLfloat *)theVertices
{
    return(GLQuadSetVertexArray(theVertices, mpQuad));
} // setVertices

- (BOOL) setSize:(const NSSize *)theSize
{
    return(GLQuadSetSize(theSize, mpQuad));
} // setSize

#pragma mark -
#pragma mark Public - Utilities

- (BOOL) acquire
{
    return(GLQuadAcquire(mpQuad));
} // acquire

- (BOOL) update
{
    return(GLQuadUpdate(mpQuad));
} // update

// Draw a quad using texture & vertex coordinates
- (void) display
{
    GLQuadDisplay(mpQuad);
} // display

@end
