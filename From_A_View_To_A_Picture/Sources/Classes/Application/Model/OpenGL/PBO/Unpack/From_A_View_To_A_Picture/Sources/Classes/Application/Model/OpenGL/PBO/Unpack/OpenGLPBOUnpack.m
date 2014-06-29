//---------------------------------------------------------------------------
//
//	File: OpenGLPBOUnpackKit.m
//
//  Abstract: Utility toolkit for handling (unpack) PBOs
//
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
//  Computer, Inc. ("Apple") in consideration of your agreement to the
//  following terms, and your use, installation, modification or
//  redistribution of this Apple software constitutes acceptance of these
//  terms.  If you do not agree with these terms, please do not use,
//  install, modify or redistribute this Apple software.
//
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software.
//  Neither the name, trademarks, service marks or logos of Apple Computer,
//  Inc. may be used to endorse or promote products derived from the Apple
//  Software without specific prior written permission from Apple.  Except
//  as expressly stated in this notice, no other rights or licenses, express
//  or implied, are granted by Apple herein, including but not limited to
//  any patent rights that may be infringed by your derivative works or by
//  other works in which the Apple Software may be incorporated.
//
//  The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  Copyright (c) 2008-2009, 2012 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#import "OpenGLImageBuffer.h"
#import "OpenGLTextureSourceTypes.h"
#import "OpenGLPBOUnpack.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structures

//---------------------------------------------------------------------------

struct OpenGLTexture
{
	GLuint  name;				// texture id
	GLint   hint;				// texture hint
	GLint   level;				// level-of-detail	number
	GLint   border;				// width of the border, either 0  or 1
	GLint   xoffset;			// x offset for texture copy
	GLint   yoffset;			// y offset for texture copy
	GLenum  target;				// e.g., texture 2D or texture rectangle
	GLenum  format;				// format
	GLenum  internalFormat;		// internal format
	GLenum  type;				// OpenGL specific type
};

typedef struct OpenGLTexture  OpenGLTexture;

//---------------------------------------------------------------------------

struct OpenGLPBO
{
	GLuint  name;		// PBO id
	GLenum  target;		// e.g., pixel pack or unpack
	GLenum  usage;		// e.g., stream draw
	GLenum  access;		// e.g., read, write, or both
};

typedef struct OpenGLPBO  OpenGLPBO;

//---------------------------------------------------------------------------

struct OpenGLPBOUnpackData
{
	OpenGLImageBuffer  buffer;	// An image buffer
	OpenGLTexture      texture;	// OpenGL texture mpPBOUnpack
	OpenGLPBO          pbo;		// OpenGL PBO mpPBOUnpack
};

typedef struct OpenGLPBOUnpackData   OpenGLPBOUnpackData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation OpenGLPBOUnpack

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark PBO Unpack Initializations

//---------------------------------------------------------------------------

- (void) initOpenGLTexture
{
	mpPBOUnpack->texture.name           = 0;
	mpPBOUnpack->texture.level          = 0;
	mpPBOUnpack->texture.border         = 0;
	mpPBOUnpack->texture.xoffset        = 0;
	mpPBOUnpack->texture.yoffset        = 0;
	mpPBOUnpack->texture.hint           = GL_STORAGE_PRIVATE_APPLE;
	mpPBOUnpack->texture.target         = GL_TEXTURE_RECTANGLE_ARB;
	mpPBOUnpack->texture.format         = kTextureSourceFormat;
	mpPBOUnpack->texture.type           = kTextureSourceType;
	mpPBOUnpack->texture.internalFormat = kTextureInternalFormat;
} // initOpenGLTexture

//---------------------------------------------------------------------------

- (void) initOpenGLImageBuffer:(const NSSize *)theImageSize
{
	mpPBOUnpack->buffer.samplesPerPixel = kTextureMaxSPP;
	mpPBOUnpack->buffer.width           = (GLuint)theImageSize->width;
	mpPBOUnpack->buffer.height          = (GLuint)theImageSize->height;
	mpPBOUnpack->buffer.rowBytes        = mpPBOUnpack->buffer.width  * mpPBOUnpack->buffer.samplesPerPixel;
	mpPBOUnpack->buffer.size            = mpPBOUnpack->buffer.height * mpPBOUnpack->buffer.rowBytes;
	mpPBOUnpack->buffer.data            = NULL;
} // initOpenGLImageBuffer

//---------------------------------------------------------------------------

