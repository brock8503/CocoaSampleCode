//-------------------------------------------------------------------------
//
//	File: OpenGLViewImageBase.m
//
//  Abstract: Utility class for generating a CGImagRef from an
//            OpenGL view
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

#import "CGBitmap.h"
#import "OpenGLViewImageBase.h"

//------------------------------------------------------------------------

//------------------------------------------------------------------------

struct OpenGLViewImageBaseData
{
	BOOL         mbFrameChanged;
	BOOL         mbInvalidated;
	CGImageRef   mpImage;
	NSRect       m_Frame;
	CGBitmapRef  mpBitmap;
};

typedef struct OpenGLViewImageBaseData   OpenGLViewImageBaseData;

//------------------------------------------------------------------------

//------------------------------------------------------------------------

@implementation OpenGLViewImageBase

//------------------------------------------------------------------------

- (id) initViewImageBaseWithFrame:(const NSRect *)theFrame
							 view:(NSOpenGLView *)theBaseView
{
	self = [super initViewPixelsWithFrame:theFrame
									 view:theBaseView];
	
	if( self )
	{
		mpViewImageBase = (OpenGLViewImageBaseDataRef)calloc(1, sizeof(OpenGLViewImageBaseData));
		
		if( mpViewImageBase != NULL )
		{
			mpViewImageBase->m_Frame        = *theFrame;
			mpViewImageBase->mbFrameChanged = YES;
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL View CGImage - Failure Allocating Memory For attributes!" );
		} // else
	} // if
	
	return( self );
} // initViewImageBaseWithFrame

//------------------------------------------------------------------------

//------------------------------------------------------------------------

- (void) cleanUpViewImageBase
{
	if( mpViewImageBase != NULL )
	{
		CGBitmapRelease(mpViewImageBase->mpBitmap);
		CGImageRelease(mpViewImageBase->mpImage);
		
		free( mpViewImageBase );
		
		mpViewImageBase = NULL;
	} // if
} // cleanUpViewImageBase

//------------------------------------------------------------------------

- (void) dealloc
{
	// Release the opaque data structure
	
	[self cleanUpViewImageBase];
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

+ (id) viewImageBaseWithFrame:(const NSRect *)theFrame
						 view:(NSOpenGLView *)theBaseView
{
	return( [[[OpenGLViewImageBase allocWithZone:[self zone]] initViewImageBaseWithFrame:theFrame
																					view:theBaseView] autorelease] );
} // viewImageBaseWithFrame

//------------------------------------------------------------------------

- (void) setFrame:(const NSRect *)theFrame
{
	if(   ( theFrame->size.width  != mpViewImageBase->m_Frame.size.width  )
	   || ( theFrame->size.height != mpViewImageBase->m_Frame.size.height ) )
	{
		mpViewImageBase->m_Frame        = *theFrame;
		mpViewImageBase->mbFrameChanged = YES;
	} // if
} // setFrame

//------------------------------------------------------------------------

- (void) invalidate:(const BOOL)theImageIsInvlidated
{
	mpViewImageBase->mbInvalidated = theImageIsInvlidated;
} // invalidate

//------------------------------------------------------------------------

- (NSRect) frame
{
	return( mpViewImageBase->m_Frame );
} // frame

//------------------------------------------------------------------------

- (CGImageRef) imageRef
{
	if( mpViewImageBase->mbFrameChanged )
	{
		[super setFrame:&mpViewImageBase->m_Frame];
		
		GLvoid *pPixels = [self pixels];
		
		if( pPixels != NULL )
		{
			CGBitmapRef pBitmap = CGBitmapCreateWithPixels(&mpViewImageBase->m_Frame.size,
														   kCGImageAlphaNoneSkipFirst,
														   pPixels);
			
			if( pBitmap != NULL )
			{
				CGBitmapRelease(mpViewImageBase->mpBitmap);
				
				mpViewImageBase->mpBitmap = pBitmap;
				
				CGImageRef pImage = CGBitmapCreateImage(mpViewImageBase->mpBitmap);
				
				if( pImage != NULL )
				{
					CGImageRelease(mpViewImageBase->mpImage);
					
					mpViewImageBase->mpImage        = pImage;
					mpViewImageBase->mbFrameChanged = NO;
				} // if
			} // if
		} // if
	} // if
	else if( mpViewImageBase->mbInvalidated )
	{
		GLvoid *pPixels = [self pixels];
		
		if( pPixels != NULL )
		{
			CGBitmapSetPixels( pPixels, mpViewImageBase->mpBitmap );
			
			CGImageRef pImage = CGBitmapCreateImage(mpViewImageBase->mpBitmap);
			
			if( pImage != NULL )
			{
				CGImageRelease(mpViewImageBase->mpImage);
				
				mpViewImageBase->mpImage       = pImage;
				mpViewImageBase->mbInvalidated = NO;
			} // if
		} // if
	} // else if
	
	return( mpViewImageBase->mpImage );
} // mpImage

//------------------------------------------------------------------------

@end

//------------------------------------------------------------------------

//------------------------------------------------------------------------

