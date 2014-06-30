/*
     File: GLUQuad.mm
 Abstract: 
 Utility methods for managing a VBO based an OpenGL quad.
 
  Version: 3.1
 
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
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#pragma mark -
#pragma mark Private - Headers

#import <iostream>

#import <OpenGL/gl.h>

#import "GLMSizes.h"
#import "GLUQuad.h"

#pragma mark -
#pragma mark Private - Data Structures

struct GLU::Quad
{
    bool      mbResize;         // Flag to indicate if quad size changed
    bool      mbUpdate;         // Flag to indicate if the tex coordinates changed
    bool      mbMapped;         // Flag to indicate if the vbo was mapped
    GLuint    mnRefCount;       // Reference count
	GLuint    mnBID;            // buffer identifier
	GLuint    mnCount;          // vertex count
	GLuint    mnSize;			// size of m_Vertices or texture coordinates
	GLuint    mnCapacity;		// vertex size + texture coordinate siez
	GLsizei   mnStride;         // vbo stride
	GLenum    mnTarget;         // vbo target
	GLenum    mnUsage;          // vbo usage
	GLenum    mnType;			// vbo type
	GLenum    mnMode;			// vbo mode
    CGRect    m_Bounds;         // vbo bounds;
	GLfloat   mnAspect;         // Aspect ratio
	GLfloat  *mpData;           // vbo data
    GLfloat   m_Vertices[8];    // Quad vertices
    GLfloat   m_TexCoords[8];   // Quad texture coordinates
};

#pragma mark -
#pragma mark Private - Macros

#define BUFFER_OFFSET(i) ((GLchar *)NULL + (i))

#pragma mark -
#pragma mark Private - Accessors

static bool GLUQuadAcquireBounds(const CGRect& bounds,
                                 GLU::QuadRef pQuad)
{
    bool bSuccess = !CGRectIsEmpty(bounds);
    
    if(bSuccess)
    {
        pQuad->mbResize = !CGRectEqualToRect(bounds, pQuad->m_Bounds);
        
        if(pQuad->mbResize)
        {
            pQuad->m_Bounds.origin.x = bounds.origin.x;
            pQuad->m_Bounds.origin.y = bounds.origin.y;
            
            pQuad->m_Bounds.size.width  = bounds.size.width;
            pQuad->m_Bounds.size.height = bounds.size.height;
            
            pQuad->mnAspect = pQuad->m_Bounds.size.width / pQuad->m_Bounds.size.height;
        } // if
    } // if
    else
    {
        pQuad->m_Bounds.origin.x = 0.0f;
        pQuad->m_Bounds.origin.y = 0.0f;
        
        pQuad->m_Bounds.size.width  = 1920.0f;
        pQuad->m_Bounds.size.height = 1080.0f;
        
        pQuad->mnAspect = pQuad->m_Bounds.size.width / pQuad->m_Bounds.size.height;
    } // else
    
    return bSuccess && pQuad->mbResize;
} // GLUQuadAcquireBounds

static bool GLUQuadSetVertices(const CGRect& bounds,
                               GLU::QuadRef pQuad)
{
    bool bSuccess = GLUQuadAcquireBounds(bounds, pQuad);
    
    if(bSuccess)
    {
        pQuad->m_Vertices[0] = pQuad->m_Bounds.origin.x;
        pQuad->m_Vertices[1] = pQuad->m_Bounds.origin.y;
        
        pQuad->m_Vertices[2] = pQuad->m_Bounds.origin.x + pQuad->m_Bounds.size.width;
        pQuad->m_Vertices[3] = pQuad->m_Bounds.origin.y;
        
        pQuad->m_Vertices[4] = pQuad->m_Bounds.origin.x + pQuad->m_Bounds.size.width;
        pQuad->m_Vertices[5] = pQuad->m_Bounds.origin.y + pQuad->m_Bounds.size.height;
        
        pQuad->m_Vertices[6] = pQuad->m_Bounds.origin.x;
        pQuad->m_Vertices[7] = pQuad->m_Bounds.origin.y + pQuad->m_Bounds.size.height;
    } // if
    
    return bSuccess;
} // GLUQuadSetVertices

static bool GLUQuadSetTextCoords(const bool& bIsInverted,
                                 GLU::QuadRef pQuad)
{
    GLfloat nValue = (bIsInverted) ? 0.0f : 1.0f;
    
    pQuad->mbUpdate = pQuad->m_TexCoords[7] != nValue;
    
    if(pQuad->mbUpdate)
    {
        if(bIsInverted)
        {
            pQuad->m_TexCoords[0]  = 0.0f;
            pQuad->m_TexCoords[1]  = 1.0f;
            
            pQuad->m_TexCoords[2]  = 1.0f;
            pQuad->m_TexCoords[3]  = 1.0f;
            
            pQuad->m_TexCoords[4]  = 1.0f;
            pQuad->m_TexCoords[5]  = 0.0f;
            
            pQuad->m_TexCoords[6]  = 0.0f;
            pQuad->m_TexCoords[7]  = 0.0f;
        } // if
        else
        {
            pQuad->m_TexCoords[0]  = 0.0f;
            pQuad->m_TexCoords[1]  = 0.0f;
            
            pQuad->m_TexCoords[2]  = 1.0f;
            pQuad->m_TexCoords[3]  = 0.0f;
            
            pQuad->m_TexCoords[4]  = 1.0f;
            pQuad->m_TexCoords[5]  = 1.0f;
            
            pQuad->m_TexCoords[6]  = 0.0f;
            pQuad->m_TexCoords[7]  = 1.0f;
        } // else
    } // if
    
    return pQuad->mbUpdate;
} // GLUQuadSetTextCoords

#pragma mark -
#pragma mark Private - Constructor

static void GLUQuadSetUsage(const GLenum& nUsage,
                            GLU::QuadRef pQuad)
{
    switch(nUsage)
    {
        case GL_STREAM_DRAW:
        case GL_STATIC_DRAW:
        case GL_DYNAMIC_DRAW:
            pQuad->mnUsage = nUsage;
            break;
            
        default:
            pQuad->mnUsage = GL_STATIC_DRAW;
            break;
    } // switch
} // GLUQuadSetUsage

static void GLUQuadSetDefaults(GLU::QuadRef pQuad)
{
    std::memset(pQuad, 0x0, sizeof(GLU::Quad));
    
    pQuad->mnRefCount = 1;
	pQuad->mnCount    = 4;
	pQuad->mnSize     = 8 * GLM::Size::kFloat;
	pQuad->mnCapacity = 2 * pQuad->mnSize;
	pQuad->mnType     = GL_FLOAT;
	pQuad->mnMode     = GL_QUADS;
	pQuad->mnTarget   = GL_ARRAY_BUFFER;
    
    pQuad->m_TexCoords[7] = 2.0f;
} // GLUQuadSetDefaults

static GLU::QuadRef GLUQuadCreateWithUsage(const GLenum& nUsage)
try
{
    GLU::QuadRef pQuad = new GLU::Quad;
    
    GLUQuadSetDefaults(pQuad);
    GLUQuadSetUsage(nUsage, pQuad);
	
	return pQuad;
} // try
catch(std::bad_alloc& ba)
{
    NSLog(@">> ERROR: OpenGL Quad - Failed allocation quad backing-store: \"%s\"", ba.what());
    
    return NULL;
} // catch

#pragma mark -
#pragma mark Private - Destructors

static void GLUQuadDeleteVertexBuffer(GLU::QuadRef pQuad)
{
    if(pQuad->mnBID)
    {
        glDeleteBuffers(1, &pQuad->mnBID);
    } // if
} // GLUQuadDeleteVertexBuffer

static void GLUQuadDelete(GLU::QuadRef pQuad)
{
	if(pQuad != NULL)
	{
        GLUQuadDeleteVertexBuffer(pQuad);
		
		delete pQuad;
		
		pQuad = NULL;
	} // if
} // GLUQuadDelete

#pragma mark -
#pragma mark Private - Utilities - Reference counting

// Increment the refernce count
static GLU::QuadRef GLUQuadRetainCount(GLU::QuadRef pQuad)
{
    GLU::QuadRef pQuadCopy = NULL;
    
    if(pQuad != NULL)
    {
        pQuad->mnRefCount++;
        
        pQuadCopy = pQuad;
    } // if
    
    return pQuadCopy;
} // GLUQuadRetainCount

// Decrement the refernce count
static void GLUQuadReleaseCount(GLU::QuadRef pQuad)
{
    if(pQuad != NULL)
    {
        pQuad->mnRefCount--;
        
        if(pQuad->mnRefCount == 0)
        {
            GLUQuadDelete(pQuad);
        } // if
    } // if
} // GLUQuadReleaseCount

#pragma mark -
#pragma mark Private - Utilities - Acquire

static bool GLUQuadAcquireBuffer(GLU::QuadRef pQuad)
{
    if(!pQuad->mnBID)
    {
        glGenBuffers(1, &pQuad->mnBID);
        
        if(pQuad->mnBID)
        {
            glBindBuffer(pQuad->mnTarget, pQuad->mnBID);
            {
                glBufferData(pQuad->mnTarget, pQuad->mnCapacity, NULL, pQuad->mnUsage);
                
                glBufferSubData(pQuad->mnTarget, 0, pQuad->mnSize, pQuad->m_Vertices);
                glBufferSubData(pQuad->mnTarget, pQuad->mnSize, pQuad->mnSize, pQuad->m_TexCoords);
            }
            glBindBuffer(pQuad->mnTarget, 0);
        } // if
    } // if
    
    return  pQuad->mnBID != 0;
} // GLUQuadAcquireBuffer

#pragma mark -
#pragma mark Private - Utilities - Map/Unmap

static bool GLUQuadMapBuffer(GLU::QuadRef pQuad)
{
    if(pQuad->mbResize && !pQuad->mbMapped)
    {
        glBindBuffer(pQuad->mnTarget,
                     pQuad->mnBID);
        
        glBufferData(pQuad->mnTarget,
                     pQuad->mnCapacity,
                     NULL,
                     pQuad->mnUsage);
        
        pQuad->mpData = (GLfloat *)glMapBuffer(pQuad->mnTarget, GL_WRITE_ONLY);
        
        pQuad->mbMapped = pQuad->mpData != NULL;
    } // if
    
    return pQuad->mbMapped;
} // GLUQuadMapBuffer

static bool GLUQuadUnmapBuffer(GLU::QuadRef pQuad)
{
    bool bSuccess = pQuad->mbResize && pQuad->mbMapped;
    
    if(bSuccess)
    {
        bSuccess = glUnmapBuffer(pQuad->mnTarget);
        
        glBindBuffer(pQuad->mnTarget, 0);
        
        pQuad->mbMapped = false;
    } // if
    
    return bSuccess;
} // GLUQuadUnmapBuffer

#pragma mark -
#pragma mark Private - Utilities - Update

static void GLUQuadUpdateBuffer(GLU::QuadRef pQuad)
{
    glBindBuffer(pQuad->mnTarget, pQuad->mnBID);
    
    if(pQuad->mbResize)
    {
        glBufferSubData(pQuad->mnTarget, 0, pQuad->mnSize, pQuad->m_Vertices);
    } // if
    
    if(pQuad->mbUpdate)
    {
        glBufferSubData(pQuad->mnTarget, pQuad->mnSize, pQuad->mnSize, pQuad->m_TexCoords);
    } // if
} // GLUQuadUpdateBuffer

#pragma mark -
#pragma mark Private - Utilities - Draw

static void GLUQuadDrawArrays(GLU::QuadRef pQuad)
{
	glBindBuffer(pQuad->mnTarget, pQuad->mnBID);
    {
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glEnableClientState(GL_VERTEX_ARRAY);
        
        glVertexPointer(2, pQuad->mnType, pQuad->mnStride, BUFFER_OFFSET(0));
        glTexCoordPointer(2, pQuad->mnType, pQuad->mnStride, BUFFER_OFFSET(pQuad->mnSize));
        
        glDrawArrays(pQuad->mnMode, 0, pQuad->mnCount);
        
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
	glBindBuffer(pQuad->mnTarget, 0);
} // GLUQuadDrawArrays

#pragma mark -
#pragma mark Public - Constructor

// Construct a quad with a usage enumerated type
GLU::QuadRef GLU::QuadCreate(const GLenum& nUsage)
{
    return GLUQuadCreateWithUsage(nUsage);
} // GLUQuadCreate

#pragma mark -
#pragma mark Public - Reference Counting

// Retain a quad
GLU::QuadRef GLU::QuadRetain(GLU::QuadRef pQuad)
{
    return GLUQuadRetainCount(pQuad);
} // GLUQuadRetain

// Release a quad
void GLU::QuadRelease(GLU::QuadRef pQuad)
{
    GLUQuadReleaseCount(pQuad);
} // GLUQuadRelease

#pragma mark -
#pragma mark Public - Accessors

// Is the quad finalized?
bool GLU::QuadIsFinalized(GLU::QuadRef pQuad)
{
    return (pQuad != NULL) ? pQuad->mnBID != 0 : false;
} // GLUQuadIsFinalized

// Set the quad to be inverted
bool GLU::QuadSetIsInverted(const bool& bIsInverted,
                          GLU::QuadRef pQuad)
{
    return (pQuad != NULL) ? GLUQuadSetTextCoords(bIsInverted, pQuad) : false;
} // GLUQuadSetIsInverted

// Set the quad bounds
bool GLU::QuadSetBounds(const CGRect& bounds,
                      GLU::QuadRef pQuad)
{
    return (pQuad != NULL) ? GLUQuadSetVertices(bounds, pQuad) : false;
} // GLUQuadSetBounds

#pragma mark -
#pragma mark Public - Updating

// Finalize and acquire a vbo for the quad
bool GLU::QuadFinalize(GLU::QuadRef pQuad)
{
    return (pQuad != NULL) ? GLUQuadAcquireBuffer(pQuad) : false;
} // GLUQuadFinalize

// Update the quad if either the bounds changed or
// the inverted flag was changed
void GLU::QuadUpdate(GLU::QuadRef pQuad)
{
    if(pQuad != NULL)
    {
        GLUQuadUpdateBuffer(pQuad);
    } // if
} // GLUQuadUpdate

#pragma mark -
#pragma mark Public - Map/Unmap

// Map to get the base address of the quad's vbo
bool GLU::QuadMap(GLU::QuadRef pQuad)
{
    return (pQuad != NULL) ? GLUQuadMapBuffer(pQuad) : false;
} // GLUQuadMap

// Unmap to invalidate the base address of the quad's vbo
bool GLU::QuadUnmap(GLU::QuadRef pQuad)
{
    return (pQuad != NULL) ? GLUQuadUnmapBuffer(pQuad) : false;
} // GLUQuadUnmap

// Get the base address of the quad's vbo
GLfloat *GLU::QuadBuffer(GLU::QuadRef pQuad)
{
    return (pQuad != NULL) ? pQuad->mpData : NULL;
} // GLUQuadBuffer

#pragma mark -
#pragma mark Public - Drawing

// Draw the quad
void GLU::QuadDraw(GLU::QuadRef pQuad)
{
    if(pQuad != NULL)
    {
        GLUQuadDrawArrays(pQuad);
    } // if
} // GLUQuadDraw
