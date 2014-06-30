/*
     File: OpenGLTextureRange.m
 Abstract: 
 Utility toolkit for handling texture range (VRAM or AGP).
 
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
#import "OpenGLTextureRange.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Data Structures

//---------------------------------------------------------------------------

struct OpenGLTextureRangeData
{
	GLuint                name;				// texture id
	GLint                 level;			// level-of-detail	number
	GLint                 border;			// width of the border, either 0  or 1
	GLint                 xoffset;			// x offset for texture copy
	GLint                 yoffset;			// y offset for texture copy
	GLenum                target;			// e.g., texture 2D or texture rectangle
	GLenum                hint;				// type of texture storage
	GLenum                format;			// format
	GLenum                internalFormat;	// internal format
	GLenum                type;				// OpenGL specific type
	OpenGLImageBuffer     buffer;			// An image buffer
	NSMutableDictionary  *dictionary;		// Texture attributes
};

typedef struct OpenGLTextureRangeData  OpenGLTextureRangeData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Constructors

//---------------------------------------------------------------------------

static BOOL OpenGLTextureRangeCreateBuffer(const NSSize *pImageBufferSize,
										   OpenGLTextureRangeDataRef pTextureRange)
{
	if( pImageBufferSize != NULL )
	{
		pTextureRange->buffer.samplesPerPixel = kTextureMaxSPP;
		pTextureRange->buffer.width           = (GLuint)pImageBufferSize->width;
		pTextureRange->buffer.height          = (GLuint)pImageBufferSize->height;
		pTextureRange->buffer.rowBytes        = pTextureRange->buffer.width  * pTextureRange->buffer.samplesPerPixel;
		pTextureRange->buffer.size            = pTextureRange->buffer.height * pTextureRange->buffer.rowBytes;
		pTextureRange->buffer.data	          = calloc(pTextureRange->buffer.height, pTextureRange->buffer.rowBytes);
	} // if
	
	return pTextureRange->buffer.data != NULL;
} // OpenGLTextureRangeCreateBuffer

//---------------------------------------------------------------------------
//
// The texture range hints parameters can be either of:
//
//		texture->hint = GL_STORAGE_SHARED_APPLE;  AGP
//		texture->hint = GL_STORAGE_CACHED_APPLE;  VRAM
//
// For samples-per-pixel with OpenGL type GL_UNSIGNED_INT_8_8_8_8 or
// GL_UNSIGNED_INT_8_8_8_8_REV:
//
//		texture->buffer.samplesPerPixel = 4;
//
//---------------------------------------------------------------------------

static void OpenGLTextureRangeSetDefualts(const NSInteger nTextureHint,
										  const NSPoint *pTextureOffset,
										  OpenGLTextureRangeDataRef pTextureRange)
{
	pTextureRange->hint           = nTextureHint;
	pTextureRange->target         = GL_TEXTURE_RECTANGLE_ARB;
	pTextureRange->format         = kTextureSourceFormat;
	pTextureRange->type           = kTextureSourceType;
	pTextureRange->internalFormat = kTextureInternalFormat;
	
	if( pTextureOffset != NULL )
	{
		pTextureRange->xoffset = (GLint)pTextureOffset->x;
		pTextureRange->yoffset = (GLint)pTextureOffset->y;
	} // if
} // OpenGLTextureRangeSetDefualts

//---------------------------------------------------------------------------

static void OpenGLTextureRangeCreateImage2D(OpenGLTextureRangeDataRef pTextureRange)
{
	glGenTextures(1, &pTextureRange->name);
	
	if( pTextureRange->name )
	{
		glEnable(pTextureRange->target);
		{
			glTextureRangeAPPLE(pTextureRange->target,
								pTextureRange->buffer.size,
								pTextureRange->buffer.data);
			
			glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
			
			glBindTexture(pTextureRange->target,
						  pTextureRange->name);
			
			glTexParameteri(pTextureRange->target, GL_TEXTURE_STORAGE_HINT_APPLE, pTextureRange->hint);
			glTexParameteri(pTextureRange->target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			glTexParameteri(pTextureRange->target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			glTexParameteri(pTextureRange->target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
			glTexParameteri(pTextureRange->target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
			
			glTexImage2D(pTextureRange->target,
						 pTextureRange->level,
						 pTextureRange->internalFormat,
						 pTextureRange->buffer.width,
						 pTextureRange->buffer.height,
						 pTextureRange->border,
						 pTextureRange->format,
						 pTextureRange->type,
						 pTextureRange->buffer.data);
		}
		glDisable(pTextureRange->target);
	} // if
} // OpenGLTextureRangeCreateImage2D

//---------------------------------------------------------------------------

static void OpenGLTextureRangeCreateDictionary(OpenGLTextureRangeDataRef pTextureRange)
{
	NSArray *pKeys = [NSArray arrayWithObjects:
					  @"name",
					  @"hint",
					  @"level",
					  @"border",
					  @"xoffset",
					  @"yoffset",
					  @"target",
					  @"format",
					  @"type",
					  @"internalformat",
					  @"width",
					  @"height",
					  nil];
	
	NSArray *pObjects = [NSArray arrayWithObjects:
						 [NSNumber numberWithInt:pTextureRange->name ],
						 [NSNumber numberWithInt:pTextureRange->hint ],
						 [NSNumber numberWithInt:pTextureRange->level ],
						 [NSNumber numberWithInt:pTextureRange->border ],
						 [NSNumber numberWithInt:pTextureRange->xoffset ],
						 [NSNumber numberWithInt:pTextureRange->yoffset ],
						 [NSNumber numberWithInt:pTextureRange->target ],
						 [NSNumber numberWithInt:pTextureRange->format ],
						 [NSNumber numberWithInt:pTextureRange->type ],
						 [NSNumber numberWithInt:pTextureRange->internalFormat ],
						 [NSNumber numberWithInt:pTextureRange->buffer.width ],
						 [NSNumber numberWithInt:pTextureRange->buffer.height ],
						 nil];
	
	pTextureRange->dictionary =  [[NSMutableDictionary alloc ] initWithObjects:pObjects
																	   forKeys:pKeys];
} // OpenGLTextureRangeCreateDictionary

//---------------------------------------------------------------------------

static OpenGLTextureRangeDataRef OpenGLTextureRangeCreate(const NSRect *pBounds,
														  const GLint nHint)
{
	OpenGLTextureRangeDataRef pTextureRange = NULL;
	
	if( pBounds != NULL )
	{
		pTextureRange = (OpenGLTextureRangeDataRef)calloc(1, sizeof(OpenGLTextureRangeData) );
		
		if ( pTextureRange != NULL  )
		{
			OpenGLTextureRangeCreateBuffer(&pBounds->size, pTextureRange);
			OpenGLTextureRangeSetDefualts(nHint, &pBounds->origin, pTextureRange);
			OpenGLTextureRangeCreateImage2D(pTextureRange);
			OpenGLTextureRangeCreateDictionary(pTextureRange);
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL Texture Range - Failure Allocating Memory For Attributes!" );
		}  // else
	} // if
	
	return pTextureRange;
} // OpenGLTextureRangeCreate

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Destructors

//---------------------------------------------------------------------------

static inline void OpenGLTextureRangeDeleteImage2D(OpenGLTextureRangeDataRef pTextureRange)
{
	if ( pTextureRange->name )
	{
		glDeleteTextures(1, &pTextureRange->name);
	} // if
} // OpenGLTextureRangeDeleteImage2D

//---------------------------------------------------------------------------

static inline void OpenGLTextureRangeDeleteBuffer(OpenGLTextureRangeDataRef pTextureRange)
{
	if( pTextureRange->buffer.data != NULL )
	{
		free( pTextureRange->buffer.data );
		
		pTextureRange->buffer.data = NULL;
	} // if
} // OpenGLTextureRangeDeleteBuffer

//---------------------------------------------------------------------------

static inline void OpenGLTextureRangeReleaseDictionary(OpenGLTextureRangeDataRef pTextureRange)
{
	if( pTextureRange->dictionary )
	{
		[pTextureRange->dictionary release];
		
		pTextureRange->dictionary = nil;
	} // if
} // OpenGLTextureRangeReleaseDictionary

//---------------------------------------------------------------------------

static void OpenGLTextureRangeDelete(OpenGLTextureRangeDataRef pTextureRange)
{
	if( pTextureRange != NULL )
	{
		OpenGLTextureRangeDeleteImage2D(pTextureRange);
		OpenGLTextureRangeDeleteBuffer(pTextureRange);
		OpenGLTextureRangeReleaseDictionary(pTextureRange);
		
		free( pTextureRange );
		
		pTextureRange = NULL;
	} // if
} // OpenGLTextureRangeDelete

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Accessors

//---------------------------------------------------------------------------

static BOOL OpenGLTextureRangeSetSize(const NSRect *pBounds,
									  OpenGLTextureRangeDataRef pTextureRange)
{
	BOOL bSuccess = pBounds != NULL;

	if( bSuccess )
	{
		GLuint nWiidth = (GLuint)pBounds->size.width;
		
		BOOL bWidthChanged = nWiidth != pTextureRange->buffer.width;
		
		if( bWidthChanged )
		{
			pTextureRange->buffer.width = nWiidth;

			[pTextureRange->dictionary setObject:[NSNumber numberWithInt:pTextureRange->buffer.width]
										  forKey:@"width"];
		} // if
		
		GLuint nHeight = (GLuint)pBounds->size.height;
		
		BOOL bHeightChanged = nHeight != pTextureRange->buffer.height;
		
		if( bHeightChanged )
		{
			pTextureRange->buffer.height = nHeight;

			[pTextureRange->dictionary setObject:[NSNumber numberWithInt:pTextureRange->buffer.height]
										  forKey:@"height"];
		} // if
		
		bSuccess = bWidthChanged || bHeightChanged;
	}  //if
	
	return bSuccess;
} // OpenGLTextureRangeSetSize

//---------------------------------------------------------------------------

static void OpenGLTextureRangeSetOffsets(const NSPoint *pOffsets,
										 OpenGLTextureRangeDataRef pTextureRange)
{
	GLint nOffsetX = (GLint)pOffsets->x;
	
	if( nOffsetX != pTextureRange->xoffset )
	{
		pTextureRange->xoffset = nOffsetX;
		
		[pTextureRange->dictionary setObject:[NSNumber numberWithInt:pTextureRange->xoffset]
									  forKey:@"xoffset"];
	} // if
	
	GLint nOffsetY = (GLint)pOffsets->y;
	
	if( nOffsetY != pTextureRange->yoffset )
	{
		pTextureRange->yoffset = nOffsetY;
		
		[pTextureRange->dictionary setObject:[NSNumber numberWithInt:pTextureRange->yoffset]
									  forKey:@"yoffset"];
	} // if
} // OpenGLTextureRangeSetOffsets

//---------------------------------------------------------------------------

static BOOL OpenGLTextureRangeSetBuffer(OpenGLTextureRangeDataRef pTextureRange)
{
	pTextureRange->buffer.rowBytes = pTextureRange->buffer.width  * pTextureRange->buffer.samplesPerPixel;
	pTextureRange->buffer.size     = pTextureRange->buffer.height * pTextureRange->buffer.rowBytes;
	
	if( pTextureRange->buffer.size > 0 )
	{
		pTextureRange->buffer.data = realloc(pTextureRange->buffer.data, pTextureRange->buffer.size);
	} // if
	
	return pTextureRange->buffer.data != NULL;
} // OpenGLTextureRangeSetBuffer

//---------------------------------------------------------------------------

static inline void OpenGLTextureRangeSetName(OpenGLTextureRangeDataRef pTextureRange)
{
	[pTextureRange->dictionary setObject:[NSNumber numberWithInt:pTextureRange->name]
								  forKey:@"name"];
} // OpenGLTextureRangeSetDictionary

//---------------------------------------------------------------------------

static BOOL OpenGLTextureRangeSetBounds(const NSRect *pBounds,
										OpenGLTextureRangeDataRef pTextureRange)
{
	BOOL bSuccess = OpenGLTextureRangeSetSize(pBounds, pTextureRange);
	
	if( bSuccess )
	{
		OpenGLTextureRangeSetBuffer(pTextureRange);
		
		OpenGLTextureRangeDeleteImage2D(pTextureRange);
		OpenGLTextureRangeSetOffsets(&pBounds->origin, pTextureRange);
		OpenGLTextureRangeCreateImage2D(pTextureRange);
		
		OpenGLTextureRangeSetName(pTextureRange);
	} // if
	
	return bSuccess;
} // setBounds

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Rendering

//---------------------------------------------------------------------------


static void OpenGLTextureRangeUpdate(const GLvoid *pPixels,
									 OpenGLTextureRangeDataRef pTextureRange)
{
	// Update the texture
	
	glEnable(pTextureRange->target);
	{
		glBindTexture(pTextureRange->target,
					  pTextureRange->name);
		
		glTexSubImage2D(pTextureRange->target,
						pTextureRange->level,
						pTextureRange->xoffset,
						pTextureRange->yoffset,
						pTextureRange->buffer.width,
						pTextureRange->buffer.height,
						pTextureRange->format,
						pTextureRange->type,
						pPixels);
	}
	glDisable(pTextureRange->target);
} // OpenGLTextureRangeUpdate

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark
#pragma mark -

//---------------------------------------------------------------------------

@implementation OpenGLTextureRange

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Designated Initializers

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
// Initialize
//
//---------------------------------------------------------------------------

- (id) initTextureRangeWithBounds:(const NSRect *)theBounds
							 hint:(const GLint)theHint;
{
	self = [super init];
	
	if( self )
	{
		mpTextureRange = OpenGLTextureRangeCreate(theBounds, theHint);
	} // if
	
	return( self );
} // initTextureRangeWithBounds

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//---------------------------------------------------------------------------

- (void) dealloc
{
	OpenGLTextureRangeDelete(mpTextureRange);
	
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//---------------------------------------------------------------------------

- (GLenum) target
{
	return( mpTextureRange->target );
} // target

//---------------------------------------------------------------------------

- (GLuint) name
{
	return( mpTextureRange->name );
} // name

//---------------------------------------------------------------------------

- (GLuint) height
{
	return( mpTextureRange->buffer.height );
} // height

//---------------------------------------------------------------------------

- (GLuint) width
{
	return( mpTextureRange->buffer.width );
} // width

//---------------------------------------------------------------------------

- (GLuint) rowBytes
{
	return( mpTextureRange->buffer.rowBytes );
} // rowBytes

//---------------------------------------------------------------------------

- (GLuint) samplesPerPixel
{
	return( mpTextureRange->buffer.samplesPerPixel );
} // samplesPerPixel

//---------------------------------------------------------------------------

- (GLuint) size
{
	return( mpTextureRange->buffer.size );
} // size

//---------------------------------------------------------------------------

- (NSDictionary *) dictionary
{
	return( mpTextureRange->dictionary );
} // dictionary

//---------------------------------------------------------------------------

- (BOOL) setBounds:(const NSRect *)theBounds
{
	return OpenGLTextureRangeSetBounds(theBounds, mpTextureRange);
} // setBounds

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Rendering

//---------------------------------------------------------------------------
//
// Update the texture
//
//---------------------------------------------------------------------------

- (void) update:(const GLvoid *)thePixels
{
	OpenGLTextureRangeUpdate(thePixels, mpTextureRange);
} // update

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
