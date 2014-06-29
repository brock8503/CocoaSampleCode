/*
     File: OpenGLFBO.m
 Abstract: 
 Utility class for managing FBOs.
 
  Version: 1.2
 
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

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#import "OpenGLImageBuffer.h"
#import "OpenGLTextureSourceTypes.h"
#import "OpenGLFBOStatus.h"
#import "OpenGLFBO.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structures

//---------------------------------------------------------------------------

struct OpenGLFBOTexture
{
	GLuint  name;				// texture named identifiers
	GLint   level;				// level-of-detail number
	GLint   border;				// width of the border, either 0 or 1
	GLenum  target;				// e.g., texture 2D or texture rectangle
	GLenum  hint;				// type of texture storage
	GLenum  format;				// format
	GLenum  internalFormat;		// internal format
	GLenum  type;				// OpenGL specific type
};

typedef struct OpenGLFBOTexture  OpenGLFBOTexture;

//---------------------------------------------------------------------------

struct OpenGLFBOViewport
{
	GLint    x;			// lower left x coordinate
	GLint    y;			// lower left y coordinate
	GLsizei  width;		// viewport height
	GLsizei  height;	// viewport width
};

typedef struct OpenGLFBOViewport  OpenGLFBOViewport;

//---------------------------------------------------------------------------

struct OpenGLFBOTransform
{
	GLdouble left;		// left vertical clipping plane
	GLdouble right;		// right vertical clipping plane
	GLdouble bottom;	// bottom horizontal clipping plane
	GLdouble top;		// top horizontal clipping plane
	GLdouble zNear;		// nearer depth clipping plane
	GLdouble zFar;		// farther depth clipping plane
};

typedef struct OpenGLFBOTransform  OpenGLFBOTransform;

//---------------------------------------------------------------------------

struct OpenGLFBOAttribs
{
	BOOL     isValid;		// Framebuffer status
	GLuint   name;			// Framebuffer object id
	GLenum   target;		// Framebuffer target
	GLenum   attachment;	// Color attachment "n" extension
	NSSize   size;			// Framebuffer size
};

typedef struct OpenGLFBOAttribs  OpenGLFBOAttribs;

//---------------------------------------------------------------------------

struct OpenGLFBOData
{
	OpenGLImageBuffer   m_Image;			// An image buffer
	OpenGLFBOTransform  m_Orthographic;		// mpFBO for orthographic projection
	OpenGLFBOViewport   m_Viewport;			// FBO viewport dimensions
	OpenGLFBOTexture    m_Texture;			// Texture bound to the framebuffer
	OpenGLFBOAttribs    m_Framebuffer;		// Framebuffer object
	OpenGLPBOPack      *mpPBOPack;			// PBO for authoring
};

typedef struct OpenGLFBOData  OpenGLFBOData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -- OpenGL Texture Initializations --

//---------------------------------------------------------------------------

static void OpenGLFBOInitImageBuffer(const NSSize *pSize,
									 OpenGLFBODataRef pFBO)
{
	pFBO->m_Image.samplesPerPixel = kTextureMaxSPP;
	pFBO->m_Image.width           = (GLuint)pSize->width;
	pFBO->m_Image.height          = (GLuint)pSize->height;
	pFBO->m_Image.rowBytes        = pFBO->m_Image.width  * pFBO->m_Image.samplesPerPixel;
	pFBO->m_Image.size            = pFBO->m_Image.height * pFBO->m_Image.rowBytes;
	pFBO->m_Image.data            = NULL;
} // OpenGLFBOInitImageBuffer

//---------------------------------------------------------------------------

static void OpenGLFBOInitTextureData(OpenGLFBODataRef pFBO)
{
	pFBO->m_Texture.name           = 0;
	pFBO->m_Texture.hint           = GL_STORAGE_PRIVATE_APPLE;
	pFBO->m_Texture.level          = 0;
	pFBO->m_Texture.border         = 0;
	pFBO->m_Texture.target         = GL_TEXTURE_RECTANGLE_ARB;
	pFBO->m_Texture.format         = kTextureSourceFormat;
	pFBO->m_Texture.type           = kTextureSourceType;
	pFBO->m_Texture.internalFormat = kTextureInternalFormat;
} // OpenGLFBOInitTextureData

//---------------------------------------------------------------------------

static void OpenGLFBOInitFramebufferAttribs(OpenGLFBODataRef  pFBO)
{
	pFBO->m_Framebuffer.name        = 0;
	pFBO->m_Framebuffer.target      = GL_FRAMEBUFFER;
	pFBO->m_Framebuffer.attachment  = GL_COLOR_ATTACHMENT0;
	pFBO->m_Framebuffer.isValid     = NO;
	pFBO->m_Framebuffer.size.width  = pFBO->m_Image.width;
	pFBO->m_Framebuffer.size.height = pFBO->m_Image.height;
} // OpenGLFBOInitFramebufferAttribs

//---------------------------------------------------------------------------

static void OpenGLFBOInitViewportAttribs( OpenGLFBODataRef pFBO )
{
	pFBO->m_Viewport.x      = 0;
	pFBO->m_Viewport.y      = 0;
	pFBO->m_Viewport.width  = pFBO->m_Image.width;
	pFBO->m_Viewport.height = pFBO->m_Image.height;
} // OpenGLFBOInitViewportAttribs

//---------------------------------------------------------------------------

static void OpenGLFBOInitOrtho2DAttribs( OpenGLFBODataRef pFBO )
{
	pFBO->m_Orthographic.left   =  0;
	pFBO->m_Orthographic.right  =  pFBO->m_Image.width;
	pFBO->m_Orthographic.bottom =  0;
	pFBO->m_Orthographic.top    =  pFBO->m_Image.height;
	pFBO->m_Orthographic.zNear  = -1.0;
	pFBO->m_Orthographic.zFar   =  1.0;
} // OpenGLFBOInitOrtho2DAttribs

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation OpenGLFBO

//---------------------------------------------------------------------------

#pragma mark -- Initialize an OpenGL FBO --

//---------------------------------------------------------------------------

- (void) initOpenGLFrameBuffer:(const NSSize *)theFBOSize
{
	OpenGLFBOInitImageBuffer( theFBOSize, mpFBO );
	OpenGLFBOInitTextureData( mpFBO );
	OpenGLFBOInitViewportAttribs( mpFBO );
	OpenGLFBOInitOrtho2DAttribs( mpFBO );
	OpenGLFBOInitFramebufferAttribs( mpFBO );
} // initOpenGLFrameBuffer

//---------------------------------------------------------------------------
//
// Initialize the fbo bound texture
//
//---------------------------------------------------------------------------

- (BOOL) newOpenGLTexture
{
	BOOL textureIsBuilt = NO;
	
	glDisable(GL_TEXTURE_2D);
	glEnable(mpFBO->m_Texture.target);
	
	glTextureRangeAPPLE(mpFBO->m_Texture.target, 0, NULL);
	glTextureRangeAPPLE(GL_TEXTURE_2D, 0, NULL);
	glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_FALSE);
	
	glGenTextures(1, &mpFBO->m_Texture.name);
	
	if( mpFBO->m_Texture.name )
	{
		glBindTexture(mpFBO->m_Texture.target,
					  mpFBO->m_Texture.name);
		
		glTexParameteri(mpFBO->m_Texture.target, GL_TEXTURE_STORAGE_HINT_APPLE, GL_STORAGE_PRIVATE_APPLE);
		glTexParameteri(mpFBO->m_Texture.target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(mpFBO->m_Texture.target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(mpFBO->m_Texture.target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(mpFBO->m_Texture.target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
		glTexImage2D(mpFBO->m_Texture.target,
					 mpFBO->m_Texture.level,
					 mpFBO->m_Texture.internalFormat,
					 mpFBO->m_Image.width,
					 mpFBO->m_Image.height,
					 mpFBO->m_Texture.border,
					 mpFBO->m_Texture.format,
					 mpFBO->m_Texture.type,
					 NULL);
		
		textureIsBuilt = YES;
	} // if
	
	glDisable(mpFBO->m_Texture.target);
	
	return( textureIsBuilt );
} // newOpenGLTexture

//---------------------------------------------------------------------------
//
// Initialize depth render buffer, bind to FBO before checking status
//
//---------------------------------------------------------------------------

- (void) newOpenGLFramebuffer
{
	glGenFramebuffers(1, &mpFBO->m_Framebuffer.name);
	
	if( mpFBO->m_Framebuffer.name )
	{
		glBindFramebuffer(mpFBO->m_Framebuffer.target,
						  mpFBO->m_Framebuffer.name);
		
		glFramebufferTexture2D(mpFBO->m_Framebuffer.target,
							   mpFBO->m_Framebuffer.attachment,
							   mpFBO->m_Texture.target,
							   mpFBO->m_Texture.name,
							   mpFBO->m_Texture.level);
		
		mpFBO->m_Framebuffer.isValid = [[OpenGLFBOStatus statusWithFBOTarget:mpFBO->m_Framebuffer.target
																		exit:NO] isComplete];
		
		glBindFramebuffer(mpFBO->m_Framebuffer.target, 0);
	} // if
} // newOpenGLFramebuffer

//---------------------------------------------------------------------------

- (void) newOpenGLFBO:(const NSSize *)theTextureSize
{
	[self initOpenGLFrameBuffer:theTextureSize];
	
	if( [self newOpenGLTexture] )
	{
		[self newOpenGLFramebuffer];
	} // if
} // newOpenGLFBO

//---------------------------------------------------------------------------
//
// Make sure client goes through designated initializer
//
//---------------------------------------------------------------------------

- (id) init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // init

//---------------------------------------------------------------------------
//
// Initialize on startup
//
//---------------------------------------------------------------------------

- (id) initFBOWithSize:(const NSSize *)theTextureSize
{
	self = [super init];
	
	if( self )
	{
		mpFBO = (OpenGLFBODataRef)calloc(1, sizeof(OpenGLFBOData));
		
		if( mpFBO != NULL )
		{
			mpFBO->mpPBOPack = [[OpenGLPBOPack alloc] initPBOPackWithSize:theTextureSize
																	usage:GL_DYNAMIC_READ
																	 mode:mpFBO->m_Framebuffer.attachment];
			
			[self newOpenGLFBO:theTextureSize];
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL FBO - Failure Allocating Memory For Attributes!" );
		} // else
	} // if
	
	return( self );
} // initFBOWithSize

//---------------------------------------------------------------------------

#pragma mark -- Cleanup all the Resources --

//---------------------------------------------------------------------------

- (void) releaseOpenGLFramebuffer
{
	if( mpFBO->m_Framebuffer.name )
	{
		glDeleteFramebuffers( 1, &mpFBO->m_Framebuffer.name );
	} // if
} // releaseOpenGLFramebuffer

//---------------------------------------------------------------------------

- (void) releaseOpenGLTexture
{
	if( mpFBO->m_Texture.name )
	{
		glDeleteTextures( 1, &mpFBO->m_Texture.name );
	} // if
} // releaseOpenGLTexture

//---------------------------------------------------------------------------

- (void) releaseOpenGLPBOPack
{
	if( mpFBO->mpPBOPack )
	{
		[mpFBO->mpPBOPack release];
		
		mpFBO->mpPBOPack = nil;
	} // if
} // releaseOpenGLPBOPack

//---------------------------------------------------------------------------

- (void) cleanUpFBO
{
	if( mpFBO != NULL )
	{
		[self releaseOpenGLPBOPack];
		[self releaseOpenGLFramebuffer];
		[self releaseOpenGLTexture];
		
		free( mpFBO );
		
		mpFBO = NULL;
	} // if
} // cleanUpFBO

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpFBO];
	
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -- Draw into FBO --

//---------------------------------------------------------------------------
//
// Reset the current viewport
//
//---------------------------------------------------------------------------

- (void) reset
{
	glViewport(mpFBO->m_Viewport.x,
			   mpFBO->m_Viewport.y,
			   mpFBO->m_Viewport.width,
			   mpFBO->m_Viewport.height );
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	glOrtho(mpFBO->m_Orthographic.left,
			mpFBO->m_Orthographic.right,
			mpFBO->m_Orthographic.bottom,
			mpFBO->m_Orthographic.top,
			mpFBO->m_Orthographic.zNear,
			mpFBO->m_Orthographic.zFar );
	
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glClear( GL_COLOR_BUFFER_BIT );
} // reset

//---------------------------------------------------------------------------
//
// Default rendering method. Must be implemented upon subclassing.
//
//---------------------------------------------------------------------------

- (void) render
{
	return;
} // render

//---------------------------------------------------------------------------
//
// Update the framebuffer by using the implementation of "render" method.
// If the shader method is not implemented, the default implementation wiil
// be used whereby, the second texture is simply bound to a quad.
//
//---------------------------------------------------------------------------

- (void) update
{
	// bind buffers and make attachment
	
	glBindFramebuffer(mpFBO->m_Framebuffer.target,
					  mpFBO->m_Framebuffer.name);
	
	// Write into the texture
	
	glDrawBuffer(mpFBO->m_Framebuffer.attachment);
	
	// reset the current viewport
	
	[self reset];
	
	// Render to texture
	
	[self render];
	
	// unbind buffer and detach
	
	glBindFramebuffer( mpFBO->m_Framebuffer.target, 0 );
} // update

//---------------------------------------------------------------------------

- (GLvoid *) readback
{
	// bind buffers and make attachment
	
	glBindFramebuffer(mpFBO->m_Framebuffer.target,
					  mpFBO->m_Framebuffer.name);
	
	// readback from the framebuffer using a pbo
	
	[mpFBO->mpPBOPack read:NO];
	
	// unbind buffer and detach
	
	glBindFramebuffer( mpFBO->m_Framebuffer.target, 0 );
	
	// Get the PBO's pixel data
	
	mpFBO->m_Image.data = [mpFBO->mpPBOPack data];
	
	return( mpFBO->m_Image.data );
} // readback

//---------------------------------------------------------------------------

- (void) copyToBuffer:(GLvoid *)theBuffer
{
	// bind buffers and make attachment
	
	glBindFramebuffer(mpFBO->m_Framebuffer.target,
					  mpFBO->m_Framebuffer.name);
	
	// copy pixels from the framebuffer using a pbo into
	// an allocated buffer
	
	[mpFBO->mpPBOPack copyToBuffer:theBuffer
						   flipped:NO];
	
	// unbind buffer and detach
	
	glBindFramebuffer( mpFBO->m_Framebuffer.target, 0 );
} // copyToBuffer

//---------------------------------------------------------------------------

- (void) copyToPixelBuffer:(CVPixelBufferRef)thePixelBuffer
{
	// bind buffers and make attachment
	
	glBindFramebuffer(mpFBO->m_Framebuffer.target,
					  mpFBO->m_Framebuffer.name);
	
	// copy pixels from the framebuffer using a pbo into
	// an allocated buffer
	
	[mpFBO->mpPBOPack copyToPixelBuffer:thePixelBuffer
								flipped:YES];
	
	// unbind buffer and detach
	
	glBindFramebuffer( mpFBO->m_Framebuffer.target, 0 );
} // copyToBuffer

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark FBO Accessors

//---------------------------------------------------------------------------

- (GLuint) texture
{
	return( mpFBO->m_Texture.name );
} // texture

//---------------------------------------------------------------------------

- (GLenum) target
{
	return( mpFBO->m_Texture.target );
} // target

//---------------------------------------------------------------------------

- (GLvoid) setSize:(const NSSize *)theTextureSize
{
	GLuint width  = (GLuint)theTextureSize->width;
	GLuint height = (GLuint)theTextureSize->height;
	
	if(		( width  != mpFBO->m_Image.width  )
	   ||	( height != mpFBO->m_Image.height ) )
	{
		[self releaseOpenGLFramebuffer];
		[self releaseOpenGLTexture];
		
		[mpFBO->mpPBOPack setSize:theTextureSize];
		
		[self newOpenGLFBO:theTextureSize];
	} // if
} // setSize

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
