//-------------------------------------------------------------------------
//
//	File: CGBitmap.m
//
//  Abstract: Utility functions for converting XRGB pixels into RGBA
//            CG image opaque references.
//
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by
//  Apple Inc. ("Apple") in consideration of your agreement to the
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
//  Neither the name, trademarks, service marks or logos of Apple Inc.
//  may be used to endorse or promote products derived from the Apple
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
//-------------------------------------------------------------------------

//------------------------------------------------------------------------

#import "OpenGLTextureSourceTypes.h"

#import "CGBitmap.h"

//------------------------------------------------------------------------

//------------------------------------------------------------------------

struct CGBitmap
{
	GLboolean        mbIsOwned;
	GLuint           mnBitsPerComponent;
 	GLuint           mnSamplesPerPixel;
	GLuint           mnHeight;				// The height (in pixels) of the buffer
    GLuint           mnWidth;				// The width (in pixels) of the buffer
    GLuint           mnRowBytes;			// The number of bytes in a pixel row
    GLuint           mnSize;				// The image size
    GLvoid          *mpPixels;				// Pointer to the top left pixel of the buffer
	CGBitmapInfo     mnBitmapInfo;
	CFStringRef      mpColorSpaceName;
	CGColorSpaceRef  mpColorSpace;
	CGContextRef     mpContext;
};

typedef struct CGBitmap   CGBitmap;

//------------------------------------------------------------------------

//------------------------------------------------------------------------

BOOL CGBitmapRelease( CGBitmapRef pBitmapImage )
{
	BOOL  bSuccess = NO;
	
	if( pBitmapImage != NULL )
	{
		if( pBitmapImage->mpColorSpace != NULL )
		{
			CGColorSpaceRelease( pBitmapImage->mpColorSpace );
			
			pBitmapImage->mpColorSpace = NULL;
		} // if
		
		if( pBitmapImage->mpContext != NULL )
		{
			CGContextRelease( pBitmapImage->mpContext );
			
			pBitmapImage->mpContext = NULL;
		} // if
		
		free( pBitmapImage );
		
		pBitmapImage = NULL;
		
		bSuccess = YES;
	} // if
	
	return( bSuccess );
} // CGBitmapRelease

//------------------------------------------------------------------------

static void CGBitmapSetProperties(const NSSize *pSize,
								  const CGImageAlphaInfo nAlphaInfo,
								  void *pPixels,
								  CGBitmapRef pBitmapImage)
{
	pBitmapImage->mpColorSpaceName = kCGColorSpaceGenericRGB;
	pBitmapImage->mpColorSpace     = CGColorSpaceCreateWithName(pBitmapImage->mpColorSpaceName);
	
	if( pBitmapImage->mpColorSpace != NULL )
	{
		pBitmapImage->mnSamplesPerPixel  = kTextureMaxSPP;
		pBitmapImage->mnBitsPerComponent = kTextureMaxBPS;
		pBitmapImage->mpPixels           = pPixels;
		pBitmapImage->mnWidth            = (GLuint)pSize->width;
		pBitmapImage->mnHeight           = (GLuint)pSize->height;
		pBitmapImage->mnRowBytes         = pBitmapImage->mnSamplesPerPixel * pBitmapImage->mnWidth;
		pBitmapImage->mnSize             = pBitmapImage->mnRowBytes * pBitmapImage->mnHeight;
		pBitmapImage->mnBitmapInfo       = nAlphaInfo | kCGBitmapByteOrder32Little;	// XRGB Little Endian
		
		pBitmapImage->mpContext = CGBitmapContextCreate(pBitmapImage->mpPixels,
														pBitmapImage->mnWidth,
														pBitmapImage->mnHeight,
														pBitmapImage->mnBitsPerComponent,
														pBitmapImage->mnRowBytes,
														pBitmapImage->mpColorSpace,
														pBitmapImage->mnBitmapInfo);
	} // if
} // CGBitmapSetProperties

//------------------------------------------------------------------------

CGBitmapRef CGBitmapCreateWithPixels(const NSSize *pSize,
									 const CGImageAlphaInfo nAlphaInfo,
									 void *pPixels)
{
	CGBitmapRef pBitmapImage = NULL;
	
	if( pPixels != NULL )
	{
		pBitmapImage = (CGBitmapRef)calloc(1,sizeof(CGBitmap));
		
		if( pBitmapImage != NULL )
		{
			pBitmapImage->mbIsOwned = GL_FALSE;
			
			CGBitmapSetProperties(pSize, nAlphaInfo, pPixels, pBitmapImage);
		} // if
	} // if
	
	return( pBitmapImage );
} // CGBitmapCreateWithPixels

//------------------------------------------------------------------------

CGBitmapRef CGBitmapCreate(const NSSize *pSize,
						   const CGImageAlphaInfo nAlphaInfo)
{
	CGBitmapRef pBitmapImage = (CGBitmapRef)calloc(1,sizeof(CGBitmap));
	
	if( pBitmapImage != NULL )
	{
		pBitmapImage->mbIsOwned = GL_TRUE;
		
		CGBitmapSetProperties(pSize, nAlphaInfo, NULL, pBitmapImage);
	} // if
	
	return( pBitmapImage );
} // CGBitmapCreate

//------------------------------------------------------------------------

