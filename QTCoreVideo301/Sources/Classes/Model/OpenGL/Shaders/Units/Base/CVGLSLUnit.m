/*
     File: CVGLSLUnit.m
 Abstract: 
 A utility toolkit for managing shaders along with their uniforms for CoreVideo opaque texture references.
 
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
#import "CVGLSLUnit.h"

#pragma mark -
#pragma mark Private - Data Structure

struct CVGLSLUnitQuad
{
    GLfloat   m_TexCoords[8];
    GLfloat   m_Vertices[8];
    GLQuad   *mpQuad;
};

typedef struct CVGLSLUnitQuad CVGLSLUnitQuad;

struct CVGLSLUnitData
{
    GLuint            mnSize;
    CVGLSLUnitQuad    m_Quad[2];
    CVGLSLUnit       *mpSelf;
};

typedef struct CVGLSLUnitData CVGLSLUnitData;

#pragma mark -
#pragma mark Private - Utilities - Constructor

static CVGLSLUnitDataRef CVGLSLUnitCreate(CVGLSLUnit *pSelf)
{
    CVGLSLUnitDataRef  pCVUnit = NULL;
    
    if(pSelf)
    {
        pCVUnit = (CVGLSLUnitDataRef)calloc(1, sizeof(CVGLSLUnitData));
        
        if(pCVUnit != NULL)
        {
            pCVUnit->mpSelf = pSelf;
        } // if
    } // if
    
	return pCVUnit;
} // CVGLSLUnitCreate

#pragma mark -
#pragma mark Private - Utilities - Destructors

static inline void CVGLSLUnitDeleteQuatAtIndex(const GLuint nIndex,
                                               CVGLSLUnitDataRef pCVUnit)
{
	if(pCVUnit->m_Quad[nIndex].mpQuad)
	{
		[pCVUnit->m_Quad[nIndex].mpQuad release];
		
		pCVUnit->m_Quad[nIndex].mpQuad = nil;
	} // if
} // CVGLSLUnitDeleteQuatAtIndex

static void CVGLSLUnitDelete(CVGLSLUnitDataRef pCVUnit)
{
    if(pCVUnit != NULL)
    {
        CVGLSLUnitDeleteQuatAtIndex(0, pCVUnit);
        CVGLSLUnitDeleteQuatAtIndex(1, pCVUnit);
        
        free(pCVUnit);
        
        pCVUnit = NULL;
    } // if
} // CVGLSLUnitDelete

#pragma mark -
#pragma mark Private - Utilities - Quads

static inline BOOL CVGLSLUnitCreateQuadAtIndex(const GLuint nIndex,
                                               const NSSize * const pSize,
                                               CVGLSLUnitDataRef pCVUnit)
{
    BOOL bSuccess = !pCVUnit->mnSize;
    
    if(bSuccess)
    {
        GLQuad *pQuad = [[GLQuad alloc] initQuadWithSize:pSize
                                                        target:GL_TEXTURE_RECTANGLE_ARB];
        
        bSuccess = pQuad != nil;
        
        if(bSuccess)
        {
            CVGLSLUnitDeleteQuatAtIndex(nIndex,pCVUnit);
            
            pCVUnit->m_Quad[nIndex].mpQuad = pQuad;
        } // if
    } // if
    
    return bSuccess;
} // CVGLSLUnitCreateQuadAtIndex

static inline BOOL CVGLSLUnitCreateQuads(const NSSize * const pSize,
                                         CVGLSLUnitDataRef pCVUnit)
{
    BOOL bSuccess =     CVGLSLUnitCreateQuadAtIndex(0, pSize, pCVUnit)
                    &&  CVGLSLUnitCreateQuadAtIndex(1, pSize, pCVUnit);
    
    if(bSuccess)
    {
        pCVUnit->mnSize = [pCVUnit->m_Quad[0].mpQuad size];
    } // if
    
    return bSuccess;
} // CVGLSLUnitCreateQuads

static inline BOOL CVGLSLUnitAcquireQuads(CVGLSLUnitDataRef pCVUnit)
{
    BOOL bSuccess = [pCVUnit->m_Quad[0].mpQuad acquire];
    
    return bSuccess && [pCVUnit->m_Quad[1].mpQuad acquire];
} // CVGLSLUnitAcquireQuads

#pragma mark -
#pragma mark Private - Utilities - Accessors

static void CVGLSLUnitSetTexCoordsAtIndex(const GLuint nIndex,
                                          CVGLSLUnitDataRef pCVUnit)
{
    GLfloat nWidth  = [pCVUnit->m_Quad[nIndex].mpQuad width];
    GLfloat nHeight = [pCVUnit->m_Quad[nIndex].mpQuad height];
    
    pCVUnit->m_Quad[nIndex].m_TexCoords[0] = 0.0f;
    pCVUnit->m_Quad[nIndex].m_TexCoords[1] = 0.0f;
    pCVUnit->m_Quad[nIndex].m_TexCoords[2] = 0.0f;
    pCVUnit->m_Quad[nIndex].m_TexCoords[3] = nHeight;
    pCVUnit->m_Quad[nIndex].m_TexCoords[4] = nWidth;
    pCVUnit->m_Quad[nIndex].m_TexCoords[5] = nHeight;
    pCVUnit->m_Quad[nIndex].m_TexCoords[6] = nWidth;
    pCVUnit->m_Quad[nIndex].m_TexCoords[7] = 0.0f;
    
    [pCVUnit->m_Quad[nIndex].mpQuad setTexCoords:pCVUnit->m_Quad[nIndex].m_TexCoords];
} // CVGLSLUnitSetTexCoordsAtIndex

static inline void CVGLSLUnitSetTexCoords(CVGLSLUnitDataRef pCVUnit)
{
    CVGLSLUnitSetTexCoordsAtIndex(0, pCVUnit);
    CVGLSLUnitSetTexCoordsAtIndex(1, pCVUnit);
} // CVGLSLUnitSetTexCoords

static void CVGLSLUnitSetVerticesAtIndex(const GLuint nIndex,
                                         CVGLSLUnitDataRef pCVUnit)
{
    if(nIndex)
    {
        pCVUnit->m_Quad[nIndex].m_Vertices[0] = -1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[1] =  1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[2] = -1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[3] = -1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[4] =  1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[5] = -1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[6] =  1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[7] =  1.0f;
    } // if
    else
    {
        pCVUnit->m_Quad[nIndex].m_Vertices[0] = -1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[1] = -1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[2] = -1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[3] =  1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[4] =  1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[5] =  1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[6] =  1.0f;
        pCVUnit->m_Quad[nIndex].m_Vertices[7] = -1.0f;
    } // if
    
    [pCVUnit->m_Quad[nIndex].mpQuad setVertices:pCVUnit->m_Quad[nIndex].m_Vertices];
} // CVGLSLUnitSetVerticesAtIndex

static inline void CVGLSLUnitSetVertices(CVGLSLUnitDataRef pCVUnit)
{
    CVGLSLUnitSetVerticesAtIndex(0, pCVUnit);
    CVGLSLUnitSetVerticesAtIndex(1, pCVUnit);
} // CVGLSLUnitSetVertices

#pragma mark -
#pragma mark Private - Utilities - Size

static inline BOOL CVGLSLUnitUpdateQuadAtIndex(const GLuint nIndex,
                                               const NSSize * const pSize,
                                               CVGLSLUnitDataRef pCVUnit)
{
    BOOL bSuccess = [pCVUnit->m_Quad[nIndex].mpQuad setSize:pSize];
    
    if(bSuccess)
    {
        CVGLSLUnitSetTexCoords(pCVUnit);
        CVGLSLUnitSetVertices(pCVUnit);
        
        bSuccess = [pCVUnit->m_Quad[nIndex].mpQuad update];
    } // if
    
    return bSuccess;
} // CVGLSLUnitUpdateQuadAtIndex

static BOOL CVGLSLUnitUpdateQuads(const NSSize * const pSize,
                                  CVGLSLUnitDataRef pCVUnit)
{
    BOOL bSuccess =     CVGLSLUnitUpdateQuadAtIndex(0, pSize, pCVUnit)
                    &&  CVGLSLUnitUpdateQuadAtIndex(1, pSize, pCVUnit);
    
    if(bSuccess)
    {
        pCVUnit->mnSize = [pCVUnit->m_Quad[0].mpQuad size];
    } // if

    return bSuccess;
} // CVGLSLUnitUpdate

static inline BOOL CVGLSLUnitSetSize(const NSSize * const pSize,
                                     CVGLSLUnitDataRef pCVUnit)
{
    BOOL bSuccess = CVGLSLUnitCreateQuads(pSize, pCVUnit);
    
    if(bSuccess)
    {
        CVGLSLUnitSetTexCoords(pCVUnit);
        CVGLSLUnitSetVertices(pCVUnit);
        
        bSuccess = CVGLSLUnitAcquireQuads(pCVUnit);
    } // if
    else
    {
        bSuccess = CVGLSLUnitUpdateQuads(pSize, pCVUnit);
    } // else
    
    return bSuccess;
} // CVGLSLUnitSetSize

#pragma mark -
#pragma mark Private - Utilities - Display

static inline void CVGLSLUnitDisplayQuadAtIndex(const GLuint nIndex,
                                                CVGLSLUnitDataRef pCVUnit)
{
    [pCVUnit->m_Quad[nIndex].mpQuad display];
} // CVGLSLUnitDisplayQuadAtIndex

static void CVGLSLUnitDisplay(CVOpenGLTextureRef pVideoFrame,
                              CVGLSLUnitDataRef pCVUnit)
{
    // Get the texture target
    GLenum target = CVOpenGLTextureGetTarget(pVideoFrame);
    
    // Enable texture target
    glEnable(target);
    
    // Get the texture target id
    GLuint name = CVOpenGLTextureGetName(pVideoFrame);
    
    // Bind the texture
    glBindTexture(target, name);
    
    // Is texture flipped?
    GLuint index = CVOpenGLTextureIsFlipped(pVideoFrame);
    
    // Bind and sisplay the quad
    CVGLSLUnitDisplayQuadAtIndex(index,pCVUnit);
} // CVGLSLUnitDisplay

static void CVGLSLUnitExcute(CVOpenGLTextureRef pVideoFrame,
                             CVGLSLUnitDataRef pCVUnit)
{
	[pCVUnit->mpSelf enable];
	{
        CVGLSLUnitDisplay(pVideoFrame, pCVUnit);
    }
	[pCVUnit->mpSelf disable];
} // CVGLSLUnitExcute

static inline void CVGLSLUnitDisplayWithUniforms(CVOpenGLTextureRef pVideoFrame,
                                                 NSDictionary *pUniforms,
                                                 CVGLSLUnitDataRef pCVUnit)
{
    [pCVUnit->mpSelf uniforms:pUniforms];
    
    CVGLSLUnitDisplay(pVideoFrame, pCVUnit);
} // CVGLSLUnitDisplayWithUniforms

static void CVGLSLUnitExcuteWithUniforms(CVOpenGLTextureRef pVideoFrame,
                                         NSDictionary *pUniforms,
                                         CVGLSLUnitDataRef pCVUnit)
{
	[pCVUnit->mpSelf enable];
	{
        CVGLSLUnitDisplayWithUniforms(pVideoFrame, pUniforms, pCVUnit);
    }
	[pCVUnit->mpSelf disable];
} // CVGLSLUnitExcuteWithUniforms

#pragma mark -

@implementation CVGLSLUnit

#pragma mark -
#pragma mark Public - initializer

- (id) init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // init

- (id) initWithDictionary:(NSDictionary *)theDicitionary
{
	self = [super initWithDictionary:theDicitionary];
    
    if(self)
    {
        mpCVUnit = CVGLSLUnitCreate(self);
    } // if
    
	return self;
} // initWithVertex

- (id) initWithShadersInAppBundle:(NSString *)theName
{
	self = [super initWithShadersInAppBundle:theName];
    
    if(self)
    {
        mpCVUnit = CVGLSLUnitCreate(self);
    } // if
    
	return self;
} // initWithShadersInAppBundle

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
	// Delete the data reference
    CVGLSLUnitDelete(mpCVUnit);
    
	// Dealloc the superclass
	[super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Accessors

// Set or update the quad size
- (BOOL) setSize:(const NSSize *)theSize
{
    return CVGLSLUnitSetSize(theSize, mpCVUnit);
} // setSize

#pragma mark -
#pragma mark Public - Utilities

// Display the video frame using the shader
- (void) display:(CVOpenGLTextureRef)theVideo
{
    CVGLSLUnitDisplay(theVideo, mpCVUnit);
} // display

// Display the video frame using the shader and uniforms
- (void) display:(CVOpenGLTextureRef)theVideo
        uniforms:(NSDictionary *)theUniforms
{
    CVGLSLUnitDisplayWithUniforms(theVideo, theUniforms, mpCVUnit);
} // display

- (void) execute:(CVOpenGLTextureRef)theVideo
{
    CVGLSLUnitExcute(theVideo, mpCVUnit);
} // execute

- (void) execute:(CVOpenGLTextureRef)theVideo
        uniforms:(NSDictionary *)theUniforms
{
    CVGLSLUnitExcuteWithUniforms(theVideo, theUniforms, mpCVUnit);
} // execute

@end