- (void) newOpenGLTexture
{
	glGenTextures(1, &mpPBOUnpack->texture.name);
	
	glEnable(mpPBOUnpack->texture.target);
	
	glTextureRangeAPPLE(mpPBOUnpack->texture.target, 0, NULL);
	glTextureRangeAPPLE(GL_TEXTURE_2D, 0, NULL);
	
	glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_FALSE);
	
	glBindTexture(mpPBOUnpack->texture.target,
				  mpPBOUnpack->texture.name);
	
	glTexParameteri(mpPBOUnpack->texture.target, GL_TEXTURE_STORAGE_HINT_APPLE, mpPBOUnpack->texture.hint);
	glTexParameteri(mpPBOUnpack->texture.target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(mpPBOUnpack->texture.target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(mpPBOUnpack->texture.target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(mpPBOUnpack->texture.target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glTexImage2D(mpPBOUnpack->texture.target,
				 mpPBOUnpack->texture.level,
				 mpPBOUnpack->texture.internalFormat,
				 mpPBOUnpack->buffer.width,
				 mpPBOUnpack->buffer.height,
				 mpPBOUnpack->texture.border,
				 mpPBOUnpack->texture.format,
				 mpPBOUnpack->texture.type,
				 NULL);
	
	glDisable(mpPBOUnpack->texture.target);
} // newOpenGLTexture

//---------------------------------------------------------------------------

- (void) newOpenGLPBOUnpack:(const GLint)thePBOUsage
{
	mpPBOUnpack->pbo.name   = 0;
	mpPBOUnpack->pbo.target = GL_PIXEL_UNPACK_BUFFER;
	mpPBOUnpack->pbo.usage  = thePBOUsage;
	mpPBOUnpack->pbo.access = GL_WRITE_ONLY;
	
	glGenBuffers(1, &mpPBOUnpack->pbo.name);
} // newOpenGLPBOUnpack

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated initializer

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

- (id) initPBOUnpackWithSize:(const NSSize *)thePBOSize
					   usage:(const GLint)thePBOUsage
{
	self = [super init];
	
	if( self )
	{
		mpPBOUnpack = (OpenGLPBOUnpackDataRef)calloc(1, sizeof(OpenGLPBOUnpackData));
		
		if( mpPBOUnpack != NULL )
		{
			[self initOpenGLTexture];
			[self initOpenGLImageBuffer:thePBOSize];
			
			[self newOpenGLTexture];
			[self newOpenGLPBOUnpack:thePBOUsage];
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL PBO Unpack - Failure Allocating Memory For Attributes!" );
		} // else
	} // self
	
	return  self;
} // initPBOUnpackWithSize

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Dealloc all the Resources

//---------------------------------------------------------------------------

- (void) cleanUpOpenGLBuffer
{
	if( mpPBOUnpack->pbo.name )
	{
		glDeleteBuffers( 1, &mpPBOUnpack->pbo.name );
	} // if
} // cleanUpOpenGLBuffer

//---------------------------------------------------------------------------

- (void) cleanUpOpenGLTexture
{
	if( mpPBOUnpack->texture.name )
	{
		glDeleteTextures( 1, &mpPBOUnpack->texture.name );
	} // if
} // cleanUpOpenGLTexture

//---------------------------------------------------------------------------

- (void) cleanUpPBOUnpack
{
	if( mpPBOUnpack != NULL )
	{
		[self cleanUpOpenGLBuffer];
		[self cleanUpOpenGLTexture];
		
		free( mpPBOUnpack );
		
		mpPBOUnpack = NULL;
	} // if
} // cleanUpPBOUnpack

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpPBOUnpack];
	
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark PBO Update

//---------------------------------------------------------------------------

- (void) update:(const GLvoid *)theImage
{
	// Bind the texture and PBO
	
	glBindTexture(mpPBOUnpack->texture.target,
				  mpPBOUnpack->texture.name);
	
	glBindBuffer(mpPBOUnpack->pbo.target,
				 mpPBOUnpack->pbo.name );
	
	// If GPU is working with a buffer, glMapBuffer results in a sync
	// issue and will stall the GPU pipeline until such time the current
	// job is processed. To avoid stalling the pipeline, one should call
	// the API glBufferData with a NULL pointer before calling the API,
	// glMapBuffer. If you do so then the previous data in a PBO will
	// be discarded and glMapBuffer returns a new allocated pointer
	// immediately even thought the GPU is still processing the previous
	// data.
	
	glBufferData(mpPBOUnpack->pbo.target,
				 mpPBOUnpack->buffer.size,
				 NULL,
				 mpPBOUnpack->pbo.usage );
	
	mpPBOUnpack->buffer.data = glMapBuffer(mpPBOUnpack->pbo.target,
										   mpPBOUnpack->pbo.access);
	
	// Copy the pixel buffer to pbo
	
	if( mpPBOUnpack->buffer.data != NULL )
	{
		memcpy(mpPBOUnpack->buffer.data,
			   theImage,
			   mpPBOUnpack->buffer.size);
	} // if
	
	// Release pointer to the mapping buffer
	
	glUnmapBuffer(mpPBOUnpack->pbo.target);
	
	// Use offset instead of pointer to copy pixels from PBO
	// to texture.
	
	glTexSubImage2D(mpPBOUnpack->texture.target,
					mpPBOUnpack->texture.level,
					mpPBOUnpack->texture.xoffset,
					mpPBOUnpack->texture.yoffset,
					mpPBOUnpack->buffer.width,
					mpPBOUnpack->buffer.height,
					mpPBOUnpack->texture.format,
					mpPBOUnpack->texture.type,
					NULL);
	
	// At this stage, it is good idea to release a PBO
	// (with ID 0) after use. Once bound to ID 0, all
	// pixel operations default to normal behavior.
	
	glBindBuffer(mpPBOUnpack->pbo.target, 0);
} // updatePBO

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark PBO Setters

//---------------------------------------------------------------------------

- (GLvoid) setUsage:(const GLenum)thePBOUsage
{
	mpPBOUnpack->pbo.usage = thePBOUsage;
} // setUsage

//---------------------------------------------------------------------------

- (GLvoid) setSize:(const NSSize *)thePBOSize
{
	GLuint width  = (GLuint)thePBOSize->width;
	GLuint height = (GLuint)thePBOSize->height;
	
	if(		( width  != mpPBOUnpack->buffer.width  )
	   ||	( height != mpPBOUnpack->buffer.height ) )
	{
		[self cleanUpOpenGLBuffer];
		[self cleanUpOpenGLTexture];
		
		[self initOpenGLTexture];
		[self initOpenGLImageBuffer:thePBOSize];
		
		[self newOpenGLTexture];
		[self newOpenGLPBOUnpack:mpPBOUnpack->pbo.usage];
	} // if
} // setSize

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark PBO Getters

//---------------------------------------------------------------------------

- (GLenum) target
{
	return( mpPBOUnpack->texture.target );
} // target

//---------------------------------------------------------------------------

- (GLuint) name
{
	return( mpPBOUnpack->texture.name );
} // name

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
