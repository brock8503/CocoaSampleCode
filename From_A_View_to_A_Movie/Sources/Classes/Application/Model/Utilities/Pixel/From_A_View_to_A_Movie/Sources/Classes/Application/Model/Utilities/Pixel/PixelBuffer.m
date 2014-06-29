/*
     File: PixelBuffer.m
 Abstract: 
 Utility class encapsulating a backing store for RGBA OpenGL-style pixel buffers.
 
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

#import "OpenGLTextureSourceTypes.h"
#import "OpenGLImageBuffer.h"

#import "PixelBuffer.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Data Structures

//---------------------------------------------------------------------------

struct PixelBufferData
{
	GLuint             bitsPerComponent;
	GLenum             format;				// format
	GLenum             internalFormat;		// internal format
	GLenum             type;				// OpenGL specific type
	NSSize             size;
	OpenGLImageBuffer  image;
};

typedef struct PixelBufferData   PixelBufferData;

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Constructor

//---------------------------------------------------------------------------

static PixelBufferDataRef PixelBufferCreateWithSize(const NSSize *pSize)
{
	PixelBufferDataRef pPixelBuffer = NULL;
	
	if( pSize != NULL )
	{
		pPixelBuffer = (PixelBufferDataRef)calloc(1, sizeof(PixelBufferData));
		
		if( pPixelBuffer != NULL )
		{
			pPixelBuffer->bitsPerComponent = kTextureMaxBPS;
			pPixelBuffer->format           = kTextureSourceFormat;
			pPixelBuffer->type             = kTextureSourceType;
			pPixelBuffer->internalFormat   = kTextureInternalFormat;
			pPixelBuffer->size             = *pSize;
			
			pPixelBuffer->image.samplesPerPixel = kTextureMaxSPP;
			pPixelBuffer->image.width           = (GLuint)pSize->width;
			pPixelBuffer->image.height          = (GLuint)pSize->height;
			pPixelBuffer->image.rowBytes        = pPixelBuffer->image.width  * pPixelBuffer->image.samplesPerPixel;
			pPixelBuffer->image.size            = pPixelBuffer->image.height * pPixelBuffer->image.rowBytes;
			pPixelBuffer->image.data            = calloc(pPixelBuffer->image.height, pPixelBuffer->image.rowBytes);
			
			if( pPixelBuffer->image.data == NULL )
			{
				NSLog( @">> ERROR: Pixel Buffer - Failure Allocating Memory For Pixel Buffer Data Store!" );
			} //if
		} // if
		else
		{
			NSLog( @">> ERROR: Pixel Buffer - Failure Allocating Memory For Attributes!" );
		} // else
	} // if
	
	return pPixelBuffer;
} // PixelBufferCreateWithSize

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Copy Constructor

//---------------------------------------------------------------------------

static PixelBufferDataRef PixelBufferCreateCopy(PixelBuffer *pPixelBufferSrc)
{
	PixelBufferDataRef pPixelBufferDst = NULL;
	
	if( pPixelBufferSrc )
	{
		pPixelBufferDst = (PixelBufferDataRef)calloc(1, sizeof(PixelBufferData));
		
		if( pPixelBufferDst != NULL )
		{
			pPixelBufferDst->bitsPerComponent = kTextureMaxBPS;
			pPixelBufferDst->format           = kTextureSourceFormat;
			pPixelBufferDst->type             = kTextureSourceType;
			pPixelBufferDst->internalFormat   = kTextureInternalFormat;
			
			pPixelBufferDst->image.samplesPerPixel = kTextureMaxSPP;
			pPixelBufferDst->image.width           = [pPixelBufferSrc width];
			pPixelBufferDst->image.height          = [pPixelBufferSrc height];
			pPixelBufferDst->image.rowBytes        = pPixelBufferDst->image.width  * pPixelBufferDst->image.samplesPerPixel;
			pPixelBufferDst->image.size            = pPixelBufferDst->image.height * pPixelBufferDst->image.rowBytes;
			
			if(pPixelBufferDst->image.size > 0)
			{
				pPixelBufferDst->image.data = calloc(pPixelBufferDst->image.height, pPixelBufferDst->image.rowBytes);
				
				GLvoid *pDataSrc = [pPixelBufferSrc data];
				
				if( (pDataSrc != NULL) && (pPixelBufferDst->image.data != NULL) )
				{
					memcpy(pPixelBufferDst->image.data,
						   pDataSrc,
						   pPixelBufferDst->image.size);
				} // if
			} // if
			
			pPixelBufferDst->size = NSMakeSize((CGFloat)pPixelBufferDst->image.width,
											   (CGFloat)pPixelBufferDst->image.height);
		} // if
	} // if
	
	return pPixelBufferDst;
} // PixelBufferCreateCopy

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Destructor

//---------------------------------------------------------------------------

static void PixelBufferDelete(PixelBufferDataRef pPixelBuffer)
{
	if( pPixelBuffer != NULL )
	{
		if( pPixelBuffer->image.data != NULL )
		{
			free( pPixelBuffer->image.data );
		} // if
		
		free( pPixelBuffer );
		
		pPixelBuffer = NULL;
	} // if
} // PixelBufferDelete

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Accessor

//---------------------------------------------------------------------------

static BOOL PixelBufferSetSize(const NSSize *pSize,
							   PixelBufferDataRef pPixelBuffer)
{
	BOOL bSuccess = pSize != NULL;
	
	if( bSuccess )
	{
		bSuccess = (pSize->width != pPixelBuffer->size.width ) || (pSize->height != pPixelBuffer->size.height);
		
		if( bSuccess )
		{
			pPixelBuffer->size           = *pSize;
			pPixelBuffer->image.width    = (GLuint)pSize->width;
			pPixelBuffer->image.height   = (GLuint)pSize->height;
			pPixelBuffer->image.rowBytes = pPixelBuffer->image.width  * pPixelBuffer->image.samplesPerPixel;
			pPixelBuffer->image.size     = pPixelBuffer->image.height * pPixelBuffer->image.rowBytes;
			pPixelBuffer->image.data     = realloc(pPixelBuffer->image.data, pPixelBuffer->image.size);
			
			bSuccess = pPixelBuffer->image.data != NULL;
		} // if
	} // if
	
	return bSuccess;
} // PixelBufferSetSize

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities

//---------------------------------------------------------------------------

static BOOL PixelBufferCopyData(const GLvoid *pData,
								PixelBufferDataRef pPixels)
{
	BOOL bSuccess = (pData != NULL) && (pPixels->image.data != NULL);
	
	if( bSuccess )
	{
		memcpy(pPixels->image.data,
			   pData,
			   pPixels->image.size);
	} // if
	
	return bSuccess;
} // PixelBufferCopyData

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Implementation

//---------------------------------------------------------------------------

@implementation PixelBuffer

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

#pragma mark -
#pragma mark Public - Designated Initializers

//---------------------------------------------------------------------------

- (id) initWithSize:(const NSSize *)theSize
{
	self = [super init];
	
	if( self )
	{
		mpPixelBuffer = PixelBufferCreateWithSize(theSize);
	} // if
	
	return( self );
} // initWithSize

//---------------------------------------------------------------------------

+ (id) pixelBufferWithSize:(const NSSize *)theSize
{
	return( [[[PixelBuffer allocWithZone:[self zone]] initWithSize:theSize] autorelease] );
} // pixelBufferWithSize

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Copy Constructor

//---------------------------------------------------------------------------

- (id) initWithPixelBuffer:(PixelBuffer *)thePixelBuffer
{
	self = [super init];
	
	if( self )
	{
		mpPixelBuffer = PixelBufferCreateCopy(thePixelBuffer);
	} // if
	
	return self;
} // initWithPixelBuffer

//---------------------------------------------------------------------------

- (id) copyWithZone:(NSZone *)zone
{
    return [[PixelBuffer allocWithZone:zone] initWithPixelBuffer:self];
} // copyWithZone

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//---------------------------------------------------------------------------

- (void) dealloc
{
	PixelBufferDelete(mpPixelBuffer);
	
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//---------------------------------------------------------------------------

- (BOOL) setSize:(const NSSize *)theSize
{
	return PixelBufferSetSize(theSize, mpPixelBuffer);
} // setSize

//---------------------------------------------------------------------------

- (GLenum) format
{
	return( mpPixelBuffer->format );
} // format

//---------------------------------------------------------------------------

- (GLenum) type
{
	return( mpPixelBuffer->type );
} // type

//---------------------------------------------------------------------------

- (GLenum) internalFormat
{
	return( mpPixelBuffer->internalFormat );
} // internalFormat

//---------------------------------------------------------------------------

- (GLuint) bitsPerComponent
{
	return( mpPixelBuffer->bitsPerComponent );
} // bitsPerComponent

//---------------------------------------------------------------------------

- (GLuint) samplesPerPixel
{
	return( mpPixelBuffer->image.samplesPerPixel );
} // samplesPerPixel

//---------------------------------------------------------------------------

- (GLuint) width
{
	return( mpPixelBuffer->image.width );
} // width

//---------------------------------------------------------------------------

- (GLuint) height
{
	return( mpPixelBuffer->image.height );
} // height

//---------------------------------------------------------------------------

- (GLuint) rowBytes
{
	return( mpPixelBuffer->image.rowBytes );
} // rowBytes

//---------------------------------------------------------------------------

- (NSSize) dimensions
{
	return( mpPixelBuffer->size );
} // dimensions

//---------------------------------------------------------------------------

- (GLuint) size
{
	return( mpPixelBuffer->image.size );
} // size

//---------------------------------------------------------------------------

- (GLvoid *) buffer
{
	return( mpPixelBuffer->image.data );
} // buffer

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities

//---------------------------------------------------------------------------

- (NSData *) data
{
	return( [NSData dataWithBytes:mpPixelBuffer->image.data
						   length:mpPixelBuffer->image.size] );
} // data


//---------------------------------------------------------------------------

- (BOOL) update:(const GLvoid *)thePixelBuffer
{
	return PixelBufferCopyData(thePixelBuffer, mpPixelBuffer);
} // update

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