CGBitmapRef CGBitmapCreateCopy(CGBitmapRef pBitmapImageSrc)
{
	CGBitmapRef pBitmapImageDst = (CGBitmapRef)calloc(1,sizeof(CGBitmap));
	
	if( pBitmapImageDst != NULL )
	{
		pBitmapImageDst->mbIsOwned        = pBitmapImageSrc->mbIsOwned;
		pBitmapImageDst->mpColorSpaceName = pBitmapImageSrc->mpColorSpaceName;
		pBitmapImageDst->mpColorSpace     = CGColorSpaceCreateWithName(pBitmapImageDst->mpColorSpaceName);
		
		if( pBitmapImageDst->mpColorSpace != NULL )
		{
			pBitmapImageDst->mnSamplesPerPixel  = kTextureMaxSPP;
			pBitmapImageDst->mnBitsPerComponent = kTextureMaxBPS;
			pBitmapImageDst->mpPixels           = pBitmapImageSrc->mpPixels;
			pBitmapImageDst->mnWidth            = pBitmapImageSrc->mnWidth;
			pBitmapImageDst->mnHeight           = pBitmapImageSrc->mnHeight;
			pBitmapImageDst->mnRowBytes         = pBitmapImageSrc->mnRowBytes;
			pBitmapImageDst->mnSize             = pBitmapImageSrc->mnSize;
			pBitmapImageDst->mnBitmapInfo       = pBitmapImageSrc->mnBitmapInfo;
			
			pBitmapImageDst->mpContext = CGBitmapContextCreate(pBitmapImageDst->mpPixels,
															   pBitmapImageDst->mnWidth,
															   pBitmapImageDst->mnHeight,
															   pBitmapImageDst->mnBitsPerComponent,
															   pBitmapImageDst->mnRowBytes,
															   pBitmapImageDst->mpColorSpace,
															   pBitmapImageDst->mnBitmapInfo);
		} // if
	} // if
	
	return( pBitmapImageDst );
} // CGBitmapCreateCopy

//------------------------------------------------------------------------

void CGBitmapSetPixels(void *pPixels,
					   CGBitmapRef pBitmapImage)
{
	if( ( pPixels != NULL ) && ( !pBitmapImage->mbIsOwned ) )
	{
		pBitmapImage->mpPixels = pPixels;
	} // if
} // CGBitmapSetPixels

//------------------------------------------------------------------------

void CGBitmapSetShouldAntialias(const bool bShouldAntialias,
								CGBitmapRef pBitmapImage)
{
	CGContextSetShouldAntialias(pBitmapImage->mpContext, bShouldAntialias);
} // CGBitmapSetShouldAntialias

//------------------------------------------------------------------------

void CGBitmapSetBlendMode(const CGBlendMode nMode,
						  CGBitmapRef pBitmapImage)
{
	CGContextSetBlendMode(pBitmapImage->mpContext, nMode);
} // CGBitmapSetBlendMode

//------------------------------------------------------------------------

GLuint CGBitmapGetWidth(CGBitmapRef pBitmapImage)
{
	return( pBitmapImage->mnWidth );
} // CGBitmapGetWidth

//------------------------------------------------------------------------

GLuint CGBitmapGetHeight(CGBitmapRef pBitmapImage)
{
	return( pBitmapImage->mnHeight );
} // CGBitmapGetHeight

//------------------------------------------------------------------------

GLuint CGBitmapGetRowBytes(CGBitmapRef pBitmapImage)
{
	return( pBitmapImage->mnRowBytes );
} // CGBitmapGetRowBytes

//------------------------------------------------------------------------

GLuint CGBitmapGetSize(CGBitmapRef pBitmapImage)
{
	return( pBitmapImage->mnSize );
} // CGBitmapGetSize

//------------------------------------------------------------------------

GLuint CGBitmapGetBitsPerComponent(CGBitmapRef pBitmapImage)
{
	return( pBitmapImage->mnBitsPerComponent );
} // CGBitmapGetBitsPerComponent

//------------------------------------------------------------------------

GLuint CGBitmapGetSamplesPerPixel(CGBitmapRef pBitmapImage)
{
	return( pBitmapImage->mnSamplesPerPixel );
} // CGBitmapGetSamplesPerPixel

//------------------------------------------------------------------------

CGBitmapInfo CGBitmapGetBitmapInfo(CGBitmapRef pBitmapImage)
{
	return( pBitmapImage->mnBitmapInfo );
} // CGBitmapGetBitmapInfo

//------------------------------------------------------------------------

CGColorSpaceRef CGBitmapGetColorSpace(CGBitmapRef pBitmapImage)
{
	return( pBitmapImage->mpColorSpace );
} // CGBitmapGetColorSpace

//------------------------------------------------------------------------

CGContextRef CGBitmapGetContext(CGBitmapRef pBitmapImage)
{
	return( pBitmapImage->mpContext );
} // CGBitmapGetContext

//------------------------------------------------------------------------

void *CGBitmapGetPixels(CGBitmapRef pBitmapImage)
{
	return( CGBitmapContextGetData(pBitmapImage->mpContext) );
} // CGBitmapGetPixels

//------------------------------------------------------------------------

void CGBitmapCopyPixels(const void *pPixelsSrc,
						CGBitmapRef pBitmapImage)
{
	if( pPixelsSrc != NULL )
	{
		void *pPixelsDst = (pBitmapImage->mbIsOwned)
		? CGBitmapContextGetData(pBitmapImage->mpContext)
		: pBitmapImage->mpPixels;
		
		memcpy( pPixelsDst, pPixelsSrc, pBitmapImage->mnSize );
	} // if
} // CGBitmapCopyPixels

//------------------------------------------------------------------------

CGImageRef CGBitmapCreateImage(CGBitmapRef pBitmapImage)
{
	CGImageRef imageRef = NULL;
	
	if( ( pBitmapImage != NULL ) && ( pBitmapImage->mpContext != NULL ) )
	{
		// Create a new image from the bitmap context
		
		imageRef = CGBitmapContextCreateImage( pBitmapImage->mpContext );
	} // if
	
	return( imageRef );
} // CGBitmapCreateImage

//------------------------------------------------------------------------

//------------------------------------------------------------------------

