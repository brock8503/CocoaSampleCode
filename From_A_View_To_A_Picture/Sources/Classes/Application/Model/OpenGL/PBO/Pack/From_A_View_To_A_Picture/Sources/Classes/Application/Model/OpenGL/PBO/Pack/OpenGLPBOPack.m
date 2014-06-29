//---------------------------------------------------------------------------
//
//	File: OpenGLPBOPackKit.m
//
//  Abstract: Utility toolkit for handling (pack) PBOs
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
//  Neither the buffer, trademarks, service marks or logos of Apple Computer,
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

#import "OpenGLTextureSourceTypes.h"
#import "OpenGLImageBuffer.h"
#import "OpenGLPBOPack.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Macros

//---------------------------------------------------------------------------

#define OpenGLPBOPackCopyTypes 2

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

enum ImageBufferType
{
	kSrcImage = 0,	// Index for source image
	kDstImage,		// Index for destination image
	kFinalImage		// Index for destination image
};

typedef enum ImageBufferType ImageBufferType;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Definitions - Function Pointers

//---------------------------------------------------------------------------

typedef void (*OpenGLPBOPackCopyFuncPtr)(OpenGLPBOPackDataRef mpPBOPack);

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Data Structures

//---------------------------------------------------------------------------

struct OpenGLPBOAttributes
{
	GLuint   buffer;			// PBO id
	GLint    x;					// X origin of the image
	GLint    y;					// Y origin of the image
	GLenum   format;			// Pixel format
	GLenum   type;				// Pixel type
	GLenum   target;			// Pixel pack
	GLenum   usage;				// static, dynamic, or stream
	GLenum   access;			// Read only permission
	GLenum   mode;				// The read buffer
	GLuint   size;				// Image size
	GLuint   width;				// Image width
	GLuint   height;			// Image height;
};

typedef struct OpenGLPBOAttributes  OpenGLPBOAttributes;

//---------------------------------------------------------------------------

struct OpenGLPBOPackData
{
	OpenGLImageBuffer    image[3];		// Source & destination images
	OpenGLPBOAttributes	 pbo;			// OpenGL PBO pack attributes
    
    OpenGLPBOPackCopyFuncPtr  glPBOPackCopy[OpenGLPBOPackCopyTypes];
};

typedef struct OpenGLPBOPackData   OpenGLPBOPackData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Copiers

//---------------------------------------------------------------------------
//
// Copy the pbo data into a pixel buffer
//
//---------------------------------------------------------------------------

static void OpenGLPBOPackCopyToBuffer(OpenGLPBOPackDataRef pPBOPack)
{
	memcpy(pPBOPack->image[kFinalImage].data,
		   pPBOPack->image[kSrcImage].data,
		   pPBOPack->image[kSrcImage].size);
} // OpenGLPBOPackCopyToBuffer

//---------------------------------------------------------------------------
//
// Copy memory from a source buffer to a destination buffer, fix
// alpha channel if desired, and vertical reflect.
//
//---------------------------------------------------------------------------

static void OpenGLPBOPackCopyToBufferVR(OpenGLPBOPackDataRef pPBOPack)
{
    uint32_t i;
    uint32_t iMax = pPBOPack->pbo.height;
    
    GLuint pixelsSrcRowBytes = pPBOPack->image[kSrcImage].width * pPBOPack->image[kSrcImage].samplesPerPixel;
    GLuint pixelsSrcSize     = pPBOPack->image[kSrcImage].size;
    GLuint pixelsSrcTopRow   = pixelsSrcSize - pixelsSrcRowBytes;
    GLuint pixelsDstRowBytes = pixelsSrcRowBytes;
    
    GLubyte *pixelsDst = (GLubyte *)pPBOPack->image[kFinalImage].data;
    
    const GLubyte *pixelsSrc = (const GLubyte *)(pPBOPack->image[kSrcImage].data + pixelsSrcTopRow);
    
    for( i = 0; i < iMax; ++i )
    {
        memcpy(pixelsDst, pixelsSrc, pixelsDstRowBytes);
        
        pixelsSrc -= pixelsSrcRowBytes;
        pixelsDst += pixelsDstRowBytes;
    } // for
} // OpenGLCopierVR

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

