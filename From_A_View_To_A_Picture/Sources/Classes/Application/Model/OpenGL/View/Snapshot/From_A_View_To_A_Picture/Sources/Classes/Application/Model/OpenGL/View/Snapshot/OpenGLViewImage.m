//------------------------------------------------------------------------
//
//	File: OpenGLViewImage.m
//
//  Abstract: Utility class for generating a NSImage from an OpenGL view
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
//------------------------------------------------------------------------

//------------------------------------------------------------------------

#import "OpenGLViewImage.h"

//------------------------------------------------------------------------

//------------------------------------------------------------------------

struct OpenGLViewImageData
{
	NSImage  *mpImage;
	CGRect    m_ContextFrame;
	NSRect    m_Frame;
	BOOL      mbFrameChanged;
	BOOL      mbInvalidated;
};

typedef struct OpenGLViewImageData  OpenGLViewImageData;

//------------------------------------------------------------------------

//------------------------------------------------------------------------

@implementation OpenGLViewImage

//------------------------------------------------------------------------

- (id) initViewImageWithFrame:(const NSRect *)theFrame
						 view:(NSOpenGLView *)theBaseView
{
	self = [super initViewImageBaseWithFrame:theFrame
										view:theBaseView];
	
	if( self )
	{
		mpViewImage = (OpenGLViewImageDataRef)calloc(1, sizeof(OpenGLViewImageData));
		
		if( mpViewImage != NULL )
		{
			mpViewImage->m_Frame        = *theFrame;
			mpViewImage->mbFrameChanged = YES;
			mpViewImage->m_ContextFrame = NSRectToCGRect( mpViewImage->m_Frame );
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL View NSImage- Failure Allocating Memory For Attributes!" );
		} // else
	} // if
	
	return( self );
} // initViewImageWithFrame

//------------------------------------------------------------------------

- (void) cleanUpImage
{
	if( mpViewImage->mpImage )
	{
		[mpViewImage->mpImage release];
		
		mpViewImage->mpImage = nil;
	} // if
} // cleanUpImage

//------------------------------------------------------------------------

- (void) cleanUpViewImage
{
	if( mpViewImage != NULL )
	{
		[self cleanUpImage];
		
		free( mpViewImage );
		
		mpViewImage = NULL;
	} //if
} // cleanUpViewImage

//------------------------------------------------------------------------

- (void) dealloc
{
	// Release the nsImage
	
	[self cleanUpViewImage];
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

+ (id) viewImageWithFrame:(const NSRect *)theFrame
					 view:(NSOpenGLView *)theBaseView
{
	return( [[[OpenGLViewImage allocWithZone:[self zone]] initViewImageWithFrame:theFrame
																			view:theBaseView] autorelease] );
} // viewImageWithFrame

//------------------------------------------------------------------------

- (void) setFrame:(const NSRect *)theFrame
{
	if(   ( theFrame->size.width  != mpViewImage->m_Frame.size.width  )
	   || ( theFrame->size.height != mpViewImage->m_Frame.size.height ) )
	{
		mpViewImage->m_Frame        = *theFrame;
		mpViewImage->m_ContextFrame = NSRectToCGRect( mpViewImage->m_Frame );
		mpViewImage->mbFrameChanged = YES;
	} // if
	
	[super setFrame:theFrame];
} // setFrame

//------------------------------------------------------------------------

- (void) invalidate:(const BOOL)theImageIsInvlidated
{
	mpViewImage->mbInvalidated = theImageIsInvlidated;
	
	[super invalidate:theImageIsInvlidated];
} // invalidate

//------------------------------------------------------------------------
//
// Create a new nsImage to receive the Quartz nsImage data
//
//------------------------------------------------------------------------

- (void) imageCreateWithFrame
{
	NSImage *pImage = [[NSImage alloc] initWithSize:mpViewImage->m_Frame.size];
	
	if( pImage )
	{
		[mpViewImage->mpImage release];
		
		mpViewImage->mpImage = pImage;
	} // if
} // imageCreateWithFrame

//------------------------------------------------------------------------

- (void) imageInitWithCGImage
{
	if( mpViewImage->mpImage )
	{
		CGImageRef pImage = [self imageRef];
		
		[mpViewImage->mpImage lockFocus];
		{
			CGContextRef pContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
			
			CGContextDrawImage(pContext,
							   mpViewImage->m_ContextFrame,
							   pImage);
		}
		[mpViewImage->mpImage unlockFocus];
	} // if
} // imageInitWithCGImage

//------------------------------------------------------------------------

- (NSImage *) image
{
	if( mpViewImage->mbFrameChanged )
	{
		[self imageCreateWithFrame];
		[self imageInitWithCGImage];
		
		mpViewImage->mbFrameChanged = NO;
	} // if
	else if( mpViewImage->mbInvalidated )
	{
		[self imageInitWithCGImage];
		
		mpViewImage->mbInvalidated = NO;
	} // else if
	
	return( mpViewImage->mpImage );
} // image

//------------------------------------------------------------------------

@end

//------------------------------------------------------------------------

//------------------------------------------------------------------------

