//---------------------------------------------------------------------------------------
//
//	File: OpenGLViewBoundsLabel.m
//
//  Abstract: Utility class for displaying view's mnWidth & mnHeight
//
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by
//  Inc. ("Apple") in consideration of your agreement to the following terms,
//  and your use, installation, modification or redistribution of this Apple
//  software constitutes acceptance of these terms.  If you do not agree with
//  these terms, please do not use, install, modify or redistribute this
//  Apple software.
//
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software.
//  Neither the name, trademarks, service marks or logos of Apple Inc. may
//  be used to endorse or promote products derived from the Apple Software
//  without specific prior written permission from Apple.  Except as
//  expressly stated in this notice, no other rights or licenses, express
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
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#import "OpenGLViewBoundsLabel.h"

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structures

//---------------------------------------------------------------------------------------

struct OpenGLViewBoundsLabelData
{
	
	NSString  *mpFormat;
	NSString  *mpLabel;
	GLsizei  mnWidth;
	GLsizei  mnHeight;
	BOOL     mbDoDisplay;
};

typedef struct	OpenGLViewBoundsLabelData OpenGLViewBoundsLabelData;

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------------------

@implementation OpenGLViewBoundsLabel

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated Initializer

//---------------------------------------------------------------------------------------
//
// Make sure client goes through designated initializer
//
//---------------------------------------------------------------------------------------

- (id) initWithString:(NSString *)theTextString
			 fontName:(NSString *)theFontName
			 fontSize:(const CGFloat)theFontSize
			textColor:(NSColor *)theTextColor
			 boxColor:(NSColor *)theBoxColor
		  borderColor:(NSColor *)theBorderColor
		  coordinates:(const NSPoint *)theCoordinates
			   bounds:(const NSRect *)theBounds
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // initWithString

//---------------------------------------------------------------------------------------

- (id) initLabelWithFormat:(NSString *)theFormatString
				  fontName:(NSString *)theFontName
				  fontSize:(const CGFloat)theFontSize
				 textColor:(NSColor *)theTextColor
				  boxColor:(NSColor *)theBoxColor
			   borderColor:(NSColor *)theBorderColor
			   coordinates:(const NSPoint *)theCoordinates
					bounds:(const NSRect *)theBounds
{
	NSString *pFormat = nil;
	
	if( theFormatString )
	{
		pFormat = [NSString stringWithString:theFormatString];
	} // if
	else
	{
		pFormat = @"Bounds: %ld x %ld";
	} // else
	
	if( pFormat )
	{
		GLsizei nWidth  = (GLsizei)theBounds->size.width;
		GLsizei nHeight = (GLsizei)theBounds->size.height;
		
		NSString *pLabel = [NSString stringWithFormat:pFormat,nWidth,nHeight];
		
		if( pLabel )
		{
			self = [super initWithString:pLabel
								fontName:theFontName
								fontSize:theFontSize
							   textColor:theTextColor
								boxColor:theBoxColor
							 borderColor:theBorderColor
							 coordinates:theCoordinates
								  bounds:theBounds];
			
			if( self )
			{
				[self setUsage:kOpenGLTextureUsePBOStreamDraw];
				
				mpLabelViewBounds = (OpenGLViewBoundsLabelDataRef)calloc(1, sizeof(OpenGLViewBoundsLabelData));
				
				if( mpLabelViewBounds != NULL )
				{
					mpLabelViewBounds->mpFormat    = [pFormat retain];
					mpLabelViewBounds->mpLabel     = [pLabel retain];
					mpLabelViewBounds->mnWidth     = nWidth;
					mpLabelViewBounds->mnHeight    = nHeight;
					mpLabelViewBounds->mbDoDisplay = YES;
				} // if
				else
				{
					NSLog( @">> ERROR: OpenGL View Bounds Label - Failure Allocating Memory For Attributes!" );
				}  // else
			} // if
		} // if
	} // if
	
	return( self );
} // initLabelWithFormat

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Deallocating Resources

//---------------------------------------------------------------------------------------

- (void) dealloc
{
	// Attributes are not required
	
	if( mpLabelViewBounds != NULL )
	{
		// Release string objects
		
		if( mpLabelViewBounds->mpLabel )
		{
			[mpLabelViewBounds->mpLabel release];
			
			mpLabelViewBounds->mpLabel = nil;
		} // if
		
		if( mpLabelViewBounds->mpFormat )
		{
			[mpLabelViewBounds->mpFormat release];
			
			mpLabelViewBounds->mpFormat = nil;
		} // if
		
		free( mpLabelViewBounds );
		
		mpLabelViewBounds = NULL;
	} // if
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Updating View Bounds

//---------------------------------------------------------------------------------------

- (void) viewSetBounds:(const NSRect *)theBounds
{
	GLsizei nWidth  = (GLsizei)theBounds->size.width;
	GLsizei nHeight = (GLsizei)theBounds->size.height;
	
	NSString *pLabel = [[NSString alloc] initWithFormat:mpLabelViewBounds->mpFormat,
						nWidth,
						nHeight];
	
	if( pLabel )
	{
		[mpLabelViewBounds->mpLabel release];
		
		mpLabelViewBounds->mnWidth  = nWidth;
		mpLabelViewBounds->mnHeight = nHeight;
		
		mpLabelViewBounds->mpLabel = pLabel;
		
		[self setText:mpLabelViewBounds->mpLabel];
	} // if
	
	[super viewSetBounds:theBounds];
} // labelSetBounds

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Label Utilities

//---------------------------------------------------------------------------------------

- (void) labelSetNeedsDisplay:(const BOOL)theLabelNeedsDisplay
{
	mpLabelViewBounds->mbDoDisplay = theLabelNeedsDisplay;
} // labelSetNeedsDisplay

//---------------------------------------------------------------------------------------

- (void) labelSetFormatString:(NSString *)theFormatString
{
	if( theFormatString )
	{
		[theFormatString retain];
		
		[mpLabelViewBounds->mpFormat release];
		
		mpLabelViewBounds->mpFormat = theFormatString;
	} //if
} // labelSetFormatString

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Drawing the label

//---------------------------------------------------------------------------------------

- (void) labelDraw
{
	if( mpLabelViewBounds->mbDoDisplay )
	{
		[self drawText];
	} // if
} // labelDraw

//---------------------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