@implementation OpenGLPBOPack

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Initializers

//---------------------------------------------------------------------------

- (void) initImageBuffers:(const NSSize *)thePBOSize
{
	mpPBOPack->image[kSrcImage].samplesPerPixel = kTextureMaxSPP;
	mpPBOPack->image[kSrcImage].width           = (GLuint)thePBOSize->width;
	mpPBOPack->image[kSrcImage].height          = (GLuint)thePBOSize->height;
	mpPBOPack->image[kSrcImage].rowBytes        = mpPBOPack->image[kSrcImage].width  * mpPBOPack->image[kSrcImage].samplesPerPixel;
	mpPBOPack->image[kSrcImage].size            = mpPBOPack->image[kSrcImage].height * mpPBOPack->image[kSrcImage].rowBytes;
	mpPBOPack->image[kSrcImage].data            = NULL;
	
	mpPBOPack->image[kDstImage].samplesPerPixel = mpPBOPack->image[kSrcImage].samplesPerPixel;
	mpPBOPack->image[kDstImage].width           = mpPBOPack->image[kSrcImage].width;
	mpPBOPack->image[kDstImage].height          = mpPBOPack->image[kSrcImage].height;
	mpPBOPack->image[kDstImage].rowBytes        = mpPBOPack->image[kSrcImage].rowBytes;
	mpPBOPack->image[kDstImage].size            = mpPBOPack->image[kSrcImage].size;
	mpPBOPack->image[kDstImage].data            = NULL;
	
	mpPBOPack->image[kFinalImage].samplesPerPixel = mpPBOPack->image[kDstImage].samplesPerPixel;
	mpPBOPack->image[kFinalImage].width           = mpPBOPack->image[kDstImage].width;
	mpPBOPack->image[kFinalImage].height          = mpPBOPack->image[kDstImage].height;
	mpPBOPack->image[kFinalImage].rowBytes        = mpPBOPack->image[kDstImage].rowBytes;
	mpPBOPack->image[kFinalImage].size            = mpPBOPack->image[kDstImage].size;
	mpPBOPack->image[kFinalImage].data            = NULL;
} // initImageBuffers

//---------------------------------------------------------------------------
//
// Need a backing store for the final (destination) image only
//
//---------------------------------------------------------------------------

- (void) newImageBuffer
{
	mpPBOPack->image[kDstImage].data = realloc(mpPBOPack->image[kDstImage].data,
											   mpPBOPack->image[kDstImage].size);
	
	if( mpPBOPack->image[kDstImage].data == NULL )
	{
		NSLog( @">> ERROR: OpenGL PBO Pack - Failure Allocating Memory For the Image Backing Store!" );
	} // if
} // newImageBuffer

//---------------------------------------------------------------------------

- (void) initPixelPackBuffer:(const GLint)thePBOUsage
						mode:(const GLenum)thePBOMode
{
	mpPBOPack->pbo.buffer = 0;
	mpPBOPack->pbo.target = GL_PIXEL_PACK_BUFFER;
	mpPBOPack->pbo.usage  = thePBOUsage;
	mpPBOPack->pbo.access = GL_READ_ONLY;
	mpPBOPack->pbo.format = GL_BGRA;
	mpPBOPack->pbo.type   = GL_UNSIGNED_BYTE;
	mpPBOPack->pbo.mode   = thePBOMode;
	mpPBOPack->pbo.x      = 0;
	mpPBOPack->pbo.y      = 0;
	mpPBOPack->pbo.size   = mpPBOPack->image[kSrcImage].size;
	mpPBOPack->pbo.width  = mpPBOPack->image[kSrcImage].width;
	mpPBOPack->pbo.height = mpPBOPack->image[kSrcImage].height;
} // initPixelPackBuffer

//---------------------------------------------------------------------------

- (void) newPixelPackBuffer
{
	glGenBuffers(1, &mpPBOPack->pbo.buffer);
} // newPixelPackBuffer

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Designated initializer

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

- (id) initPBOPackWithSize:(const NSSize *)thePBOSize
					 usage:(const GLint)thePBOUsage
					  mode:(const GLenum)thePBOMode
{
	self = [super init];
	
	if( self )
	{
		mpPBOPack = (OpenGLPBOPackDataRef)calloc(1, sizeof(OpenGLPBOPackData));
		
		if( mpPBOPack != NULL )
		{
            mpPBOPack->glPBOPackCopy[0] = &OpenGLPBOPackCopyToBuffer,
            mpPBOPack->glPBOPackCopy[1] = &OpenGLPBOPackCopyToBufferVR,
            
			[self initImageBuffers:thePBOSize];
			
			[self initPixelPackBuffer:thePBOUsage
								 mode:thePBOMode];
			
			[self newImageBuffer];
			[self newPixelPackBuffer];
		} // if
		else
		{
			NSLog( @"OpenGL PBO Pack - Failure Allocating Memory For Attributes!" );
		} // else
	} // if
	
	return  self;
} // initPBOPackWithSize

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructors

//---------------------------------------------------------------------------

- (void) cleanUpPixelPackBuffer
{
	if( mpPBOPack->pbo.buffer )
	{
		glDeleteBuffers( 1, &mpPBOPack->pbo.buffer );
	} // if
} // cleanUpPBOPack

//---------------------------------------------------------------------------

- (void) cleanUpImageBuffer
{
	if( mpPBOPack->image[kDstImage].data != NULL )
	{
		free( mpPBOPack->image[kDstImage].data );
		
		mpPBOPack->image[kDstImage].data = NULL;
	} // if
} // cleanUpImageBuffer

//---------------------------------------------------------------------------

- (void) cleanUpPBOPack
{
	if( mpPBOPack != NULL )
	{
		[self cleanUpPixelPackBuffer];
		[self cleanUpImageBuffer];
		
		free( mpPBOPack );
		
		mpPBOPack = NULL;
	} // if
} // cleanUpPBOPack

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpPBOPack];
	
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - PBO

//---------------------------------------------------------------------------

- (void) pboCopyToBufferSync:(const GLuint)theCopyBufferType
{
	// Copy pixels from framebuffer to PBO by using offset instead of a
	// pointer. OpenGL should perform asynch DMA transfer, so that the
	// glReadPixels API returns immediately.
	
	glBindBuffer(mpPBOPack->pbo.target,
				 mpPBOPack->pbo.buffer);
	
	glBufferData(mpPBOPack->pbo.target,
				 mpPBOPack->pbo.size,
				 NULL,
				 mpPBOPack->pbo.usage);
	
	glReadPixels(mpPBOPack->pbo.x,
				 mpPBOPack->pbo.y,
				 mpPBOPack->pbo.width,
				 mpPBOPack->pbo.height,
				 mpPBOPack->pbo.format,
				 mpPBOPack->pbo.type,
				 NULL);
	
	// Map the PBO that contain framebuffer pixels before processing it
	
	mpPBOPack->image[kSrcImage].data = glMapBuffer(mpPBOPack->pbo.target,
                                                   mpPBOPack->pbo.access);
	
	if( mpPBOPack->image[kSrcImage].data != NULL )
	{
		mpPBOPack->glPBOPackCopy[theCopyBufferType](mpPBOPack);
	} // if
	
	// Release pointer to the mapping buffer
	
	glUnmapBuffer( mpPBOPack->pbo.target );
	
	// At this stage, it is good idea to release a PBO
	// (with ID 0) after use. Once bound to ID 0, all
	// pixel operations default to normal behavior.
	
	glBindBuffer( mpPBOPack->pbo.target, 0 );
} // read

//---------------------------------------------------------------------------

- (void) read:(const BOOL)theImageIsFlipped
{
	mpPBOPack->image[kFinalImage].data = mpPBOPack->image[kDstImage].data;
	
	[self pboCopyToBufferSync:theImageIsFlipped];
} // read

//---------------------------------------------------------------------------

- (void) copyToBuffer:(GLvoid *)theBuffer
			  flipped:(const BOOL)theImageIsFlipped
{
	if( theBuffer != NULL )
	{
		mpPBOPack->image[kFinalImage].data = theBuffer;
	} // if
	else
	{
		mpPBOPack->image[kFinalImage].data = mpPBOPack->image[kDstImage].data;
	} // else
	
	[self pboCopyToBufferSync:theImageIsFlipped];
} // copyToBuffer

//---------------------------------------------------------------------------

- (void) copyToPixelBuffer:(CVPixelBufferRef)thePixelBuffer
				   flipped:(const BOOL)theImageIsFlipped
{
	CVOptionFlags  lockFlags = 0;
	CVReturn       error     = CVPixelBufferLockBaseAddress(thePixelBuffer,lockFlags);
	
	if( error == kCVReturnSuccess )
	{
		mpPBOPack->image[kFinalImage].data = CVPixelBufferGetBaseAddress(thePixelBuffer);
		
		CVPixelBufferUnlockBaseAddress(thePixelBuffer,lockFlags);
		
		mpPBOPack->image[kFinalImage].width    = CVPixelBufferGetWidth(thePixelBuffer);
		mpPBOPack->image[kFinalImage].height   = CVPixelBufferGetHeight(thePixelBuffer);
		mpPBOPack->image[kFinalImage].rowBytes = CVPixelBufferGetBytesPerRow(thePixelBuffer);
		mpPBOPack->image[kFinalImage].size     = mpPBOPack->image[kFinalImage].rowBytes * mpPBOPack->image[kFinalImage].height;
		
		[self pboCopyToBufferSync:theImageIsFlipped];
	} // if
	else
	{
		mpPBOPack->image[kFinalImage].data = mpPBOPack->image[kDstImage].data;
		
		[self pboCopyToBufferSync:theImageIsFlipped];
	} // else
} // copyToPixelBuffer

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors - Setters

//---------------------------------------------------------------------------

- (GLvoid) setMode:(const GLenum)thePBOMode
{
	mpPBOPack->pbo.mode = thePBOMode;
} // setMode

//---------------------------------------------------------------------------

- (GLvoid) setUsage:(const GLenum)thePBOUsage
{
	mpPBOPack->pbo.usage = thePBOUsage;
} // setUsage

//---------------------------------------------------------------------------

- (GLvoid) setSize:(const NSSize *)thePBOSize
{
	GLuint width  = (GLuint)thePBOSize->width;
	GLuint height = (GLuint)thePBOSize->height;
	
	if(		( width  != mpPBOPack->image[kDstImage].width  )
	   ||	( height != mpPBOPack->image[kDstImage].height ) )
	{
		[self cleanUpPixelPackBuffer];
		
		[self initImageBuffers:thePBOSize];
		
		[self initPixelPackBuffer:mpPBOPack->pbo.usage
							 mode:mpPBOPack->pbo.mode];
		
		[self newImageBuffer];
		[self newPixelPackBuffer];
	} // if
} // setSize

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors - Getters

//---------------------------------------------------------------------------

- (GLvoid *) data
{
	return( mpPBOPack->image[kFinalImage].data );
} // data

//---------------------------------------------------------------------------

- (GLuint) size
{
	return( mpPBOPack->image[kFinalImage].size );
} // size

//---------------------------------------------------------------------------

- (GLuint) rowbytes
{
	return( mpPBOPack->image[kFinalImage].rowBytes );
} // size

//---------------------------------------------------------------------------

- (GLuint) samplesPerPixel
{
	return( mpPBOPack->image[kFinalImage].samplesPerPixel );
} // samplesPerPixel

//---------------------------------------------------------------------------

- (GLuint) width
{
	return( mpPBOPack->image[kFinalImage].width );
} // width

//---------------------------------------------------------------------------

- (GLuint) height
{
	return( mpPBOPack->image[kFinalImage].height );
} // height

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
